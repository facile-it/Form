import Functional

public protocol FormStorageType {
	var allKeys: [FieldKey] { get }
	func set(value: Any?, at key: FieldKey)
	func getValue(at key: FieldKey) -> Any?
	func set(options: Any?, at key: FieldKey)
	func getOptions(at key: FieldKey) -> Any?
	func set(hidden: Bool, at key: FieldKey)
	func getHidden(at key: FieldKey) -> Bool
	func notify(at key: FieldKey)
	func clear()
}

public final class FormStorage: FormStorageType, WeakObserversCollectionEmitterType {
	public typealias EmittedType = FieldKey

	public var weakObservers: [AnyWeakObserver<FieldKey>] = []
	
	fileprivate var fieldValues: [FieldKey:Any] = [:]
	fileprivate var fieldOptions: [FieldKey:Any] = [:]
	fileprivate var hiddenFieldKeys: Set<FieldKey> = []

	public init() {}

	public var allKeys: [FieldKey] {
		return Array(fieldValues.keys)
	}

	public func set(value: Any?, at key: FieldKey) {
		fieldValues[key] = value
		notify(at: key)
	}

	public func getValue(at key: FieldKey) -> Any? {
		return fieldValues[key]
	}

	public func set(options: Any?, at key: FieldKey) {
		fieldOptions[key] = options
		notify(at: key)
	}

	public func getOptions(at key: FieldKey) -> Any? {
		return fieldOptions[key]
	}

	public func set(hidden: Bool, at key: FieldKey) {
		let shouldNotify = (hiddenFieldKeys.contains(key) != hidden)
		if hidden {
			hiddenFieldKeys.formUnion([key])
		} else {
			hiddenFieldKeys.remove(key)
		}
		if shouldNotify {
			notify(at: key)
		}
	}

	public func getHidden(at key: FieldKey) -> Bool {
		return hiddenFieldKeys.contains(key)
	}

	public func notify(at key: FieldKey) {
		weakObservers.forEach { $0.observe(key) }
	}

	public func clear() {
		let keys = Set(fieldValues.keys).union(hiddenFieldKeys)
		fieldValues.removeAll()
		hiddenFieldKeys.removeAll()
		keys.forEach(notify)
	}
}
