import Functional

public struct FieldModel<Options: FieldOptions>: FieldKeyOwnerType, EmptyType {
	public typealias ValueType = Options.ValueType

	public let key: FieldKey
	public let config: FieldConfig<Options>
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let serialization: FieldSerialization<ValueType>

	public func getWSPlist(in storage: FormStorage) -> PropertyList? {
		return serialization.getWSPlist(for: key, in: storage)
	}

	public func getViewModel(in storage: FormStorage) -> FieldViewModel {
		return config.getViewModel(for: key, in: storage)
	}

	public func updateValueAndApplyActions(with value: Any?, in storage: FormStorage) {
		if let value = value as? ValueType {
			storage.set(value: value, at: key)
			actions.composeAll.apply(value: value, storage: storage)
		} else {
			storage.set(value: nil, at: key)
			actions.composeAll.apply(value: nil, storage: storage)
		}
	}

	public static var empty: FieldModel<Options> {
		return FieldModel(
			key: "",
			config: FieldConfig(
				title: "",
				options: Options.empty),
			rules: [],
			actions: [],
			serialization: FieldSerialization(
				visibility: .never,
				strategy: .direct("")))
	}
}

public typealias ModelStyle = FieldStyle<
	FieldModel<FieldOptionsFixed>,
	FieldModel<FieldOptionsSwitch>,
	FieldModel<FieldOptionsText>,
	FieldModel<FieldOptionsDate>,
	FieldModel<FieldOptionsIntPicker>,
	FieldModel<FieldOptionsStringPicker>,
	FieldModel<FieldOptionsAnyPicker>
>

public struct Field: FieldKeyOwnerType, EmptyType {
	fileprivate let modelStyle: ModelStyle
	public init(_ modelStyle: ModelStyle) {
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
		}
	}

	public func getWSPlist(in storage: FormStorage) -> PropertyList? {
		switch modelStyle {
		case .fixed(let model):
			return model.getWSPlist(in: storage)
		case .onOff(let model):
			return model.getWSPlist(in: storage)
		case .textEntry(let model):
			return model.getWSPlist(in: storage)
		case .datePicker(let model):
			return model.getWSPlist(in: storage)
		case .intPicker(let model):
			return model.getWSPlist(in: storage)
		case .stringPicker(let model):
			return model.getWSPlist(in: storage)
		case .anyPicker(let model):
			return model.getWSPlist(in: storage)
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
		}
	}

	public func updateValueAndApplyActions(with value: Any?, in storage: FormStorage) {
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
		}
	}

	public static var empty: Field {
		return Field(.fixed(.empty))
	}
}

extension Int: FieldValue {
	public var optionalInt: Int? {
		return self
	}

	public var optionalBool: Bool? {
		return nil
	}

	public var optionalString: String? {
		return nil
	}

	public var optionalWSObject: Any? {
		return nil
	}

	public var hashable: AnyHashable {
		return AnyHashable(self)
	}
}

struct Ciccio {
	let x = Field(.onOff(.init(
		key: "",
		config: .init(
			title: "",
			options: FieldOptionsSwitch { $0.analyze(
				ifTrue: "si",
				ifFalse: "no") }),
		rules: [
			.init { (optionalValue, storage) in
				guard let value = optionalValue else { return FieldConformance.empty }
				return value.analyze(ifTrue: FieldConformance.valid, ifFalse: FieldConformance.invalid(message: "message"))
			}
		],
		actions: [
			.init { (optionalValue, storage) in
				guard let value = optionalValue else { return }
				if value == false { fatalError() }
			}
		],
		serialization: .init(
			visibility: .always,
			strategy: .simple(.init(key: "key_ws") { $0.analyze(
				ifTrue: "Y",
				ifFalse: "N") })))))

	var y: Field {

		let config = FieldConfig(
			title: "",
			options: FieldOptionsIntPicker(
				possibleValues: [
					(1, "1"),
					(2, "2"),
					(3, "3")
				]
		))

		let serialization = FieldSerialization<Int>(
			visibility: .always,
			strategy: .simple(.init(key: "key_ws") { ($0 > 0).analyze(
				ifTrue: "Y",
				ifFalse: "N") }))

		let model = FieldModel<FieldOptionsIntPicker>(
			key: "",
			config: config,
			rules: [],
			actions: [],
			serialization: serialization)

		return Field(.intPicker(model))
	}
}
