public enum KeyboardType {
	case text
	case numbers
	case email
}

public struct DateRange: Equatable {
	public let min: Date?
	public let max: Date?
	public init(_ min: Date?, _ max: Date?) {
		self.min = min
		self.max = max
	}
}

public func == (lhs: DateRange, rhs: DateRange) -> Bool {
	return lhs.min == rhs.min && lhs.max == rhs.max
}
