import XCTest
import SwiftCheck
import Functional
import Form

typealias ArbitraryTestChange = ArbitraryAnyFieldChange<Int, TestObject>

class FieldChangeSpec: XCTestCase {
    func testMonoidLaws() {
        property("1•a = a") <- forAll { (ai: Int, at: TestObject, ac: ArbitraryTestChange) in
            let object = ac.value
            return AnyFieldChange.zero.compose(object).isEqual(to: object) § (ai, at)
        }
        
        property("a•1 = a") <- forAll { (ai: Int, at: TestObject, ac: ArbitraryTestChange) in
            let object = ac.value
            return object.compose(AnyFieldChange.zero).isEqual(to: object) § (ai, at)
        }
        
        property("(a•b)•c = a•(b•c)") <- forAll { (ai: Int, at: TestObject, ac1: ArbitraryTestChange, ac2: ArbitraryTestChange, ac3: ArbitraryTestChange) in
            let object1 = ac1.value
            let object2 = ac2.value
            let object3 = ac3.value
            return (object1.compose(object2)).compose(object3).isEqual(to:object1.compose(object2.compose(object3))) § (ai, at)
        }
    }
    
    func testChangeSameType() {
            let testObject = TestObject(value: 42)
            let expectedTestObject = TestObject(value: 43)
            let storage = FormStorage()
            storage.set(value: 1, at: "test")

            let result = FieldModel<FieldOptionsIntPicker>(
                key: "test",
                config: .init(
                    title: "",
                    options: .init(
                        possibleValues: [(0, "0")])),
                rules: [],
                actions: [],
                changes: [
					.always(.change { (value, object: inout TestObject) in
						object.value += value })])
                .transform(
                    object: testObject,
                    considering: storage)
            
            XCTAssertEqual(result as? TestObject, expectedTestObject)
    }

	func testChangeOtherType() {
		let testObject = TestObject(value: 42)
		let expectedTestObject = TestObject(value: 42)
		let storage = FormStorage()
		storage.set(value: 1, at: "test")

		let result = FieldModel<FieldOptionsIntPicker>(
			key: "test",
			config: .init(
				title: "",
				options: .init(
					possibleValues: [(0, "0")])),
			rules: [],
			actions: [],
			changes: [
				.always(.change { (value, object: inout AltTestObject) in
					object.value = "\(value)" })])
			.transform(
				object: testObject,
				considering: storage)

		XCTAssertEqual(result as? TestObject, expectedTestObject)
	}

	func testObjectChange() {
		let change = ObjectChange { $0 }
		let start = 10
		let end = change.apply(to: start)
		XCTAssertEqual(end, start)
	}

	func testChangeSameTypeInForm() {
		let testObject = TestObject(value: 3)
		let expectedTestObject = TestObject(value: 18)
		let storage = FormStorage()
		storage.set(value: 2, at: "test1")
		storage.set(value: 3, at: "test2")

		let form = Form(
			storage: storage,
			model: FormModel(subelements: [
				FormStepModel(subelements:[
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test1",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout TestObject) in
									object.value *= value })])))]),
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test2",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout TestObject) in
									object.value *= value })])))])])]))

		return XCTAssertEqual(form.getObjectChange.apply(to: testObject), expectedTestObject)
	}

	func testChangeDifferentTypeFirstInForm() {
		let testObject = TestObject(value: 3)
		let expectedTestObject = TestObject(value: 9)
		let storage = FormStorage()
		storage.set(value: 2, at: "test1")
		storage.set(value: 3, at: "test2")

		let form = Form(
			storage: storage,
			model: FormModel(subelements: [
				FormStepModel(subelements:[
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test1",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout AltTestObject) in
									object.value = "\(value)" })])))]),
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test2",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout TestObject) in
									object.value *= value })])))])])]))

		return XCTAssertEqual(form.getObjectChange.apply(to: testObject), expectedTestObject)
	}

	func testChangeDifferentTypeSecondInForm() {
		let testObject = TestObject(value: 3)
		let expectedTestObject = TestObject(value: 6)
		let storage = FormStorage()
		storage.set(value: 2, at: "test1")
		storage.set(value: 3, at: "test2")

		let form = Form(
			storage: storage,
			model: FormModel(subelements: [
				FormStepModel(subelements:[
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test1",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout TestObject) in
									object.value *= value })])))]),
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test2",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout AltTestObject) in
									object.value = "\(value)" })])))])])]))

		return XCTAssertEqual(form.getObjectChange.apply(to: testObject), expectedTestObject)
	}

	func testChangeDifferentTypeAllInForm() {
		let testObject = TestObject(value: 3)
		let expectedTestObject = TestObject(value: 3)
		let storage = FormStorage()
		storage.set(value: 2, at: "test1")
		storage.set(value: 3, at: "test2")

		let form = Form(
			storage: storage,
			model: FormModel(subelements: [
				FormStepModel(subelements:[
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test1",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout AltTestObject) in
									object.value = "\(value)" })])))]),
					FormSectionModel(subelements:[
						Field(.intPicker(FieldModel<FieldOptionsIntPicker>(
							key: "test2",
							config: .init(
								title: "",
								options: .init(
									possibleValues: [(0, "0")])),
							rules: [],
							actions: [],
							changes: [
								.always(.change { (value, object: inout AltTestObject) in
									object.value = "\(value)" })])))])])]))

		return XCTAssertEqual(form.getObjectChange.apply(to: testObject), expectedTestObject)
	}
}
