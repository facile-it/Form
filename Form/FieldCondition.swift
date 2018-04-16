import FunctionalKit
import Abstract


public struct FieldCondition<Value: FieldValue> {
	let predicate: (Value?,FormStorage) -> Bool

	public init(predicate: @escaping (Value?,FormStorage) -> Bool) {
		self.predicate = predicate
	}

	public func check(value: FieldValue?, storage: FormStorage) -> Bool {
        guard let value1 = value else { return predicate(nil, storage) }
		guard let value2 = value1 as? Value else { return false }
		return predicate(value2,storage)
	}
}

extension FieldCondition: Monoid {
	public static var empty: FieldCondition {
		return FieldCondition { _,_  in true }
	}

	public static func <> (left: FieldCondition, right: FieldCondition) -> FieldCondition {
		return FieldCondition { value, storage in
			left.check(value: value, storage: storage)
				&& right.check(value: value, storage: storage)
		}
	}
}

extension FieldCondition {
	public func and(_ other: FieldCondition) -> FieldCondition {
		return FieldCondition { value, storage in
			self.check(value: value, storage: storage)
				&& other.check(value: value, storage: storage)
		}
	}

	public func or(_ other: FieldCondition) -> FieldCondition {
		return FieldCondition { value, storage in
			self.check(value: value, storage: storage)
				|| other.check(value: value, storage: storage)
		}
	}
}

extension FieldCondition where Value: Equatable {
	public static func valueIs(equalTo otherValue: Value?) -> FieldCondition {
		return FieldCondition { (value, _) in value == otherValue }
	}

	public static func valueIs(containedIn options: [Value]) -> FieldCondition {
		return FieldCondition { (value, _) in value.map(options.contains).get(or: false) }
	}

	public static func valueIs(differentFrom otherValue: Value?) -> FieldCondition {
		return FieldCondition { (value, _) in value != otherValue }
	}

	public static func valueIs(notContainedIn options: [Value]) -> FieldCondition {
		return FieldCondition { (value, _) in value.map(options.contains).map { $0.not }.get(or: true) }
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

public typealias If<Value: FieldValue> = FieldCondition<Value>

extension FieldCondition {
	public func run(ifTrue actionsTrue: [FieldAction<Value>], ifFalse actionsFalse: [FieldAction<Value>]) -> FieldAction<Value> {
		return FieldAction<Value> { value, storage in
			if self.predicate(value,storage) {
				actionsTrue.concatenated.apply(value: value, storage: storage)
			} else {
				actionsFalse.concatenated.apply(value: value, storage: storage)
			}
		}
	}

	public func run(ifTrue actionTrue: FieldAction<Value>, ifFalse actionFalse: FieldAction<Value>) -> FieldAction<Value> {
		return run(ifTrue: [actionTrue], ifFalse: [actionFalse])
	}

	public func ifTrue(_ actions: FieldAction<Value>...) -> FieldAction<Value> {
		return run(ifTrue: actions.concatenated, ifFalse: .empty)
	}

	public func ifFalse(_ actions: FieldAction<Value>...) -> FieldAction<Value> {
		return run(ifTrue: .empty, ifFalse: actions.concatenated)
	}
}
