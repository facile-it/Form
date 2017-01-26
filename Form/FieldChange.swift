import Foundation
import Functional

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
		return AnyFieldChange<Value> { $0.1 }
	}
}

extension AnyFieldChange: Monoid {
	public func join(_ other: AnyFieldChange<Value>) -> AnyFieldChange<Value> {
		return AnyFieldChange<Value> { (value, any) -> Any in
			return other.apply(with: value, to: self.apply(with: value, to: any))
		}
	}

	public static var zero: AnyFieldChange<Value> {
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
