import Functional

public struct FieldModel<Options: FieldOptions>: FieldKeyOwnerType, EmptyType {
	public typealias ValueType = Options.ValueType

	public let key: FieldKey
	public let config: FieldConfig<Options>
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let serialization: FieldSerialization<ValueType>

	public func getWSPlist(in storage: FormStorage) -> PropertyList? {
		return serialization.getWSPlist(for: key, in: storage)
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModel {
		return config.getViewModel(for: key, in: storage)
	}

	public func updateValueAndApplyActions(with value: Any?, in storage: FormStorage) {
		if let value = value as? ValueType {
			storage.set(value: value, at: key)
			actions.composeAll.apply(value: value, storage: storage)
		} else {
			storage.set(value: nil, at: key)
			actions.composeAll.apply(value: nil, storage: storage)
		}
	}

	public static var empty: FieldModel<Options> {
		return FieldModel(
			key: "",
			config: FieldConfig(
				title: "",
				options: Options.empty),
			rules: [],
			actions: [],
			serialization: FieldSerialization(
				visibility: .never,
				strategy: .direct("")))
	}
}
