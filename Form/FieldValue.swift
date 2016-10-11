public protocol HasOptionalString {
	var optionalString: String? { get }
}

public protocol HasOptionalInt {
	var optionalInt: Int? { get }
}

public protocol HasOptionalBool {
	var optionalBool: Bool? { get }
}

public protocol HasOptionalWSObject {
	var optionalWSObject: Any? { get }
}

public protocol HasHashable {
	var hashable: AnyHashable { get }
}

public protocol FieldValue: HasOptionalString, HasOptionalInt, HasOptionalBool, HasOptionalWSObject, HasHashable {}
