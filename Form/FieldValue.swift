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

extension Date: FieldValue {
	public var hashable: AnyHashable {
		return AnyHashable(self)
	}

	public var optionalBool: Bool? {
		return nil
	}

	public var optionalWSObject: Any? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMddHHmmss"
		return formatter.string(from: self)
	}

	public var optionalString: String? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMddHHmmss"
		return formatter.string(from: self)
	}

	public var optionalInt: Int? {
		return nil
	}
}

public struct AnyFieldValue: FieldValue {
	public let get: FieldValue
	public init(_ value: FieldValue) {
		self.get = value
	}

	public var hashable: AnyHashable {
		return get.hashable
	}

	public var optionalBool: Bool? {
		return get.optionalBool
	}

	public var optionalWSObject: Any? {
		return get.optionalWSObject
	}

	public var optionalString: String? {
		return get.optionalString
	}

	public var optionalInt: Int? {
		return get.optionalInt
	}
}
