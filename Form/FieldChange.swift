import Foundation
import Functional
import Abstract
import Monads

public struct FieldChange<Value,Object> {
	let transform: (Value,Object) -> Object
	public init(transform: @escaping (Value,Object) -> Object) {
		self.transform = transform
	}
}

public struct AnyFieldChange<Value> {
	let transform: (Value,Any) -> Any

	public init(transform: @escaping (Value,Any) -> Any) {
		self.transform = transform
	}

	public init<T>(change: FieldChange<Value,T>) {
		self.transform = { (value,any) -> Any in
			guard let object = any as? T else { return any }
			return change.transform(value,object)
		}
	}

	public static func change<T>(_ transform: @escaping (Value,T) -> T) -> AnyFieldChange<Value> {
		return AnyFieldChange<Value>(change: FieldChange<Value,T>(transform: transform))
	}

	public static func change<T>(_ transform: @escaping (Value,inout T) -> ()) -> AnyFieldChange<Value> {
		return change { (value: Value, model: T) -> T in
			var m_model = model
			transform(value,&m_model)
			return m_model
		}
	}

	public func apply(with value: Value, to object: Any) -> Any {
		return self.transform(value,object)
	}

	public static var identity: AnyFieldChange<Value> {
		return AnyFieldChange<Value> { _, object in object }
	}
}

extension AnyFieldChange: Monoid {
	public static func <> (left: AnyFieldChange, right: AnyFieldChange) -> AnyFieldChange {
		return AnyFieldChange<Value> { (value, any) -> Any in
			return right.apply(with: value, to: left.apply(with: value, to: any))
		}
	}

	public static var empty: AnyFieldChange<Value> {
		return .identity
	}
}

public enum FieldChangeCondition<Value> {
	case always(AnyFieldChange<Value>)
	case ifVisible(AnyFieldChange<Value>)

	var getChange: AnyFieldChange<Value> {
		switch self {
		case .always(let change):
			return change
		case .ifVisible(let change):
			return change
		}
	}
}

public struct ObjectChange {
	let transform: (Any) -> Any?
	public init(transform: @escaping (Any) -> Any?) {
		self.transform = transform
	}

	public func apply<T>(to object: T) -> T? {
		return transform(object) as? T
	}
}
