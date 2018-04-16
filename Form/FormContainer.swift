import FunctionalKit
import Abstract


public protocol FormContainerType {
	associatedtype ConfigurationType
	associatedtype Subtype

	var configuration: ConfigurationType { get }
	var subelements: [Subtype] { get }

	init(configuration: ConfigurationType, subelements: [Subtype])

	func getFieldIndexPath(for subelementIndex: UInt) -> FieldIndexPath
	func getSubelementIndex(at key: FieldKey) -> UInt?
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

extension FormContainerType {
	public func getSubelement(at key: FieldKey) -> Writer<FieldIndexPath,Subtype>? {
		guard let index = getSubelementIndex(at: key) else { return nil }
		return Writer.pure(subelements[Int(index)]).tell(getFieldIndexPath(for: index))
	}
}
