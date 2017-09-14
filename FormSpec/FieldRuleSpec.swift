import XCTest
import SwiftCheck
import Functional
import Abstract
import Monads
import JSONObject
@testable import Form

typealias RuleTested = ArbitraryFieldRule<Int>

class FieldRuleSpec: XCTestCase {
    func testMonoidLaws() {
        property("1•a = a") <- forAll { (av: OptionalOf<Int>, object: RuleTested) in
            let rule = object.get
            return (.empty <> rule).isEqual(to: rule) § av.getOptional
        }
        
        property("a•1 = a") <- forAll { (av: OptionalOf<Int>, object: RuleTested) in
            let rule = object.get
            return (rule <> .empty).isEqual(to: rule) § av.getOptional
        }
        
        property("(a•b)•c = a•(b•c)") <- forAll { (av: OptionalOf<Int>, object1: RuleTested, object2: RuleTested, object3: RuleTested) in
            let rule1 = object1.get
            let rule2 = object2.get
            let rule3 = object3.get
            return (rule1 <> rule2 <> rule3).isEqual(to: rule1 <> (rule2 <> rule3)) § av.getOptional
        }
    }
    
    func testConvenienceRules() {
        property("'nonNil' return FieldConformace valid from a FieldRule with non nil value") <- forAll { (ak: FieldKey, av: ArbitraryFieldValue) in
            let storage = FormStorage()
            let fieldValue: FieldValue? = av.get
            storage.set(value: fieldValue, at: ak)
            
            return FieldRule
                .nonNil(message: "")
                .isValid(value: fieldValue,storage: storage)
                .isValid
        }
        
        property("'nonNil' return FieldConformace invalid from a FieldRule with nil value") <- { () -> Bool in
            let storage = FormStorage()
            
            return !(FieldRule<Int>
                .nonNil(message: "")
                .isValid(value: nil,storage: storage)
                .isValid)
        }
    }
}

