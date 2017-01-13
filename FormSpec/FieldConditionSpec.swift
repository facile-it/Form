import XCTest
import SwiftCheck
import Functional
import Form

typealias TestedCondition = FieldCondition<Int>

class FieldConditionSpec: XCTestCase {

    func testMonoidLaws() {
        property("1•a = a") <- forAll { (av: OptionalOf<Int>, object: TestedCondition) in
            TestedCondition.empty.join(object).isEqual(to: object) § av.getOptional
        }
        
        property("a•1 = a") <- forAll { (av: OptionalOf<Int>, object: TestedCondition) in
            object.join(TestedCondition.empty).isEqual(to: object) § av.getOptional
        }
        
        property("(a•b)•c = a•(b•c)") <- forAll { (av: OptionalOf<Int>, object1: TestedCondition, object2: TestedCondition, object3: TestedCondition) in
            (object1.join(object2)).join(object3).isEqual(to:object1.join(object2.join(object3))) § av.getOptional
        }
    }
}
