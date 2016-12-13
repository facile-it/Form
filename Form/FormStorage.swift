import Functional

public final class FormStorage: WeakObserversCollectionEmitterType {
	public typealias EmittedType = FieldKey

	public var weakObservers: [AnyWeakObserver<FieldKey>] = []
	
	fileprivate var fieldValues: [FieldKey:FieldValue] = [:]
	fileprivate var fieldOptions: [FieldKey:Any] = [:]
	fileprivate var hiddenFieldKeys: Set<FieldKey> = []

	public init() {}

	public var allKeys: Set<FieldKey> {
		return Set(fieldValues.keys)
	}

	public func set(value: FieldValue?, at key: FieldKey) {
		let prevValue = fieldValues[key]
		switch (value, prevValue) {
		case (.none,.none):
			return
		case (.some(let value), .some(let prevValue)) where value.isEqual(to: prevValue):
			return
		default:
			fieldValues[key] = value
			send(key)
		}
	}

	public func getValue(at key: FieldKey) -> FieldValue? {
		return fieldValues[key]
	}

	public func set(options: Any?, at key: FieldKey) {
        let prevOption = fieldOptions[key]
        switch (options, prevOption) {
        case (.none,.none):
            return
        default:
            fieldOptions[key] = options
            send(key)
        }
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
			send(key)
		}
	}

	public func getHidden(at key: FieldKey) -> Bool {
		return hiddenFieldKeys.contains(key)
	}

	public func clear() {
		let keys = Set(fieldValues.keys).union(hiddenFieldKeys)
		fieldValues.removeAll()
		hiddenFieldKeys.removeAll()
		keys.forEach(send)
	}
}
