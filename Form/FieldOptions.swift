import Functional

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

public protocol FieldOptions: EmptyType {
	associatedtype ValueType

	var style: FieldOptionsStyle { get }
	static func checkValue(for storageValue: Any) -> ValueType?
}

extension FieldOptions {
	public static func checkValue(for storageValue: Any) -> ValueType? {
		return storageValue as? ValueType
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

	public init(possibleValues: DateRange, formatter: @escaping (Date) -> String) {
		self.possibleValues = possibleValues
		self.formatter = formatter
	}

	public static var empty: FieldOptionsDate {
		return FieldOptionsDate(possibleValues: DateRange(nil, nil), formatter: { _ in "" })
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

	public static var empty: FieldOptionsIntPicker {
		return FieldOptionsIntPicker(possibleValues: [])
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

	public static var empty: FieldOptionsStringPicker {
		return FieldOptionsStringPicker(possibleValues: [])
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

	public static var empty: FieldOptionsAnyPicker {
		return FieldOptionsAnyPicker(possibleValues: [])
	}

	public var style: FieldOptionsStyle {
		return .anyPicker(self)
	}

	public static func checkValue(for storageValue: Any) -> AnyFieldValue? {
		guard let fieldValue = storageValue as? FieldValue else { return nil }
		return AnyFieldValue(fieldValue)
	}
}

public struct FieldOptionsCustom: FieldOptions {
	public typealias ValueType = AnyFieldValue

	public let identifier: String
	public let valueDescription: (AnyFieldValue?) -> String

	public init(identifier: String, valueDescription: @escaping (AnyFieldValue?) -> String = { $0?.optionalString ?? "" }) {
		self.identifier = identifier
		self.valueDescription = valueDescription
	}

	public static var empty: FieldOptionsCustom {
		return FieldOptionsCustom(identifier: "")
	}

	public var style: FieldOptionsStyle {
		return .custom(self)
	}

	public static func checkValue(for storageValue: Any) -> AnyFieldValue? {
		guard let fieldValue = storageValue as? FieldValue else { return nil }
		return AnyFieldValue(fieldValue)
	}
}
