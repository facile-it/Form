//import Foundation
//import FunctionalKit
import Abstract

//import NetworkingKit
//
//public struct WSRelation<RootValue> {
//	private let key: String
//	private let getObject: (RootValue) -> JSONObject?
//
//	public init(key: String, getObject: @escaping (RootValue) -> JSONObject?) {
//		self.key = key
//		self.getObject = getObject
//	}
//
//	public func getObject(for value: RootValue) -> JSONObject? {
//		return getObject(value)
//			.map { [key:$0] }
//			.map(JSONObject.dict)
//	}
//}
//
//public typealias FieldWSRelation<Value: FieldValue> = WSRelation<Value>
//
//public enum FieldSerializationCondition {
//	case never
//	case ifVisible
//	case always
//}
//
//public enum FieldSerializationStrategy<Value>: EmptyConstructible {
//	case direct(FieldKey)
//	case single(FieldWSRelation<Value>)
//	case multiple([FieldWSRelation<Value>])
////	case path([String],FieldWSRelation<Value>)
//
//	public static var empty: FieldSerializationStrategy<Value> {
//		return .direct(FieldKey.empty)
//	}
//}
//
//public struct FieldSerialization<Value: FieldValue>: EmptyConstructible {
//
//	private let condition: FieldSerializationCondition
//	private let strategy: FieldSerializationStrategy<Value>
//
//	public init(condition: FieldSerializationCondition, strategy: FieldSerializationStrategy<Value>) {
//		self.condition = condition
//		self.strategy = strategy
//	}
//
//	public func getJSONObject(for key: FieldKey, in storage: FormStorage, considering checkValue: (FieldValue) -> Value?) -> JSONObject? {
//		guard condition != .never else { return nil }
//
//		let visible = storage.getHidden(at: key).inverse
//
//		guard visible == true || condition != .ifVisible else { return nil }
//
//		guard let value = storage.getValue(at: key).flatMap(checkValue) else { return nil }
//
//		switch strategy {
//		case let .direct(key):
//			return FieldWSRelation<Value>(key: key) { $0.optionalJSONObject }.getObject(for: value)
//		case let .single(relation):
//			return relation.getObject(for: value)
//		case let .multiple(relations):
//			return relations.mapSome(WSRelation.getObject >< value).concatenated()
//		}
//	}
//
//	public static func simple(key: FieldKey) -> FieldSerialization<Value> {
//		return FieldSerialization(
//			condition: .ifVisible,
//			strategy: .direct(key))
//	}
//
//	public static var empty: FieldSerialization<Value> {
//		return FieldSerialization(
//			condition: .never,
//			strategy: .empty)
//	}
//}
