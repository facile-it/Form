import Functional

public typealias FieldViewModelPair = (viewModel: FieldViewModel, indexPath: FieldIndexPath)
public typealias FieldValueCompletePair = (fieldValue: FieldValue?, indexPath: FieldIndexPathComplete)

public final class Form: EmitterMapperType {
	public typealias ObservedType = FieldKey
	public typealias EmittedType = FieldViewModelPair

	private let model: FormModel
	private let storage: FormStorage
	public var identifier: String {
		return model.configuration.title.getOrEmpty
	}

	public var weakObservers: [AnyWeakObserver<FieldViewModelPair>] = []
	public var mappingFunction: (String) -> FieldViewModelPair {
		return getFieldViewModelIndexPathPair
	}

	public init(model: FormModel, storage: FormStorage) {
		self.model = model
		self.storage = storage
		storage.addObserver(self)
	}

	public var allPairs: [FieldViewModelPair] {
		return storage.allKeys.map(getFieldViewModelIndexPathPair)
	}

	public var wsPlist: PropertyList? {
		return model.subelements
			.flatMap { $0.subelements }
			.flatMap { $0.subelements }
			.mapSome { $0.getWSPlist(in: storage) }
			.accumulate { $0.compose($1) }
	}

	public func editStorage(with transform: (FormStorage) -> ()) {
		transform(storage)
	}

	public func update(pair: FieldValueCompletePair) {
		guard
			let step = model.subelements.get(at: Int(pair.indexPath.stepIndex)),
			let section = step.subelements.get(at: Int(pair.indexPath.sectionIndex)),
			let field = section.subelements.get(at: Int(pair.indexPath.fieldIndex))
			else { return }
			field.updateValueAndApplyActions(with: pair.fieldValue, in: storage)
	}

	fileprivate func getFieldViewModelIndexPathPair(at key: FieldKey) -> FieldViewModelPair {
		return Writer<FormModel,FieldIndexPath>(model)
			.flatMap(Use(FormModel.getSubelement).with(key))
			.flatMap(Use(FormStepModel.getSubelement).with(key))
			.flatMap(Use(FormSectionModel.getSubelement).with(key))
			.map(Use(Field.getViewModel).with(storage))
			.runWriter
	}
}
