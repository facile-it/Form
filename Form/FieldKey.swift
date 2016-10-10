public typealias FieldKey = String

public protocol FieldKeyOwnerType {
	var key: FieldKey { get }
}
