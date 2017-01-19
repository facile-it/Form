import XCTest
import SwiftCheck
import Functional
@testable import Form

typealias TestedCondition = FieldCondition<Int>
typealias ArbitraryTestedCondition = ArbitraryFieldCondition<Int>

class FieldConditionSpec: XCTestCase {

    func testMonoidLaws() {
        property("1•a = a") <- forAll { (av: OptionalOf<Int>, ac: ArbitraryTestedCondition) in
            let object = ac.get
            return TestedCondition.zero.join(object).isEqual(to: object) § av.getOptional
        }
        
        property("a•1 = a") <- forAll { (av: OptionalOf<Int>, ac: ArbitraryTestedCondition) in
            let object = ac.get
            return object.join(TestedCondition.zero).isEqual(to: object) § av.getOptional
        }
        
        property("(a•b)•c = a•(b•c)") <- forAll { (av: OptionalOf<Int>, ac1: ArbitraryTestedCondition, ac2: ArbitraryTestedCondition, ac3: ArbitraryTestedCondition) in
            let object1 = ac1.get
            let object2 = ac2.get
            let object3 = ac3.get
            return (object1.join(object2)).join(object3).isEqual(to:object1.join(object2.join(object3))) § av.getOptional
        }
    }
    
    func testCheck() {
        property("check(value:storage:) is consistent with 'predicate' if FieldValue is nil") <- forAll { (ac: ArbitraryFieldCondition<Int>) in
            let condition = ac.get
            let storage = FormStorage()
            
            return condition.check(value: nil, storage: storage) == condition.predicate(nil,storage)
        }
        
        property("check(value:storage:) is consistent with 'predicate' if FieldValue is Value, otherwise returns false") <- forAll { (ac: ArbitraryFieldCondition<Int>, av: ArbitraryFieldValue) in
            let condition = ac.get
            let value = av.get
            
            let storage = FormStorage()
            
            return
                (value is Int ==> {
                    condition.check(value: value, storage: storage) == condition.predicate(value as? Int,storage) })
                ^&&^
                (value is Int == false ==> {
                    condition.check(value: value, storage: storage) == false })
        }
    }
    
    func testConvenienceConditions() {
        property("'and(_ other:)' works as intended") <- forAll { (av1: OptionalOf<Int>, ac1: ArbitraryTestedCondition, ac2: ArbitraryTestedCondition) in
            let storage = FormStorage()
            
            let condition1 = ac1.get
            let condition2 = ac1.get
            
            let check1 = condition1.check(value: av1.getOptional, storage: storage)
            let check2 = condition2.check(value: av1.getOptional, storage: storage)
            
            let andCondition = condition1.and(condition2)
            let andCheck = andCondition.check(value: av1.getOptional, storage: storage)
            
            return (andCheck && (check1 && check2)) || (!andCheck && !(check1 && check2))
        }
        
        property("'or(_ other:)' works as intended") <- forAll { (av: OptionalOf<Int>, ac1: ArbitraryTestedCondition, ac2: ArbitraryTestedCondition) in
            let storage = FormStorage()
            
            let condition1 = ac1.get
            let condition2 = ac1.get
            
            let check1 = condition1.check(value: av.getOptional, storage: storage)
            let check2 = condition2.check(value: av.getOptional, storage: storage)
            
            let orCondition = condition1.or(condition2)
            let orCheck = orCondition.check(value: av.getOptional, storage: storage)
            
            return (orCheck && (check1 && check2)) || (!orCheck && !(check1 && check2))
        }
        
        property("'valueIs(equalTo otherValue:)' return true condition for equal values") <- forAll { (av: OptionalOf<Int>) in
            let storage = FormStorage()
            let optValue = av.getOptional
            
            return FieldCondition<Int>
                .valueIs(equalTo: optValue)
                .check(value: optValue, storage: storage)
        }
        
        property("'valueIs(differentFrom otherValue:)' return true condition for different values") <- forAll { (av: OptionalOf<Int>) in
            let storage = FormStorage()
            let optValue = av.getOptional
            
            guard let value = optValue else { return true }
            let diffOptValue: Int? = value + 1
            
            return FieldCondition<Int>
                .valueIs(differentFrom: diffOptValue)
                .check(value: optValue, storage: storage)
        }
        
        property("'otherValue(at key:isEqual toValue:)' return true condition for equal values") <- forAll { (ak: FieldKey, av: OptionalOf<Int>) in
            let storage = FormStorage()
            let optValue = av.getOptional
            storage.set(value: optValue, at: ak)
            
            return FieldCondition<Int>
                .otherValue(at: ak, isEqual: optValue)
                .check(value: optValue, storage: storage)
        }
        
        property("'ifTrue(_ action:)' return actionTrue for true condition") <- forAll { (av: OptionalOf<Int>, ak: FieldKey, actionTrue:FieldAction<Int>) in
            let storage = FormStorage()
            storage.set(value: av.getOptional, at: ak)
            let condition = FieldCondition<Int>.init(predicate: { (_, storage) -> Bool in
                true
            })
            
            return condition
                .ifTrue(actionTrue)
                .isEqual(to: actionTrue)(av.getOptional)
        }
        
        property("'ifFalse(_ action:)' return actionFalse for false condition") <- forAll { (av: OptionalOf<Int>, ak: FieldKey, actionFalse:FieldAction<Int>) in
            let storage = FormStorage()
            storage.set(value: av.getOptional, at: ak)
            let condition = FieldCondition<Int>.init(predicate: { (_, storage) -> Bool in
                false
            })
            
            return condition
                .ifFalse(actionFalse)
                .isEqual(to: actionFalse)(av.getOptional)
        }
    }
}
