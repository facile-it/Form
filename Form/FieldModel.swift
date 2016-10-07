import Functional

public typealias FieldKey = String

public struct FieldModel<FieldConfig: FieldConfigType> {
	typealias ValueType = FieldConfig.OptionsType.FieldValueType
	public let key: FieldKey
	public let config: FieldConfig
	public let rules: [FieldRule<ValueType>]
	public let actions: [FieldAction<ValueType>]
	public let serialization: FieldSerialization<ValueType>
}

struct Ciccio {
	let x = FieldModel(
		key: "key_local",
		config: FieldConfig(
			title: "field_title",
			options: FieldOptionsSwitch { $0.analyze(
				ifTrue: "si",
				ifFalse: "no") }),
		rules: [.nonNil(message: "should not be nil"),
		        .shouldBeTrue(message: "should be true")],
		actions: [.set(value: 3, at: "ciccio"),
		          FieldCondition.valueIs(equal: true).runCondition(
					ifTrue: .hideField(at: "pluto"),
					ifFalse: .showField(at: "pluto"))],
		serialization: FieldSerialization(
			visibility: .always,
			strategy: .simple(FieldWSRelation(key: "key_ws") { $0.analyze(
				ifTrue: "Y",
				ifFalse: "N") })))
}

extension FieldRuleType where FieldValueType == Bool {
	static func shouldBeTrue(message: String) -> FieldRule<Bool> {
		return FieldRule { $0.0.getOrElse(false).analyze(
			ifTrue: .valid,
			ifFalse: .invalid(message: message)) }
	}
}
