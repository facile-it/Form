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

extension Int: FieldValue {
	public var optionalBool: Bool? {
		return nil
	}
	
	public var hashable: AnyHashable {
		return AnyHashable(self)
	}
	
	public var optionalString: String? {
		return nil
	}
	
	public var optionalWSObject: Any? {
		return self
	}

	public var optionalInt: Int? {
		return self
	}
}

extension String: FieldValue {
	public var optionalInt: Int? {
		return nil
	}
	
	public var hashable: AnyHashable {
		return AnyHashable(self)
	}
	
	public var optionalBool: Bool? {
		return nil
	}
	
	public var optionalWSObject: Any? {
		return self
	}
	
	public var optionalString: String? {
		return self
	}
}

extension Bool: FieldValue {
	public var hashable: AnyHashable {
		return AnyHashable(self)
	}
	
	public var optionalBool: Bool? {
		return self
	}
	
	public var optionalWSObject: Any? {
		return self
	}
	
	public var optionalString: String? {
		return nil
	}
	
	public var optionalInt: Int? {
		return nil
	}
}
