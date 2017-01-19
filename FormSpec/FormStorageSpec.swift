import XCTest
import Form
import SwiftCheck
import Functional
import Signals

class FormStorageSpec: XCTestCase {

	func testAllKeys() {
		property("'allKeys' is consistent with stored field values") <- forAll { (ap1: ArbitraryPair<OptionalOf<ArbitraryFieldValue>,FieldKey>, ap2: ArbitraryPair<OptionalOf<ArbitraryFieldValue>,FieldKey>, ap3: ArbitraryPair<OptionalOf<ArbitraryFieldValue>,FieldKey>, ap4: ArbitraryPair<OptionalOf<ArbitraryFieldValue>,FieldKey>) in

			let storage = FormStorage()

			let array = [ap1, ap2, ap3, ap4]
				.map { ($0.left.getOptional?.get, $0.right) }

			array.forEach {
				storage.set(value: $0.0, at: $0.1)
			}

			let expectedKeys = array
				.reduce([:]) { (accumulation: [FieldKey:FieldValue], element: (FieldValue?,FieldKey)) in
					var m_dict = accumulation
					m_dict[element.1] = element.0
					return m_dict
				}
				.keys
				|> Set.init

			return storage.allKeys.isEqual(to: expectedKeys)
		}
	}

	func testSetGetValue() {
		let storage = FormStorage()

		property("'setValue' and 'getValue' should be consistent") <- forAll { (av: OptionalOf<ArbitraryFieldValue>, ak: FieldKey) in
			let optValue = av.getOptional?.get as FieldValue?
			storage.set(value: optValue, at: ak)
			let optGotValue = storage.getValue(at: ak)
			return optFieldValuesAreEqual(optGotValue, optValue)
		}
	}

	func testClear() {
		property("'clear' should remove all keys") <- {
			let storage = FormStorage()

			storage.set(value: 3, at: "4")
			storage.set(value: nil, at: "5")
			storage.set(value: "hello", at: "world")

			guard storage.allKeys.count > 0 else { return false }

			storage.clear()

			return storage.allKeys.count == 0
		}
	}

	func testSendSetValueWhenNeeded() {
		let storage = FormStorage()

		let value1 = 42
		let value2 = 43
		let key = "don't panic"

		let counterWillReach6 = expectation(description: "counterWillReach6")

		var counter = 0
		storage.observableFieldKey.onNext { sentKey in
			XCTAssertEqual(sentKey, key)
			counter += 1
			if counter >= 6 {
				counterWillReach6.fulfill()
			}
			return .again
		}

		storage.set(value: nil, at: key)
		storage.set(value: value1, at: key)
		storage.set(value: value1, at: key)
		storage.set(value: nil, at: key)
		storage.set(value: value2, at: key)
		storage.set(value: value1, at: key)
		storage.set(value: value2, at: key)
		storage.set(value: value2, at: key)
		storage.set(value: nil, at: key)
		storage.set(value: nil, at: key)

		waitForExpectations(timeout: 1, handler: nil)
	}
    
    func testSetGetOptions() {
        let storage = FormStorage();
        
        property("'setOptions' and 'getOptions' should be consistent") <- forAll { (ao: OptionalOf<ArbitraryFieldValue>, av: OptionalOf<ArbitraryFieldValue>, ak: FieldKey) in
            storage.set(value: av.getOptional?.get as FieldValue?, at: ak)
            storage.set(options: ao.getOptional?.get, at: ak)
            let optGotOption = storage.getOptions(at: ak)
            if ao.getOptional == nil && optGotOption == nil { return true }
            guard let option = ao.getOptional?.get, let gotOption = optGotOption else { return false }
            guard gotOption is FieldValue else { return false }
            return (gotOption as! FieldValue).isEqual(to: option)
        }
    }
    
    func testSetOptionsWhenNeeded() {
        let storage = FormStorage()
        
        let value = 42
        let key = "don't panic"
        storage.set(value: value, at: key)
        
        let option1 = 23
        let option2 = 91
        
        let counterWillReach9 = expectation(description: "counterWillReach9")
        
        var counter = 0
		storage.observableFieldKey.onNext { sentKey in
			counter += 1
			if counter >= 9 {
				counterWillReach9.fulfill()
			}
			return .again
		}

        storage.set(options: nil, at: key)
        storage.set(options: option2, at: key)
        storage.set(options: option1, at: key)
        storage.set(options: option2, at: key)
        storage.set(options: option2, at: key)
        storage.set(options: option2, at: key)
        storage.set(options: option1, at: key)
        storage.set(options: option1, at: key)
        storage.set(options: option1, at: key)
        storage.set(options: option2, at: key)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSetGetHidden() {
        let storage = FormStorage()
        
        property("'setHidden' and 'getHidden' should be consistent") <- forAll { (ab: Bool, av: OptionalOf<ArbitraryFieldValue>, ak: FieldKey) in
            storage.set(value: av.getOptional?.get as FieldValue?, at: ak)
            storage.set(hidden: ab, at: ak)
            let gotHidden = storage.getHidden(at: ak)
            
            if gotHidden != ab { return false }
            return true
        }
    }
    
    func testSendSetHiddenWhenNeeded() {
        let storage = FormStorage()
        
        let value = 42
        let key = "don't panic"
        storage.set(value: value, at: key)
        
        let counterWillReach6 = expectation(description: "counterWillReach10")
        
        var counter = 0
		storage.observableFieldKey.onNext { sentKey in
			counter += 1
			if counter >= 6 {
				counterWillReach6.fulfill()
			}
			return .again
		}

        storage.set(hidden: true, at: key)
        storage.set(hidden: false, at: key)
        storage.set(hidden: true, at: key)
        storage.set(hidden: true, at: key)
        storage.set(hidden: false, at: key)
        storage.set(hidden: true, at: key)
        storage.set(hidden: true, at: key)
        storage.set(hidden: true, at: key)
        storage.set(hidden: false, at: key)
        storage.set(hidden: false, at: key)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
