import Functional
import JSONObject

public struct FieldModel<Options: FieldOptions>: FieldKeyOwnerType, EmptyConstructible {
	public typealias ValueType = Options.ValueType

	public let key: FieldKey
	public let config: FieldConfig<Options>
	public let changes: [AnyFieldChange<ValueType>]
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]

	public init(key: FieldKey, config: FieldConfig<Options>, changes: [AnyFieldChange<ValueType>], rules: [FieldRule<ValueType>], actions: [FieldAction<ValueType>]) {
		self.key = key
		self.config = config
		self.changes = changes
		self.rules = rules
		self.actions = actions
	}

	public func transform(object: Any, considering storage: FormStorage) -> Any {
		guard let value = storage.getValue(at: key) as? ValueType else { return object }
		return changes.joinAll().apply(with: value, to: object)
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
			changes: [],
			rules: [],
			actions: [])
	}
}
