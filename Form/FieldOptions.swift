import Functional

public typealias FieldOptionsStyle = FieldStyle<
	FieldOptionsFixed,
	FieldOptionsSwitch,
	FieldOptionsText,
	FieldOptionsDate,
	FieldOptionsIntPicker,
	FieldOptionsStringPicker,
	FieldOptionsAnyPicker
>

public protocol FieldOptions: EmptyType {
	associatedtype ValueType

	var style: FieldOptionsStyle { get }
}

public struct FieldOptionsFixed: FieldOptions {
	public typealias ValueType = String

	public let text: String
	public init(text: String) {
		self.text = text
	}

	public static var empty: FieldOptionsFixed {
		return FieldOptionsFixed(text: "")
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

	public static var empty: FieldOptionsSwitch {
		return FieldOptionsSwitch { _ in nil }
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

	public static var empty: FieldOptionsText {
		return FieldOptionsText(placeholder: nil, keyboardType: .text)
	}

	public var style: FieldOptionsStyle {
		return .textEntry(self)
	}
}

public struct FieldOptionsDate: FieldOptions {
	public typealias ValueType = Date

	public let possibleValues: DateRange
	public let formatter: (Date) -> String

	public init(possibleValue: DateRange, formatter: @escaping (Date) -> String) {
		self.possibleValues = possibleValue
		self.formatter = formatter
	}

	public static var empty: FieldOptionsDate {
		return FieldOptionsDate(possibleValue: DateRange(nil, nil), formatter: { _ in "" })
	}

	public var style: FieldOptionsStyle {
		return .datePicker(self)
	}
}

public struct FieldOptionsIntPicker: FieldOptions {
	public typealias ValueType = Int

	public let possibleValues: [(Int,CustomStringConvertible)]

	public init(possibleValues: [(Int,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public static var empty: FieldOptionsIntPicker {
		return FieldOptionsIntPicker(possibleValues: [])
	}

	public var style: FieldOptionsStyle {
		return .intPicker(self)
	}
}

public struct FieldOptionsStringPicker: FieldOptions {
	public typealias ValueType = String

	public let possibleValues: [(String,CustomStringConvertible)]

	public init(possibleValues: [(String,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public static var empty: FieldOptionsStringPicker {
		return FieldOptionsStringPicker(possibleValues: [])
	}

	public var style: FieldOptionsStyle {
		return .stringPicker(self)
	}
}

public struct FieldOptionsAnyPicker: FieldOptions {
	public typealias ValueType = FieldValue

	public let possibleValues: [(FieldValue,CustomStringConvertible)]

	public init(possibleValues: [(FieldValue,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}

	public static var empty: FieldOptionsAnyPicker {
		return FieldOptionsAnyPicker(possibleValues: [])
	}

	public var style: FieldOptionsStyle {
		return .anyPicker(self)
	}
}
