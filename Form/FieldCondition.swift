import Functional

public protocol FieldConditionType: FieldActivityType {
	func check(value: FieldValueType?, storage: FormStorage) -> Bool
}

public struct FieldCondition<FieldValue>: FieldConditionType {
	public typealias FieldValueType = FieldValue
	
	fileprivate let predicate: (FieldValue?,FormStorage) -> Bool

	public init(predicate: @escaping (FieldValue?,FormStorage) -> Bool) {
		self.predicate = predicate
	}

	public func check(value: FieldValue?, storage: FormStorage) -> Bool {
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

extension FieldCondition where FieldValue: Equatable {
	public static func valueIs(equal toValue: FieldValue?) -> FieldCondition {
		return FieldCondition { (value, _) in value == toValue }
	}

	public static func otherValue(at key: FieldKey, isEqual toValue: FieldValue?) -> FieldCondition {
		return FieldCondition { (_, storage) in
			let optionalStorageValue = storage.getValue(at: key)
			guard toValue != nil else {
				return optionalStorageValue == nil
			}
			guard let value = optionalStorageValue as? FieldValue else {
				return false
			}
			return value == toValue
		}
	}
}

/// FieldAction related methods
extension FieldCondition {
	public func runCondition(ifTrue actionTrue: FieldAction<FieldValue>, ifFalse actionFalse: FieldAction<FieldValue>) -> FieldAction<FieldValue> {
		return FieldAction<FieldValue> {
			if self.predicate($0.0,$0.1) {
				actionTrue.apply(value: $0.0, storage: $0.1)
			} else {
				actionFalse.apply(value: $0.0, storage: $0.1)
			}
		}
	}

	public func ifTrue(_ action: FieldAction<FieldValue>) -> FieldAction<FieldValue> {
		return runCondition(ifTrue: action, ifFalse: FieldAction<FieldValue>.empty)
	}

	public func ifFalse(_ action: FieldAction<FieldValue>) -> FieldAction<FieldValue> {
		return runCondition(ifTrue: FieldAction<FieldValue>.empty, ifFalse: action)
	}
}
