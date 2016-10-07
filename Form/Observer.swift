public protocol ObserverType: class {
	associatedtype ObservedType

	var identifier: String { get }
	func observe(_ value: ObservedType)
}

class BoxObserverBase<Wrapped>: ObserverType {
	typealias ObservedType = Wrapped
	var identifier: String = ""
	func observe(_ value: Wrapped) {
		fatalError()
	}
}

final class BoxObserver<Observer: ObserverType>: BoxObserverBase<Observer.ObservedType> {
	let base: Observer?
	init(_ base: Observer) {
		self.base = base
		super.init()
		self.identifier = base.identifier
	}

	override func observe(_ value: Observer.ObservedType) {
		base?.observe(value)
	}
}

final class WeakBoxObserver<Observer: ObserverType>: BoxObserverBase<Observer.ObservedType> {
	weak var base: Observer?
	init(_ base: Observer) {
		self.base = base
		super.init()
		self.identifier = base.identifier
	}

	override func observe(_ value: Observer.ObservedType) {
		base?.observe(value)
	}
}

public final class AnyWeakObserver<Type>: ObserverType {
	public typealias ObservedType = Type

	fileprivate let base: BoxObserverBase<Type>
	public init<Observer: ObserverType>(_ base: Observer) where Observer.ObservedType == ObservedType {
		self.base = WeakBoxObserver(base)
	}

	public var identifier: String {
		return base.identifier
	}

	public func observe(_ value: Type) {
		base.observe(value)
	}
}

public final class AnyObserver<Type>: ObserverType {
	public typealias ObservedType = Type

	fileprivate let base: BoxObserverBase<Type>
	public init<Observer: ObserverType>(_ base: Observer) where Observer.ObservedType == ObservedType {
		self.base = BoxObserver(base)
	}

	public var identifier: String {
		return base.identifier
	}

	public func observe(_ value: Type) {
		base.observe(value)
	}
}

public final class Observer<Type>: ObserverType {
	public typealias ObservedType = Type

	public let identifier: String
	private let observation: (Type) -> ()

	public init(identifier: String, observation: @escaping (Type) -> ()) {
		self.identifier = identifier
		self.observation = observation
	}

	public func observe(_ value: Type) {
		observation(value)
	}
}

public protocol EmitterType {
	associatedtype EmittedType
	func addObserver<Observer: ObserverType>(_ observer: Observer) where Observer.ObservedType == EmittedType
	func removeObserver(withIdentifier identifier: String)
}

public final class Deferred<Wrapped> {

	private var value: Wrapped?
	private var observers: [Observer<Wrapped>] = []

	public init(_ value: Wrapped? = nil) {
		self.value = value
	}

	public var peek: Wrapped? {
		return value
	}

	@discardableResult public func upon(callback: @escaping (Wrapped) -> ()) -> Deferred {
		if let value = value {
			callback(value)
		} else {
			observers.append(Observer<Wrapped>(identifier: "", observation: callback))
		}
		return self
	}

	@discardableResult public func fill(with value: Wrapped) -> Deferred {
		guard self.value == nil else { return self }
		self.value = value
		observers.forEach { $0.observe(value) }
		observers.removeAll()
		return self
	}
}
