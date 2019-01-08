import FunctionalKit
import Abstract


public struct FieldConfig<Options: FieldOptions> {
	public typealias FieldValueType = Options.ValueType

	public let title: String
	public let futureOptions: Future<Options>

	public init(title: String, futureOptions: Future<Options>) {
		self.title = title
		self.futureOptions = futureOptions
	}

	public init(title: String, options: Options) {
		self.init(title: title, futureOptions: Future<Options>.pure(options))
	}

	public func getViewModel(for key: FieldKey, in storage: FormStorage, rules: [FieldRule<FieldValueType>]) -> FieldViewModel {
		var available: Options? = nil
		futureOptions.run {
			available = $0
		}
		guard let availableOptions = [storage.getOptions(at: key) as? Options,
		                              available]
			.first(where: { $0 != nil }).joined() else {

				futureOptions.run { storage.set(options: $0, at: key) }

				return FieldViewModel.empty(
					isHidden: storage.getHidden(at: key),
					isLoading: true)
		}

		let value = storage.getValue(at: key)
		let errorMessage = rules.concatenated()
			.isValid(value: value.flatMap(Options.sanitizeValue), storage: storage)
			.invalidMessages
			.map { "\(self.title): \($0)\n" }
			.concatenated()

		return FieldViewModel(
			title: title,
			value: value,
			style: availableOptions.style,
			errorMessage: Optional(errorMessage).filter { $0.isEmpty == false },
			isHidden: storage.getHidden(at: key),
			isLoading: false)
	}
}
