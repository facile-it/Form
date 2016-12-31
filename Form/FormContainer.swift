import Functional

public protocol EmptyConstructible {
	static var empty: Self { get }
}

public protocol FormContainerType: EmptyConstructible {
	associatedtype ConfigurationType: EmptyConstructible
	associatedtype Subtype

	var configuration: ConfigurationType { get }
	var subelements: [Subtype] { get }

	init(configuration: ConfigurationType, subelements: [Subtype])

	func getFieldIndexPath(for subelementIndex: UInt) -> FieldIndexPath
	func getSubelementIndex(at key: FieldKey) -> UInt?
}

extension FormContainerType where ConfigurationType: EmptyConstructible {
	public static var empty: Self {
		return Self(configuration: ConfigurationType.empty, subelements: [])
	}
}

extension FormContainerType where Self.Subtype : FieldKeyOwnerType {
	public func getSubelementIndex(at key: FieldKey) -> UInt? {
		return subelements
			.index { $0.key == key }
			.map { UInt($0) }
	}
}

extension FormContainerType where Self.Subtype : FormContainerType {
	public func getSubelementIndex(at key: FieldKey) -> UInt? {
		return subelements
			.index { $0.getSubelementIndex(at: key) != nil }
			.map { UInt($0) }
	}
}

extension FormContainerType where Self.Subtype: EmptyConstructible {
	public func getSubelement(at key: FieldKey) -> Writer<Subtype,FieldIndexPath> {
		if let index = getSubelementIndex(at: key) {
			return Writer(subelements[Int(index)])
				.tell(getFieldIndexPath(for: index))
		} else {
			return Writer(Subtype.empty)
		}
	}
}
