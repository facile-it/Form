import NetworkingKit

public protocol JSONObjectConvertible {
	var jsonObject: JSONObject { get }
}

public protocol AnyHashableConvertible {
	var anyHashable: AnyHashable { get }
}

public protocol FieldValue: CustomStringConvertible, JSONObjectConvertible, AnyHashableConvertible {}

extension FieldValue {
	public func isEqual(to other: FieldValue) -> Bool {
		return self.jsonObject == other.jsonObject && self.anyHashable == other.anyHashable
	}
}

extension FieldValue where Self: Hashable {
	public var anyHashable: AnyHashable {
		return AnyHashable(self)
	}
}

extension Int: FieldValue {
	public var jsonObject: JSONObject {
		return .number(self)
	}
}

extension String: FieldValue {
	public var jsonObject: JSONObject {
		return .string(self)
	}
}

extension Bool: FieldValue {
	public var jsonObject: JSONObject {
		return .bool(self)
	}
}

extension Date: FieldValue {
	public var jsonObject: JSONObject {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMddHHmmss"
		return JSONObject.string(formatter.string(from: self))
	}
}

public struct AnyFieldValue: FieldValue {
	public let get: FieldValue
	public init(_ value: FieldValue) {
		self.get = value
	}

	public var description: String {
		return get.description
	}

	public var jsonObject: JSONObject {
		return get.jsonObject
	}

	public var anyHashable: AnyHashable {
		return get.anyHashable
	}
}
