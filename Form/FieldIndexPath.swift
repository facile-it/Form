import Functional
import Abstract
import Monads

public struct FieldIndexPath: Hashable {
	public let stepIndex: UInt?
	public let sectionIndex: UInt?
	public let fieldIndex: UInt?

	public static func with(stepIndex index: UInt) -> FieldIndexPath {
		return FieldIndexPath(stepIndex: index, sectionIndex: nil, fieldIndex: nil)
	}

	public static func with(sectionIndex index: UInt) -> FieldIndexPath {
		return FieldIndexPath(stepIndex: nil, sectionIndex: index, fieldIndex: nil)
	}

	public static func with(fieldIndex index: UInt) -> FieldIndexPath {
		return FieldIndexPath(stepIndex: nil, sectionIndex: nil, fieldIndex: index)
	}

	public var hashValue: Int {
		let step = stepIndex.map { Int($0) } ?? -1
		let section = sectionIndex.map { Int($0) } ?? -1
		let field = fieldIndex.map { Int($0) } ?? -1
		return "\(step)_\(section)_\(field)".hashValue
	}
}

public func == (lhs: FieldIndexPath, rhs: FieldIndexPath) -> Bool {
	return lhs.stepIndex == rhs.stepIndex
		&& lhs.sectionIndex == rhs.sectionIndex
		&& lhs.fieldIndex == rhs.fieldIndex
}

extension FieldIndexPath: Monoid {
	public static var empty: FieldIndexPath {
		return FieldIndexPath(stepIndex: nil, sectionIndex: nil, fieldIndex: nil)
	}

	public static func <> (left: FieldIndexPath, right: FieldIndexPath) -> FieldIndexPath {
		return FieldIndexPath(
			stepIndex: right.stepIndex ?? left.stepIndex,
			sectionIndex: right.sectionIndex ?? left.sectionIndex,
			fieldIndex: right.fieldIndex ?? left.fieldIndex)
	}
}

public struct FieldIndexPathComplete: Hashable {
	public let stepIndex: UInt
	public let sectionIndex: UInt
	public let fieldIndex: UInt

	public init(stepIndex: UInt, sectionIndex: UInt, fieldIndex: UInt) {
		self.stepIndex = stepIndex
		self.sectionIndex = sectionIndex
		self.fieldIndex = fieldIndex
	}

	public init?(_ path: FieldIndexPath) {
		guard let
			stepIndex = path.stepIndex,
			let sectionIndex = path.sectionIndex,
			let fieldIndex = path.fieldIndex
			else { return nil }
		self.init(stepIndex: stepIndex, sectionIndex: sectionIndex, fieldIndex: fieldIndex)
	}

	public var hashValue: Int {
		return "\(stepIndex)_\(sectionIndex)_\(fieldIndex)".hashValue
	}
}

public func == (lhs: FieldIndexPathComplete, rhs: FieldIndexPathComplete) -> Bool {
	return lhs.stepIndex == rhs.stepIndex
		&& lhs.sectionIndex == rhs.sectionIndex
		&& lhs.fieldIndex == rhs.fieldIndex
}
