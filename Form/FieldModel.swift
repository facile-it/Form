import Functional

public struct FieldModel<FieldConfig: FieldConfigType>: FieldKeyOwnerType {
	typealias ValueType = FieldConfig.OptionsType.FieldValueType

	public let key: FieldKey
	public let config: FieldConfig
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let serialization: FieldSerialization<ValueType>

	fileprivate func updateValueAndApplyActions(with value: Any?, in storage: FormStorage) {
		if let value = value as? ValueType {
			storage.set(value: value, at: key)
			actions.composeAll.apply(value: value, storage: storage)
		} else {
			storage.set(value: nil, at: key)
			actions.composeAll.apply(value: nil, storage: storage)
		}
	}
}

public enum Field {
	case fixed(FieldModel<FieldConfig<FieldOptionsFixed>>)
	case onOff(FieldModel<FieldConfig<FieldOptionsSwitch>>)
	case textEntry(FieldModel<FieldConfig<FieldOptionsText>>)
	case datePicker(FieldModel<FieldConfig<FieldOptionsDate>>)
	case intPicker(FieldModel<FieldConfig<FieldOptionsPicker<Int>>>)
	case stringPicker(FieldModel<FieldConfig<FieldOptionsPicker<String>>>)
	case anyPicker(FieldModel<FieldConfig<FieldOptionsPicker<AnyHashable>>>)

	public func getWSPlist(in storage: FormStorage) -> PropertyList? {
		switch self {
		case let .fixed(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .onOff(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .textEntry(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .datePicker(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .intPicker(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .stringPicker(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		case let .anyPicker(model):
			return model.serialization.getWSPlist(for: key, in: storage)
		}
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModelType {
		switch self {
		case let .fixed(model):
			return .fixed(model.config.getViewModel(for: key, in: storage))
		case let .onOff(model):
			return .onOff(model.config.getViewModel(for: key, in: storage))
		case let .textEntry(model):
			return .textEntry(model.config.getViewModel(for: key, in: storage))
		case let .datePicker(model):
			return .datePicker(model.config.getViewModel(for: key, in: storage))
		case let .intPicker(model):
			return .intPicker(model.config.getViewModel(for: key, in: storage))
		case let .stringPicker(model):
			return .stringPicker(model.config.getViewModel(for: key, in: storage))
		case let .anyPicker(model):
			return .anyPicker(model.config.getViewModel(for: key, in: storage))
		}
	}

	public func updateValueAndApplyActions(with value: Any?, in storage: FormStorage) {
		switch self {
		case let .fixed(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .onOff(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .textEntry(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .datePicker(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .intPicker(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .stringPicker(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case let .anyPicker(model):
			model.updateValueAndApplyActions(with: value, in: storage)
		}
	}
}

extension Field: FieldKeyOwnerType {
	public var key: FieldKey {
		switch self {
		case let .fixed(model):
			return model.key
		case let .onOff(model):
			return model.key
		case let .textEntry(model):
			return model.key
		case let .datePicker(model):
			return model.key
		case let .intPicker(model):
			return model.key
		case let .stringPicker(model):
			return model.key
		case let .anyPicker(model):
			return model.key
		}
	}
}

extension Field: EmptyType {
	public static var empty: Field {
		return .fixed(FieldModel(
			key: "",
			config: FieldConfig(
				title: "",
				options: FieldOptionsFixed(text: "")),
			rules: [],
			actions: [],
			serialization: FieldSerialization(
				visibility: .never,
				strategy: .direct(""))))
	}
}

//struct Ciccio {
//	let x = FieldModel(
//		key: "key_local",
//		config: FieldConfig(
//			title: "field_title",
//			options: FieldOptionsSwitch { $0.analyze(
//				ifTrue: "si",
//				ifFalse: "no") }),
//		rules: [.nonNil(message: "should not be nil"),
//		        .shouldBeTrue(message: "should be true")],
//		actions: [.set(value: 3, at: "ciccio"),
//		          FieldCondition.valueIs(equal: true).runCondition(
//					ifTrue: .hideField(at: "pluto"),
//					ifFalse: .showField(at: "pluto"))],
//		serialization: FieldSerialization(
//			visibility: .always,
//			strategy: .simple(FieldWSRelation(key: "key_ws") { $0.analyze(
//				ifTrue: "Y",
//				ifFalse: "N") })))
//}
//
//extension FieldRuleType where FieldValueType == Bool {
//	static func shouldBeTrue(message: String) -> FieldRule<Bool> {
//		return FieldRule { $0.0.getOrElse(false).analyze(
//			ifTrue: .valid,
//			ifFalse: .invalid(message: message)) }
//	}
//}
