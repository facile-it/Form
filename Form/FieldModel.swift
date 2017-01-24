import Functional
import JSONObject

public struct FieldModel<Options: FieldOptions>: FieldKeyOwnerType, EmptyConstructible {
	public typealias ValueType = Options.ValueType

	public let key: FieldKey
	public let config: FieldConfig<Options>
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let serialization: FieldSerialization<ValueType>

	public init(key: FieldKey, config: FieldConfig<Options>, rules: [FieldRule<ValueType>], actions: [FieldAction<ValueType>], serialization: FieldSerialization<ValueType>) {
		self.key = key
		self.config = config
		self.rules = rules
		self.actions = actions
		self.serialization = serialization
	}

	public func getJSONObject(in storage: FormStorage) -> JSONObject? {
		return serialization.getJSONObject(for: key, in: storage, considering: Options.sanitizeValue)
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModel {
		return config.getViewModel(for: key, in: storage, rules: rules)
	}

	public func updateValueAndApplyActions(with value: FieldValue?, in storage: FormStorage) {
		storage.set(value: value, at: key)
		actions.joinAll().apply(value: value.flatMap(Options.sanitizeValue), storage: storage)
	}

	public static var empty: FieldModel<Options> {
		return FieldModel(
			key: "",
			config: FieldConfig(
				title: "",
				options: Options.empty),
			rules: [],
			actions: [],
			serialization: FieldSerialization.empty)
	}
}
