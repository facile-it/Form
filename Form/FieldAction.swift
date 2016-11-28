import Functional

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
		return FieldAction { _ in }
	}

	public func compose(_ other: FieldAction) -> FieldAction {
		return FieldAction {
			self.apply(value: $0.0, storage: $0.1)
			other.apply(value: $0.0, storage: $0.1)
		}
	}
}

extension FieldAction {
	public func and(_ other: FieldAction) -> FieldAction {
		return compose(other)
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
		return [removeValueForField(at: key),hideField(at: key)].composeAll
	}

	public static func notify(at key: FieldKey) -> FieldAction {
		return FieldAction { (_, storage) in
			storage.notify(at: key)
		}
	}
}
