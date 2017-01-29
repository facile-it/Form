import JSONObject

public protocol JSONObjectConvertible {
	var jsonObject: JSONObject { get }
}

public protocol AnyHashableConvertible {
	var hashable: AnyHashable { get }
}

public protocol FieldValue: JSONObjectConvertible, AnyHashableConvertible {}

extension FieldValue {
	public func isEqual(to other: FieldValue) -> Bool {
		return self.jsonObject == other.jsonObject && self.hashable == other.hashable
	}
}

extension FieldValue where Self: Hashable {
	public var hashable: AnyHashable {
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
	public var jsonObject: JSONObject {
		return get.jsonObject
	}

	public var hashable: AnyHashable {
		return get.hashable
	}
}
