import Functional

public typealias FieldViewModelPair = (viewModel: FieldViewModel, indexPath: FieldIndexPath)
public typealias FieldValueCompletePair = (fieldValue: FieldValue?, indexPath: FieldIndexPathComplete)

public final class Form: EmitterMapperType {
	public typealias ObservedType = FieldKey
	public typealias EmittedType = FieldViewModelPair

	private let storage: FormStorage
	private let model: FormModel
	public var identifier: String {
		return model.configuration.title.getOrEmpty
	}

	public var weakObservers: [AnyWeakObserver<FieldViewModelPair>] = []
	public var mappingFunction: (String) -> FieldViewModelPair {
		return getFieldViewModelIndexPathPair
	}

	public init(storage: FormStorage, model: FormModel) {
		self.storage = storage
		self.model = model
		storage.addObserver(self)
	}

	public var formConfiguration: FormConfiguration {
		return model.configuration
	}

	public func stepConfiguration(at index: UInt) -> FormStepConfiguration? {
		guard model.subelements.indices.contains(Int(index)) else { return nil }
		return model.subelements[index].configuration
	}

	public func sectionConfiguration(at sectionIndex: UInt, forStep stepIndex: UInt) -> FormSectionConfiguration? {
		guard model.subelements.indices.contains(Int(stepIndex)) else { return nil }
		let step = model.subelements[stepIndex]
		guard step.subelements.indices.contains(Int(sectionIndex)) else { return nil }
		return step.subelements[sectionIndex].configuration
	}

	public func editStorage(with transform: (FormStorage) -> ()) {
		transform(storage)
	}

	public var allPairs: [FieldViewModelPair] {
		return model.subelements
			.flatMap { $0.subelements }
			.flatMap { $0.subelements }
			.map { $0.key }
			.map(getFieldViewModelIndexPathPair)
	}

	public func update(pair: FieldValueCompletePair) {
		guard
			let step = model.subelements.get(at: Int(pair.indexPath.stepIndex)),
			let section = step.subelements.get(at: Int(pair.indexPath.sectionIndex)),
			let field = section.subelements.get(at: Int(pair.indexPath.fieldIndex))
			else { return }
		field.updateValueAndApplyActions(with: pair.fieldValue, in: storage)
	}

	public var wsPlist: PropertyList? {
		return model.subelements
			.flatMap { $0.subelements }
			.flatMap { $0.subelements }
			.mapSome { $0.getWSPlist(in: storage) }
			.accumulate { $0.compose($1) }
	}

	fileprivate func getFieldViewModelIndexPathPair(at key: FieldKey) -> FieldViewModelPair {
		return Writer<FormModel,FieldIndexPath>(model)
			.flatMap(Use(FormModel.getSubelement).with(key))
			.flatMap(Use(FormStepModel.getSubelement).with(key))
			.flatMap(Use(FormSectionModel.getSubelement).with(key))
			.map(Use(Field.getViewModel).with(storage))
			.run
	}
}

extension Form: EmptyType {
	public static var empty: Form {
		return Form(storage: FormStorage(), model: FormModel.empty)
	}
}
