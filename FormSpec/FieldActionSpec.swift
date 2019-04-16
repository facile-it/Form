import XCTest
import SwiftCheck
import Form
import FunctionalKit
import Abstract

import Signals

typealias Tested = FieldAction<Int>

class FieldActionSpec: XCTestCase {
	func testMonoidLaws() {
		property("1•a = a") <- forAll { (av: Optional<Int>, object: Tested) in
			(.empty <> object).isEqual(to: object) § av
		}

		property("a•1 = a") <- forAll { (av: Optional<Int>, object: Tested) in
			(object <> .empty).isEqual(to: object) § av
		}

		property("(a•b)•c = a•(b•c)") <- forAll { (av: Optional<Int>, object1: Tested, object2: Tested, object3: Tested) in
            let x1 = object1 <> object2
            let x2 = object3
            let resultX = x1 <> x2
            
            let y1 = object1
            let y2 = object2 <> object3
            let resultY = y1 <> y2
            
            let storageX = FormStorage()
            let storageY = FormStorage()
            
            resultX.apply(value: av, storage: storageX)
            resultY.apply(value: av, storage: storageY)
            
            let isEqual = storageX.hasSameFieldValuesAndHiddenFieldKeys(of: storageY)
            
            return isEqual
            
//            return (object1 <> object2 <> object3).isEqual(to: object1 <> (object2 <> object3)) § av
		}
	}

	func testConvenienceActions() {
		property("'updateField(at:)' works as intended") <- forAll { (key: FieldKey, av: Optional<Int>) in

			let optValue = av
			let storage = FormStorage()
			Tested.updateField(at: key).apply(value: optValue, storage: storage)

			return optFieldValuesAreEqual(storage.getValue(at: key), optValue)
		}

		property("'set(value:at:)' works as intended") <- forAll { (key: FieldKey, av: Optional<Int>, avIgnored: Optional<Int>) in

			let optValue = av
			let storage = FormStorage()
			Tested.set(value: optValue, at: key).apply(value: avIgnored, storage: storage)

			return optFieldValuesAreEqual(storage.getValue(at: key), optValue)
		}
        
        property("'removeValueForField(at key:) works as intended") <- forAll { (key: FieldKey, av: Optional<Int>, avIgnored:Optional<Int>) in
            
            let optValue = av
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.removeValueForField(at: key).apply(value: avIgnored, storage: storage)
            return optFieldValuesAreEqual(storage.getValue(at: key), nil)
        }
        
        property("'hideField(at key:)' work as intended") <- forAll { (key: FieldKey, av: Optional<Int>, avIgnored: Optional<Int>) in
            
            let optValue = av
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.hideField(at: key).apply(value: avIgnored, storage: storage)
            return storage.getHidden(at: key)
        }
        
        property("'showField(at key:)' work as intended") <- forAll { (key: FieldKey, av: Optional<Int>, avIgnored: Optional<Int>) in
            
            let optValue = av
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.hideField(at: key).apply(value: avIgnored, storage: storage)
            Tested.showField(at: key).apply(value: avIgnored, storage: storage)
            return !storage.getHidden(at: key)
        }
        
        property("'removeValueAndHideField(at key:)' work as intended") <- forAll { (key: FieldKey, av: Optional<Int>, avIgnored: Optional<Int>) in
            
            let optValue = av
            let storage = FormStorage()
            storage.set(value: optValue as FieldValue?, at: key)
            Tested.removeValueAndHideField(at: key).apply(value: avIgnored, storage: storage)
            
            return storage.getHidden(at: key) && storage.getValue(at: key) == nil
        }
	}
    
    func testNotify() {
        
        let storage = FormStorage()
        let value: Int? = 23
        let key = "MJ"
        storage.set(value: value, at: key)
        
        let storageReactedToNotify = expectation(description: "storageReactedToNotify")

		storage.observableFieldKey.onNext { key in
			storageReactedToNotify.fulfill()
			return .again
		}

        Tested.notify(at: key).apply(value: value, storage: storage)

        waitForExpectations(timeout: 1, handler: nil)
    }
}
