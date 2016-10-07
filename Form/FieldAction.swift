import Functional

public protocol FieldActionType: FieldActivityType {
	init(transform: @escaping (FieldValueType?,FormStorage) -> ())
	func apply(value: FieldValueType?, storage: FormStorage)
}

public struct FieldAction<FieldValue>: FieldActionType {
	public typealias FieldValueType = FieldValue
	
	private let transform: (FieldValue?,FormStorage) -> ()

	public init(transform: @escaping (FieldValue?,FormStorage) -> ()) {
		self.transform = transform
	}

	public func apply(value: FieldValue?, storage: FormStorage) {
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

extension FieldActionType {
	public static func updateField(at key: FieldKey) -> FieldAction<FieldValueType> {
		return FieldAction { (value, storage) in
			storage.set(value: value, at: key)
		}
	}

	public static func set(value: Any?, at key: FieldKey) -> FieldAction<FieldValueType> {
		return FieldAction { (_, storage) in
			storage.set(value: value, at: key)
		}
	}

	public static func removeValueForField(at key: FieldKey) -> FieldAction<FieldValueType> {
		return set(value: nil, at: key)
	}

	public static func hideField(at key: FieldKey) -> FieldAction<FieldValueType> {
		return FieldAction { (_, storage) in
			storage.set(hidden: true, at: key)
		}
	}

	public static func showField(at key: FieldKey) -> FieldAction<FieldValueType> {
		return FieldAction { (_, storage) in
			storage.set(hidden: false, at: key)
		}
	}

	public static func removeValueAndHideField(at key: FieldKey) -> FieldAction<FieldValueType> {
		return [removeValueForField(at: key),hideField(at: key)].composeAll()
	}

	public static func notify(at key: FieldKey) -> FieldAction<FieldValueType> {
		return FieldAction { (_, storage) in
			storage.notify(at: key)
		}
	}
}
