import Functional

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
		return FieldRule {
			guard $0.0 != nil else {
				return FieldConformance.invalid(message: message)
			}
			return FieldConformance.valid
		}
	}
}

extension FieldRule: Monoid {
	public static var empty: FieldRule<Value> {
		return FieldRule { _ in .empty }
	}

	public func compose(_ other: FieldRule<Value>) -> FieldRule<Value> {
		return FieldRule {
			self.isValid(value: $0, storage: $1).compose(other.isValid(value: $0, storage: $1))
		}
	}
}
