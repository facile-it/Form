import FunctionalKit
import Abstract

import Signals

public final class FormStorage {
	public typealias EmittedType = FieldKey

	private let variableFieldKey = Emitter<FieldKey>()
	public private(set) var observableFieldKey = AnyObservable(Emitter<FieldKey>())

	fileprivate var fieldValues: [FieldKey:FieldValue] = [:]
	fileprivate var fieldOptions: [FieldKey:Any] = [:]
	fileprivate var hiddenFieldKeys: Set<FieldKey> = []

	public init() {
        self.observableFieldKey = AnyObservable(self.variableFieldKey)
    }

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
			variableFieldKey.update(key)
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
			variableFieldKey.update(key)
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
			variableFieldKey.update(key)
		}
	}

	public func getHidden(at key: FieldKey) -> Bool {
		return hiddenFieldKeys.contains(key)
	}

	public func notify(at key: FieldKey) {
		variableFieldKey.update(key)
	}

	public func clear() {
		let keys = Set(fieldValues.keys).union(hiddenFieldKeys)
		fieldValues.removeAll()
		hiddenFieldKeys.removeAll()
		keys.forEach { variableFieldKey.update($0) }
	}

	public func hasSameFieldValuesAndHiddenFieldKeys(of other: FormStorage) -> Bool {
		guard Array.init(fieldValues.keys) == Array.init(other.fieldValues.keys) else { return false }
		guard hiddenFieldKeys == other.hiddenFieldKeys else { return false }

		let a = fieldValues
		let b = other.fieldValues

		guard a.count == b.count else { return false }

		for (key,value) in a {
			guard let otherValue = b[key] else { return false }
			guard value.isEqual(to: otherValue) else { return false }
		}

		return true
	}
}


