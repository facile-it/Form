public protocol FieldRuleType: FieldActivityType {
	func isValid(value: FieldValueType?, storage: FormStorage) -> FieldConformance
}

public struct FieldRule<FieldValue>: FieldRuleType {
	public typealias FieldValueType = FieldValue

	private let validation: (FieldValue?,FormStorage) -> FieldConformance

	public init(validation: @escaping (FieldValue?,FormStorage) -> FieldConformance) {
		self.validation = validation
	}

	public func isValid(value: FieldValue?, storage: FormStorage) -> FieldConformance {
		return validation(value,storage)
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
