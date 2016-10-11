public enum FieldStyle<Fixed,OnOff,TextEntry,DatePicker,IntPicker,StringPicker,AnyPicker> {
	case fixed(Fixed)
	case onOff(OnOff)
	case textEntry(TextEntry)
	case datePicker(DatePicker)
	case intPicker(IntPicker)
	case stringPicker(StringPicker)
	case anyPicker(AnyPicker)
}
