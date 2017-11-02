import Functional
import Abstract
import Monads
import Signals
import JSONObject

public typealias FieldViewModelPair = (viewModel: FieldViewModel, indexPath: FieldIndexPath)
public typealias FieldValueCompletePair = (fieldValue: FieldValue?, indexPath: FieldIndexPathComplete)

public final class Form {

	private let storage: FormStorage
	private let model: FormModel
	private let disposableBag = DisposableBag()

	private let variableFieldViewModelPair = Emitter<FieldViewModelPair>()
	public private(set) var observableFieldViewModelPair = AnyObservable(Emitter<FieldViewModelPair>())
    
	public init(storage: FormStorage, model: FormModel) {
		self.storage = storage
		self.model = model
        
        self.observableFieldViewModelPair = AnyObservable(self.variableFieldViewModelPair)

		storage.observableFieldKey
			.mapSome(Form.getFieldViewModelIndexPathPair(model: model, storage: storage))
			.bind(to: self.variableFieldViewModelPair)
			.add(to: disposableBag)
	}

	deinit {
		disposableBag.dispose()
	}

	public var formConfiguration: FormConfiguration {
		return model.configuration
	}

	public func stepConfiguration(at index: UInt) -> FormStepConfiguration? {
		guard model.subelements.indices.contains(Int(index)) else { return nil }
		return model.subelements[Int(index)].configuration
	}

	public func sectionConfiguration(at sectionIndex: UInt, forStep stepIndex: UInt) -> FormSectionConfiguration? {
		guard model.subelements.indices.contains(Int(stepIndex)) else { return nil }
		let step = model.subelements[Int(stepIndex)]
		guard step.subelements.indices.contains(Int(sectionIndex)) else { return nil }
		return step.subelements[Int(sectionIndex)].configuration
	}

	public func editStorage(with transform: (FormStorage) -> ()) {
		transform(storage)
	}

	public var allPairs: [FieldViewModelPair] {
		let elements: [Field] = model.subelements
			.map { $0.subelements }
			.joined
			.map { $0.subelements }
			.joined
		return elements
			.map { $0.key }
			.flatMap(Form.getFieldViewModelIndexPathPair(model: model, storage: storage))
	}

	public func update(pair: FieldValueCompletePair) {
		let stepIndex = Int(pair.indexPath.stepIndex)
		let sectionIndex = Int(pair.indexPath.sectionIndex)
		let fieldIndex = Int(pair.indexPath.fieldIndex)
		guard
			let step = model.subelements.indices.contains(stepIndex)
				? model.subelements[stepIndex]
				: nil,
			let section = step.subelements.indices.contains(sectionIndex)
				? step.subelements[sectionIndex]
				: nil,
			let field = section.subelements.indices.contains(fieldIndex)
				? section.subelements[fieldIndex]
				: nil
			else { return }
		field.updateValueAndApplyActions(with: pair.fieldValue, in: storage)
	}

	public func applyActions() {
		let elements: [Field] = self.model.subelements
			.map { $0.subelements }
			.joined
			.map { $0.subelements }
			.joined
		elements.forEach { $0.updateValueAndApplyActions(
				with: self.storage.getValue(at: $0.key),
				in: self.storage) }
	}

	public var getObjectChange: ObjectChange {
		return ObjectChange {
			let elements: [Field] = self.model.subelements
				.map { $0.subelements }
				.joined
				.map { $0.subelements }
				.joined
			return elements.reduce($0) { $1.transform(object: $0, considering: self.storage) }
		}
	}

	fileprivate static func getFieldViewModelIndexPathPair(model: FormModel, storage: FormStorage) -> (FieldKey) -> FieldViewModelPair? {
		return { key in
			Optional(Writer<FormModel,FieldIndexPath>.pure(model))
				.flatMapT { $0.getSubelement(at: key) }
				.flatMapT { $0.getSubelement(at: key) }
				.flatMapT { $0.getSubelement(at: key) }
				.mapT { $0.getViewModel(in: storage) }?
				.run
		}
	}
}
