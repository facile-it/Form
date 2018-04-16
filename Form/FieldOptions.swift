import FunctionalKit
import Abstract


public typealias FieldOptionsStyle = FieldStyle<
	FieldOptionsFixed,
	FieldOptionsSwitch,
	FieldOptionsText,
	FieldOptionsDate,
	FieldOptionsIntPicker,
	FieldOptionsStringPicker,
	FieldOptionsAnyPicker,
	FieldOptionsCustom
>

public protocol FieldOptions {
	associatedtype ValueType: FieldValue

	var style: FieldOptionsStyle { get }
	static func sanitizeValue(for storageValue: FieldValue) -> ValueType?
}

extension FieldOptions {
	public static func sanitizeValue(for storageValue: FieldValue) -> ValueType? {
		return storageValue as? ValueType
	}
}

extension FieldOptions where ValueType == AnyFieldValue {
	public static func sanitizeValue(for storageValue: FieldValue) -> AnyFieldValue? {
		if let value = storageValue as? AnyFieldValue {
			return value
		} else {
			return AnyFieldValue(storageValue)
		}
	}
}

public protocol FieldOptionsPicker: FieldOptions {
	var possibleValues: [(ValueType,CustomStringConvertible)] { get }
}

public struct FieldOptionsFixed: FieldOptions {
	public typealias ValueType = String

	public let text: String
	public init(text: String) {
		self.text = text
	}

	public var style: FieldOptionsStyle {
		return .fixed(self)
	}
}

public struct FieldOptionsSwitch: FieldOptions {
	public typealias ValueType = Bool

	public let getDescription: (Bool) -> String?

	public init(getDescription: @escaping (Bool) -> String?) {
		self.getDescription = getDescription
	}

	public var style: FieldOptionsStyle {
		return .onOff(self)
	}
}

public struct FieldOptionsText: FieldOptions {
	public typealias ValueType = String

	public let placeholder: String?
	public let keyboardType: KeyboardType

	public init(placeholder: String?, keyboardType: KeyboardType) {
		self.placeholder = placeholder
		self.keyboardType = keyboardType
	}

	public var style: FieldOptionsStyle {
		return .textEntry(self)
	}
}

public struct FieldOptionsDate: FieldOptions {
	public typealias ValueType = Date

	public let possibleValues: DateRange
	public let formatter: (Date) -> String

	public init(possibleValues: DateRange, formatter: @escaping (Date) -> String) {
		self.possibleValues = possibleValues
		self.formatter = formatter
	}

	public var style: FieldOptionsStyle {
		return .datePicker(self)
	}
}

public struct FieldOptionsIntPicker: FieldOptionsPicker {
	public typealias ValueType = Int

	public let possibleValues: [(Int,CustomStringConvertible)]

	public init(possibleValues: [(Int,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public var style: FieldOptionsStyle {
		return .intPicker(self)
	}
}

public struct FieldOptionsStringPicker: FieldOptionsPicker {
	public typealias ValueType = String

	public let possibleValues: [(String,CustomStringConvertible)]

	public init(possibleValues: [(String,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public var style: FieldOptionsStyle {
		return .stringPicker(self)
	}
}

public struct FieldOptionsAnyPicker: FieldOptionsPicker {
	public typealias ValueType = AnyFieldValue

	public let possibleValues: [(AnyFieldValue,CustomStringConvertible)]

	public init(possibleValues: [(AnyFieldValue,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public var style: FieldOptionsStyle {
		return .anyPicker(self)
	}
}

public struct FieldOptionsCustom: FieldOptions {
	public typealias ValueType = AnyFieldValue

	public let identifier: String
	public let valueDescription: (AnyFieldValue?) -> String

	public init(identifier: String, valueDescription: @escaping (AnyFieldValue?) -> String = { ($0?.get).map { "\($0)"} ?? "" }) {
		self.identifier = identifier
		self.valueDescription = valueDescription
	}

	public var style: FieldOptionsStyle {
		return .custom(self)
	}
}
