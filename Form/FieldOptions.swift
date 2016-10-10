public protocol FieldOptionsType {
	associatedtype FieldValueType
}

public struct FieldOptionsFixed: FieldOptionsType {
	public typealias FieldValueType = String

	public let text: String
	public init(text: String) {
		self.text = text
	}
}

public struct FieldOptionsSwitch: FieldOptionsType {
	public typealias FieldValueType = Bool

	public let getDescription: (Bool) -> String?

	public init(getDescription: @escaping (Bool) -> String?) {
		self.getDescription = getDescription
	}
}

public struct FieldOptionsText: FieldOptionsType {
	public typealias FieldValueType = String

	public let placeholder: String?
	public let keyboardType: KeyboardType

	public init(placeholder: String?, keyboardType: KeyboardType) {
		self.placeholder = placeholder
		self.keyboardType = keyboardType
	}
}

public struct FieldOptionsDate: FieldOptionsType {
	public typealias FieldValueType = Date

	public let possibleValues: DateRange
	public let formatter: (Date) -> String

	public init(possibleValue: DateRange, formatter: @escaping (Date) -> String) {
		self.possibleValues = possibleValue
		self.formatter = formatter
	}
}

public struct FieldOptionsPicker<FieldValue>: FieldOptionsType {
	public typealias FieldValueType = FieldValue

	public let possibleValues: [(FieldValue,CustomStringConvertible)]

	public init(possibleValues: [(FieldValue,CustomStringConvertible)]) {
		self.possibleValues = possibleValues
	}
}
