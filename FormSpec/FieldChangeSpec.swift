import XCTest
import SwiftCheck
import Functional
import Form

typealias ArbitraryTestChange = ArbitraryAnyFieldChange<Int, TestObject>

class FieldChangeSpec: XCTestCase {
    func testMonoidLaws() {
        property("1•a = a") <- forAll { (ai: Int, at: TestObject, ac: ArbitraryTestChange) in
            let object = ac.value
            return AnyFieldChange.zero.join(object).isEqual(to: object) § (ai, at)
        }
        
        property("a•1 = a") <- forAll { (ai: Int, at: TestObject, ac: ArbitraryTestChange) in
            let object = ac.value
            return object.join(AnyFieldChange.zero).isEqual(to: object) § (ai, at)
        }
        
        property("(a•b)•c = a•(b•c)") <- forAll { (ai: Int, at: TestObject, ac1: ArbitraryTestChange, ac2: ArbitraryTestChange, ac3: ArbitraryTestChange) in
            let object1 = ac1.value
            let object2 = ac2.value
            let object3 = ac3.value
            return (object1.join(object2)).join(object3).isEqual(to:object1.join(object2.join(object3))) § (ai, at)
        }
    }
    
    func testChange() {
        property("'init(change:)' makes changes as expected") <- {
            let testObject = TestObject(value: 42)
            let expectedTestObject = TestObject(value: 43)
            let storage = FormStorage()
            storage.set(value: 1, at: "test")
            
            let result = FieldModel<FieldOptionsIntPicker>(
                key: "test",
                config: .init(
                    title: "",
                    options: .init(
                        possibleValues: [0 : "0"])),
                rules: [],
                actions: [],
                changes: [
                    .always(.change { (value, object: inout TestObject) in
                        object.value += value
                    })])
                .transform(
                    object: testObject,
                    considering: storage)
            
            guard let res = result as? TestObject else { return false }
            return res == expectedTestObject
        }
    }
}
