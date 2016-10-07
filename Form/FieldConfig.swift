import Functional

public protocol FieldViewModelGeneratorType {
	associatedtype OptionsType: FieldOptionsType

	func getViewModel(at key: FieldKey, in storage: FormStorage) -> FieldViewModel<OptionsType.FieldValueType,OptionsType>
}

public protocol FieldConfigType {
	associatedtype OptionsType: FieldOptionsType

	var title: String { get }
	var deferredOptions: Deferred<OptionsType> { get }
}

extension FieldViewModelGeneratorType where Self: FieldConfigType {
	public func getViewModel(at key: FieldKey, in storage: FormStorage) -> FieldViewModel<OptionsType.FieldValueType,OptionsType> {
		guard let availableOptions = [storage.getOptions(at: key) as? OptionsType,
		                              deferredOptions.peek]
			.firstOptionalSomeOrNone else {

				deferredOptions.upon { storage.set(options: $0, at: key) }

				return FieldViewModel<OptionsType.FieldValueType, OptionsType>.empty(
					isHidden: storage.getHidden(at: key),
					isLoading: true)
		}

		return FieldViewModel<OptionsType.FieldValueType, OptionsType>(
			title: title,
			value: storage.getValue(at: key) as? OptionsType.FieldValueType,
			options: availableOptions,
			errorMessage: nil,
			isHidden: storage.getHidden(at: key),
			isLoading: false)
	}
}

public struct FieldConfig<FieldOptions: FieldOptionsType>: FieldConfigType, FieldViewModelGeneratorType {
	public typealias OptionsType = FieldOptions

	public let title: String
	public let deferredOptions: Deferred<FieldOptions>

	init(title: String, deferredOptions: Deferred<FieldOptions>) {
		self.title = title
		self.deferredOptions = deferredOptions
	}

	init(title: String, options: FieldOptions) {
		self.init(title: title, deferredOptions: Deferred<FieldOptions>(options))
	}
}
