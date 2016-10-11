import Functional

public struct FieldCondition<Value> {
	fileprivate let predicate: (Value?,FormStorage) -> Bool

	public init(predicate: @escaping (Value?,FormStorage) -> Bool) {
		self.predicate = predicate
	}

	public func check(value: Any?, storage: FormStorage) -> Bool {
		guard let value = value as? Value else { return false }
		return predicate(value,storage)
	}
}

extension FieldCondition: Monoid {
	public static var empty: FieldCondition {
		return FieldCondition { _ in true }
	}

	public func compose(_ other: FieldCondition) -> FieldCondition {
		return FieldCondition {
			self.check(value: $0.0, storage: $0.1) && other.check(value: $0.0, storage: $0.1)
		}
	}
}

extension FieldCondition {
	func and(_ other: FieldCondition) -> FieldCondition {
		return compose(other)
	}
}

extension FieldCondition where Value: Equatable {
	public static func valueIs(equal toValue: Value?) -> FieldCondition {
		return FieldCondition { (value, _) in value == toValue }
	}

	public static func otherValue(at key: FieldKey, isEqual toValue: Value?) -> FieldCondition {
		return FieldCondition { (_, storage) in
			let optionalStorageValue = storage.getValue(at: key)
			guard toValue != nil else {
				return optionalStorageValue == nil
			}
			guard let value = optionalStorageValue as? Value else {
				return false
			}
			return value == toValue
		}
	}
}

/// FieldAction related methods
extension FieldCondition {
	public func runCondition(ifTrue actionTrue: FieldAction<Value>, ifFalse actionFalse: FieldAction<Value>) -> FieldAction<Value> {
		return FieldAction<Value> {
			if self.predicate($0.0,$0.1) {
				actionTrue.apply(value: $0.0, storage: $0.1)
			} else {
				actionFalse.apply(value: $0.0, storage: $0.1)
			}
		}
	}

	public func ifTrue(_ action: FieldAction<Value>) -> FieldAction<Value> {
		return runCondition(ifTrue: action, ifFalse: FieldAction<Value>.empty)
	}

	public func ifFalse(_ action: FieldAction<Value>) -> FieldAction<Value> {
		return runCondition(ifTrue: FieldAction<Value>.empty, ifFalse: action)
	}
}
