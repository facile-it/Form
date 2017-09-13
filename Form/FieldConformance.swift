import Functional
import Abstract
import Monads

public struct FieldConformance {
	public let isValid: Bool
	public let invalidMessages: [String]

	public static var valid: FieldConformance {
		return FieldConformance(isValid: true, invalidMessages: [])
	}

	public static func invalid(message: String) -> FieldConformance {
		return FieldConformance(isValid: false, invalidMessages: [message])
	}
}

extension FieldConformance: Equatable {}

public func == (lhs: FieldConformance, rhs: FieldConformance) -> Bool {
	return lhs.isValid == rhs.isValid
		&& lhs.invalidMessages == rhs.invalidMessages
}

extension FieldConformance: Monoid {
	public static var empty: FieldConformance {
		return FieldConformance(isValid: true, invalidMessages: [])
	}

	public static func <> (left: FieldConformance, right: FieldConformance) -> FieldConformance {
		return FieldConformance(
			isValid: left.isValid && right.isValid,
			invalidMessages: left.invalidMessages + right.invalidMessages)
	}
}
