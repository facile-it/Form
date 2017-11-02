import Functional
import Abstract
import Monads

public struct FieldRule<Value> {
	private let validation: (Value?,FormStorage) -> FieldConformance

	public init(validation: @escaping (Value?,FormStorage) -> FieldConformance) {
		self.validation = validation
	}

	public func isValid(value: Value?, storage: FormStorage) -> FieldConformance {
		return validation(value,storage)
	}
}

extension FieldRule {
	public static func nonNil(message: String) -> FieldRule {
		return FieldRule { value, _ in
			guard value != nil else {
				return FieldConformance.invalid(message: message)
			}
			return FieldConformance.valid
		}
	}
}

extension FieldRule: Monoid {
	public static var empty: FieldRule<Value> {
		return FieldRule { _,_  in .empty }
	}

	public static func <> (left: FieldRule<Value>, right: FieldRule<Value>) -> FieldRule<Value> {
		return FieldRule {
			left.isValid(value: $0, storage: $1) <> right.isValid(value: $0, storage: $1)
		}
	}
}
