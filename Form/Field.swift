import Functional
import JSONObject

public typealias FieldModelStyle = FieldStyle<
	FieldModel<FieldOptionsFixed>,
	FieldModel<FieldOptionsSwitch>,
	FieldModel<FieldOptionsText>,
	FieldModel<FieldOptionsDate>,
	FieldModel<FieldOptionsIntPicker>,
	FieldModel<FieldOptionsStringPicker>,
	FieldModel<FieldOptionsAnyPicker>,
	FieldModel<FieldOptionsCustom>
>

public struct Field: FieldKeyOwnerType {
	fileprivate let modelStyle: FieldModelStyle
	public init(_ modelStyle: FieldModelStyle) {
		self.modelStyle = modelStyle
	}

	public var key: FieldKey {
		switch modelStyle {
		case .fixed(let model):
			return model.key
		case .onOff(let model):
			return model.key
		case .textEntry(let model):
			return model.key
		case .datePicker(let model):
			return model.key
		case .intPicker(let model):
			return model.key
		case .stringPicker(let model):
			return model.key
		case .anyPicker(let model):
			return model.key
		case .custom(let model):
			return model.key
		}
	}

	public func transform(object: Any, considering storage: FormStorage) -> Any {
		switch modelStyle {
		case .fixed(let model):
			return model.transform(object: object, considering: storage)
		case .onOff(let model):
			return model.transform(object: object, considering: storage)
		case .textEntry(let model):
			return model.transform(object: object, considering: storage)
		case .datePicker(let model):
			return model.transform(object: object, considering: storage)
		case .intPicker(let model):
			return model.transform(object: object, considering: storage)
		case .stringPicker(let model):
			return model.transform(object: object, considering: storage)
		case .anyPicker(let model):
			return model.transform(object: object, considering: storage)
		case .custom(let model):
			return model.transform(object: object, considering: storage)
		}
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModel {
		switch modelStyle {
		case .fixed(let model):
			return model.getViewModel(in: storage)
		case .onOff(let model):
			return model.getViewModel(in: storage)
		case .textEntry(let model):
			return model.getViewModel(in: storage)
		case .datePicker(let model):
			return model.getViewModel(in: storage)
		case .intPicker(let model):
			return model.getViewModel(in: storage)
		case .stringPicker(let model):
			return model.getViewModel(in: storage)
		case .anyPicker(let model):
			return model.getViewModel(in: storage)
		case .custom(let model):
			return model.getViewModel(in: storage)
		}
	}

	public func updateValueAndApplyActions(with value: FieldValue?, in storage: FormStorage) {
		switch modelStyle {
		case .fixed(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .onOff(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .textEntry(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .datePicker(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .intPicker(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .stringPicker(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .anyPicker(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		case .custom(let model):
			model.updateValueAndApplyActions(with: value, in: storage)
		}
	}
}
