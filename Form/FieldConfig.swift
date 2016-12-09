import Functional

public struct FieldConfig<Options: FieldOptions>: EmptyType {
	typealias FieldValueType = Options.ValueType

	public let title: String
	public let deferredOptions: Deferred<Options>

	public init(title: String, deferredOptions: Deferred<Options>) {
		self.title = title
		self.deferredOptions = deferredOptions
	}

	public init(title: String, options: Options) {
		self.init(title: title, deferredOptions: Deferred<Options>(options))
	}

	public func getViewModel(for key: FieldKey, in storage: FormStorage, rules: [FieldRule<FieldValueType>], considering checkValue: (FieldValue) -> FieldValueType?) -> FieldViewModel {
		guard let availableOptions = [storage.getOptions(at: key) as? Options,
		                              deferredOptions.peek]
			.firstNonNilOrNil else {

				deferredOptions.upon { storage.set(options: $0, at: key) }

				return FieldViewModel.empty(
					isHidden: storage.getHidden(at: key),
					isLoading: true)
		}

		let value = storage.getValue(at: key)
		let errorMessage = rules.joined()
			.isValid(value: value.flatMap(checkValue), storage: storage)
			.invalidMessages
			.map { "\(title): \($0)" }
			.joined(separator: "\n")

		return FieldViewModel(
			title: title,
			value: value,
			style: availableOptions.style,
			errorMessage: errorMessage,
			isHidden: storage.getHidden(at: key),
			isLoading: false)
	}

	public static var empty: FieldConfig<Options> {
		return FieldConfig(
			title: String.empty,
			options: Options.empty)
	}
}
