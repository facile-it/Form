public struct FieldViewModel<FieldValue, FieldOptions: FieldOptionsType> where FieldOptions.FieldValueType == FieldValue {
	public let title: String?
	public let value: FieldValue?
	public let options: FieldOptions?
	public let errorMessage: String?
	public let isHidden: Bool
	public let isLoading: Bool

	public static func empty(isHidden: Bool, isLoading: Bool) -> FieldViewModel {
		return FieldViewModel(
			title: nil,
			value: nil,
			options: nil,
			errorMessage: nil,
			isHidden: isHidden,
			isLoading: isLoading)
	}
}
