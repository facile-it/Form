import FunctionalKit
import Abstract


public struct FieldAction<Value: FieldValue> {
	private let transform: (Value?,FormStorage) -> ()

	public init(transform: @escaping (Value?,FormStorage) -> ()) {
		self.transform = transform
	}

	public func apply(value: Value?, storage: FormStorage) {
		transform(value,storage)
	}
}

extension FieldAction: Monoid {
	public static var empty: FieldAction {
		return FieldAction { _,_  in }
	}

	public static func <> (left: FieldAction, right: FieldAction) -> FieldAction {
		return FieldAction { value, storage in
			left.apply(value: value, storage: storage)
			right.apply(value: value, storage: storage)
		}
	}
}

extension FieldAction {
	public func and(_ other: FieldAction) -> FieldAction {
		return self <> other
	}
}

extension FieldAction {
	public static func updateField(at key: FieldKey) -> FieldAction {
		return FieldAction { (value, storage) in
			storage.set(value: value, at: key)
		}
	}

	public static func set(value: FieldValue?, at key: FieldKey) -> FieldAction {
		return FieldAction { (_, storage) in
			storage.set(value: value, at: key)
		}
	}

	public static func removeValueForField(at key: FieldKey) -> FieldAction {
		return set(value: nil, at: key)
	}

	public static func hideField(at key: FieldKey) -> FieldAction {
		return FieldAction { (_, storage) in
			storage.set(hidden: true, at: key)
		}
	}

	public static func showField(at key: FieldKey) -> FieldAction {
		return FieldAction { (_, storage) in
			storage.set(hidden: false, at: key)
		}
	}

	public static func removeValueAndHideField(at key: FieldKey) -> FieldAction {
		return [removeValueForField(at: key),hideField(at: key)].concatenated()
	}

	public static func notify(at key: FieldKey) -> FieldAction {
		return FieldAction { (_, storage) in
			storage.notify(at: key)
		}
	}
}
