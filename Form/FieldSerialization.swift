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

public typealias FieldWSRelation<FieldValue> = WSRelation<FieldValue,String,Any>

public enum FieldSerializationVisibility {
	case never
	case ifVisible
	case always
}

public enum FieldSerializationStrategy<FieldValueType> {
	case simple(FieldWSRelation<FieldValueType>)
	case multiple([FieldWSRelation<FieldValueType>])
//	case path([String],FieldWSRelation<FieldValueType>)
}

public struct FieldSerialization<FieldValueType> {

	private let visibility: FieldSerializationVisibility
	private let strategy: FieldSerializationStrategy<FieldValueType>

	public init(visibility: FieldSerializationVisibility, strategy: FieldSerializationStrategy<FieldValueType>) {
		self.visibility = visibility
		self.strategy = strategy
	}

	public func getPlist(value: FieldValueType, visible: Bool) -> PropertyList? {
		guard visibility != .never else { return nil }

		guard visible == true || visibility != .ifVisible else { return nil }

		switch strategy {
		case let .simple(relation):
			return relation.getPlist(for: value)
		case let .multiple(relations):
			return relations.map(Use(WSRelation.getPlist).with(value)).composeAll()
		}
	}
}
