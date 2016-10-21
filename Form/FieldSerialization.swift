import Foundation
import Functional

public struct WSRelation<RootValue,WSKey: Hashable,WSObject> {
	private let key: WSKey
	private let getObject: (RootValue) -> WSObject?

	public init(key: WSKey, getObject: @escaping (RootValue) -> WSObject?) {
		self.key = key
		self.getObject = getObject
	}

	public func getPlist(for value: RootValue) -> [WSKey:WSObject]? {
		return getObject(value).map { [key : $0] }
	}
}

public typealias FieldWSRelation<Value> = WSRelation<Value,String,Any>

public enum FieldSerializationCondition {
	case never
	case ifVisible
	case always
}

public enum FieldSerializationStrategy<Value>: EmptyType {
	case direct(FieldKey)
	case single(FieldWSRelation<Value>)
	case multiple([FieldWSRelation<Value>])
//	case path([String],FieldWSRelation<Value>)

	public static var empty: FieldSerializationStrategy<Value> {
		return .direct(FieldKey.empty)
	}
}

public struct FieldSerialization<Value>: EmptyType {

	private let condition: FieldSerializationCondition
	private let strategy: FieldSerializationStrategy<Value>

	public init(condition: FieldSerializationCondition, strategy: FieldSerializationStrategy<Value>) {
		self.condition = condition
		self.strategy = strategy
	}

	public func getWSPlist(for key: FieldKey, in storage: FormStorage, considering checkValue: (Any) -> Value?) -> PropertyList? {
		guard condition != .never else { return nil }

		let visible = storage.getHidden(at: key).inverse

		guard visible == true || condition != .ifVisible else { return nil }

		guard let value = storage.getValue(at: key).flatMap(checkValue) else { return nil }

		switch strategy {
		case let .direct(key):
			return [key: value]
		case let .single(relation):
			return relation.getPlist(for: value)
		case let .multiple(relations):
			return relations.mapSome(Use(WSRelation.getPlist).with(value)).composeAll
		}
	}

	public static func simple(key: FieldKey) -> FieldSerialization<Value> {
		return FieldSerialization(
			condition: .ifVisible,
			strategy: .direct(key))
	}

	public static var empty: FieldSerialization<Value> {
		return FieldSerialization(
			condition: .never,
			strategy: .empty)
	}
}
