import Functional

public struct FieldConfig<Options: FieldOptions>: EmptyType {
	public let title: String
	public let deferredOptions: Deferred<Options>

	public init(title: String, deferredOptions: Deferred<Options>) {
		self.title = title
		self.deferredOptions = deferredOptions
	}

	public init(title: String, options: Options) {
		self.init(title: title, deferredOptions: Deferred<Options>(options))
	}

	public func getViewModel(for key: FieldKey, in storage: FormStorage) -> FieldViewModel {
		guard let availableOptions = [storage.getOptions(at: key) as? Options,
		                              deferredOptions.peek]
			.firstOptionalSomeOrNone else {

				deferredOptions.upon { storage.set(options: $0, at: key) }

				return FieldViewModel.empty(
					isHidden: storage.getHidden(at: key),
					isLoading: true)
		}

		return FieldViewModel(
			title: title,
			value: storage.getValue(at: key) as? FieldValue,
			style: availableOptions.style,
			errorMessage: nil,
			isHidden: storage.getHidden(at: key),
			isLoading: false)
	}

	public static var empty: FieldConfig<Options> {
		return FieldConfig(
			title: String.empty,
			options: Options.empty)
	}
}
