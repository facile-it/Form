import JSONObject

public protocol HasOptionalString {
	var optionalString: String? { get }
}

public protocol HasOptionalInt {
	var optionalInt: Int? { get }
}

public protocol HasOptionalBool {
	var optionalBool: Bool? { get }
}

public protocol HasOptionalJSONObject {
	var optionalJSONObject: JSONObject? { get }
}

public protocol HasHashable {
	var hashable: AnyHashable { get }
}

public protocol FieldValue: HasOptionalString, HasOptionalInt, HasOptionalBool, HasOptionalJSONObject, HasHashable {}

extension FieldValue {
	public func isEqual(to other: FieldValue) -> Bool {
		return optionalString == other.optionalString
			&& optionalInt == other.optionalInt
			&& optionalBool == other.optionalBool
			&& optionalJSONObject == other.optionalJSONObject
			&& hashable == other.hashable
	}
}

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
	
	public var optionalJSONObject: JSONObject? {
		return .number(self)
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
	
	public var optionalJSONObject: JSONObject? {
		return .string(self)
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
	
	public var optionalJSONObject: JSONObject? {
		return .bool(self)
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

	public var optionalJSONObject: JSONObject? {
		return optionalString.map(JSONObject.string)
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

	public var optionalJSONObject: JSONObject? {
		return get.optionalJSONObject
	}

	public var optionalString: String? {
		return get.optionalString
	}

	public var optionalInt: Int? {
		return get.optionalInt
	}
}
