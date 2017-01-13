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
    }
}
