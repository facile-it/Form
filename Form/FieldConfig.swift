import Functional

public protocol FieldConfigType {//: FieldViewModelGeneratorType {
	associatedtype OptionsType: FieldOptionsType

	var title: String { get }
	var deferredOptions: Deferred<OptionsType> { get }
}

public struct FieldConfig<FieldOptions: FieldOptionsType>: FieldConfigType {
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

	public func getViewModel(for key: FieldKey, in storage: FormStorage) -> FieldViewModel<FieldOptions> {
		guard let availableOptions = [storage.getOptions(at: key) as? FieldOptions,
		                              deferredOptions.peek]
			.firstOptionalSomeOrNone else {

				deferredOptions.upon { storage.set(options: $0, at: key) }

				return FieldViewModel<FieldOptions>.empty(
					isHidden: storage.getHidden(at: key),
					isLoading: true)
		}

		return FieldViewModel<FieldOptions>(
			title: title,
			value: storage.getValue(at: key) as? FieldOptions.FieldValueType,
			options: availableOptions,
			errorMessage: nil,
			isHidden: storage.getHidden(at: key),
			isLoading: false)

	}
}
