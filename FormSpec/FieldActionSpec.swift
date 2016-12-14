import XCTest
import SwiftCheck
import Form
import Functional

typealias Tested = FieldAction<Int>

class FieldActionSpec: XCTestCase {
    var actionObserver: CustomObserver<FieldKey>? = nil
    
	func testMonoidLaws() {
		property("1•a = a") <- forAll { (av: OptionalOf<Int>, object: Tested) in
			Tested.empty.join(object).isEqual(to: object) § av.getOptional
		}

		property("a•1 = a") <- forAll { (av: OptionalOf<Int>, object: Tested) in
			object.join(Tested.empty).isEqual(to: object) § av.getOptional
		}

		property("(a•b)•c = a•(b•c)") <- forAll { (av: OptionalOf<Int>, object1: Tested, object2: Tested, object3: Tested) in
			(object1.join(object2)).join(object3).isEqual(to:object1.join(object2.join(object3))) § av.getOptional
		}
	}

	func testConvenienceActions() {
		property("'updateField(at:)' works as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>) in

			let optValue = av.getOptional
			let storage = FormStorage()
			Tested.updateField(at: key).apply(value: optValue, storage: storage)

			return optFieldValuesAreEqual(storage.getValue(at: key), optValue)
		}

		property("'set(value:at:)' works as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>, avIgnored: OptionalOf<Int>) in

			let optValue = av.getOptional
			let storage = FormStorage()
			Tested.set(value: optValue, at: key).apply(value: avIgnored.getOptional, storage: storage)

			return optFieldValuesAreEqual(storage.getValue(at: key), optValue)
		}
        
        property("'removeValueForField(at key:) works as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>, avIgnored:OptionalOf<Int>) in
            
            let optValue = av.getOptional
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.removeValueForField(at: key).apply(value: avIgnored.getOptional, storage: storage)
            return optFieldValuesAreEqual(storage.getValue(at: key), nil)
        }
        
        property("'hideField(at key:)' work as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>, avIgnored: OptionalOf<Int>) in
            
            let optValue = av.getOptional
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.hideField(at: key).apply(value: avIgnored.getOptional, storage: storage)
            return storage.getHidden(at: key)
        }
        
        property("'showField(at key:)' work as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>, avIgnored: OptionalOf<Int>) in
            
            let optValue = av.getOptional
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.hideField(at: key).apply(value: avIgnored.getOptional, storage: storage)
            Tested.showField(at: key).apply(value: avIgnored.getOptional, storage: storage)
            return !storage.getHidden(at: key)
        }
        
        property("'removeValueAndHideField(at key:)' work as intended") <- forAll { (key: FieldKey, av: OptionalOf<Int>, avIgnored: OptionalOf<Int>) in
            
            let optValue = av.getOptional
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.removeValueAndHideField(at: key).apply(value: avIgnored.getOptional, storage: storage)
            
            return storage.getHidden(at: key) && storage.getValue(at: key) == nil
        }
	}
}
