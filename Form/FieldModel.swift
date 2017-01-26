import Functional
import JSONObject

public struct FieldModel<Options: FieldOptions>: FieldKeyOwnerType {
	public typealias ValueType = Options.ValueType

	public let key: FieldKey
	public let config: FieldConfig<Options>
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let changes: [FieldChangeCondition<ValueType>]

	public init(key: FieldKey, config: FieldConfig<Options>, rules: [FieldRule<ValueType>], actions: [FieldAction<ValueType>], changes: [FieldChangeCondition<ValueType>]) {
		self.key = key
		self.config = config
		self.rules = rules
		self.actions = actions
		self.changes = changes
	}

	public func transform(object: Any, considering storage: FormStorage) -> Any {
		guard let value = storage.getValue(at: key) as? ValueType else { return object }
		return changes
			.filter {
				if case .ifVisible = $0 {
					return storage.getHidden(at: key).not
				} else {
					return true
				}
			}
			.map { $0.getChange }
			.joinAll()
			.apply(with: value, to: object)
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModel {
		return config.getViewModel(for: key, in: storage, rules: rules)
	}

	public func updateValueAndApplyActions(with value: FieldValue?, in storage: FormStorage) {
		storage.set(value: value, at: key)
		actions.joinAll().apply(value: value.flatMap(Options.sanitizeValue), storage: storage)
	}
}
