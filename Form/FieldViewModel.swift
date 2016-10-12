public struct FieldViewModel {
	public let title: String?
	public let value: FieldValue?
	public let style: FieldOptionsStyle?
	public let errorMessage: String?
	public let isHidden: Bool
	public let isLoading: Bool

	public static func empty(isHidden: Bool, isLoading: Bool) -> FieldViewModel {
		return FieldViewModel(
			title: nil,
			value: nil,
			style: nil,
			errorMessage: nil,
			isHidden: isHidden,
			isLoading: isLoading)
	}
}
