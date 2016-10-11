public struct FieldRule<Value> {
	public typealias FieldValueType = Value

	private let validation: (Value?,FormStorage) -> FieldConformance

	public init(validation: @escaping (Value?,FormStorage) -> FieldConformance) {
		self.validation = validation
	}

	public func isValid(value: Any?, storage: FormStorage) -> FieldConformance {
		guard let validValue = value as? Value else { return FieldConformance.invalid(message: "invalid value: \(value)") }
		return validation(validValue,storage)
	}
}

extension FieldRule {
	public static func nonNil(message: String) -> FieldRule {
		return FieldRule {
			guard $0.0 != nil else {
				return FieldConformance.invalid(message: message)
			}
			return FieldConformance.valid
		}
	}
}
