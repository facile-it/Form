import Foundation
import Functional

public struct WSRelation<RootValue,WSKey: Hashable,WSObject> {
	private let key: WSKey
	private let getObject: (RootValue) -> WSObject

	public init(key: WSKey, getObject: @escaping (RootValue) -> WSObject) {
		self.key = key
		self.getObject = getObject
	}

	public func getPlist(for value: RootValue) -> [WSKey:WSObject] {
		return [key : getObject(value)]
	}
}

public typealias FieldWSRelation<Value> = WSRelation<Value,String,Any>

public enum FieldSerializationVisibility {
	case never
	case ifVisible
	case always
}

public enum FieldSerializationStrategy<Value>: EmptyType {
	case direct(FieldKey)
	case simple(FieldWSRelation<Value>)
	case multiple([FieldWSRelation<Value>])
//	case path([String],FieldWSRelation<Value>)

	public static var empty: FieldSerializationStrategy<Value> {
		return .direct(FieldKey.empty)
	}
}

public struct FieldSerialization<Value>: EmptyType {

	private let visibility: FieldSerializationVisibility
	private let strategy: FieldSerializationStrategy<Value>

	public init(visibility: FieldSerializationVisibility, strategy: FieldSerializationStrategy<Value>) {
		self.visibility = visibility
		self.strategy = strategy
	}

	public func getWSPlist(for key: FieldKey, in storage: FormStorage) -> PropertyList? {
		guard visibility != .never else { return nil }

		let visible = storage.getHidden(at: key).inverse

		guard visible == true || visibility != .ifVisible else { return nil }

		guard let value = storage.getValue(at: key) as? Value else { return nil }

		switch strategy {
		case let .direct(key):
			return [key: value]
		case let .simple(relation):
			return relation.getPlist(for: value)
		case let .multiple(relations):
			return relations.map(Use(WSRelation.getPlist).with(value)).composeAll
		}
	}

	public static var empty: FieldSerialization<Value> {
		return FieldSerialization(
			visibility: .never,
			strategy: .empty)
	}
}
