public struct FieldViewModel<FieldOptions: FieldOptionsType> {
	typealias FieldValue = FieldOptions.FieldValueType
	
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

public enum FieldViewModelType {
	case fixed(FieldViewModel<FieldOptionsFixed>)
	case onOff(FieldViewModel<FieldOptionsSwitch>)
	case textEntry(FieldViewModel<FieldOptionsText>)
	case datePicker(FieldViewModel<FieldOptionsDate>)
	case intPicker(FieldViewModel<FieldOptionsPicker<Int>>)
	case stringPicker(FieldViewModel<FieldOptionsPicker<String>>)
	case anyPicker(FieldViewModel<FieldOptionsPicker<AnyHashable>>)
}
