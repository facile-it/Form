import XCTest
import Form
import SwiftCheck
import Functional

class FormStorageSpec: XCTestCase {

	var customObserver: CustomObserver<FieldKey>? = nil
    var optionsObserver: CustomObserver<FieldKey>? = nil

	func testAllKeys() {
		property("'allKeys' is consistent with stored field values") <- forAll { (ap1: ArbitraryPair<OptionalOf<Int>,FieldKey>, ap2: ArbitraryPair<OptionalOf<Int>,FieldKey>, ap3: ArbitraryPair<OptionalOf<Int>,FieldKey>, ap4: ArbitraryPair<OptionalOf<Int>,FieldKey>) in

			let storage = FormStorage()

			let array = [ap1, ap2, ap3, ap4]
				.map { ($0.left.getOptional, $0.right) }

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

		property("'setValue' and 'getValue' should be consistent") <- forAll { (av: OptionalOf<Int>, ak: FieldKey) in
			let optValue = av.getOptional as FieldValue?
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
		let customObserver = CustomObserver<FieldKey>(identifier: "") { sentKey in
			XCTAssertEqual(sentKey, key)
			counter += 1
			if counter >= 6 {
				counterWillReach6.fulfill()
			}
		}
		self.customObserver = customObserver
		storage.addObserver(customObserver)

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
        
        property("'setOptions' and 'getOptions' should be consistent") <- forAll { (ao: OptionalOf<Int>, av: OptionalOf<Int>, ak: FieldKey) in
            storage.set(value: av.getOptional as FieldValue?, at: ak)
            storage.set(options: ao.getOptional, at: ak)
            let optGotOption = storage.getOptions(at: ak)
            if ao.getOptional == nil && optGotOption == nil { return true }
            guard let option = ao.getOptional, let gotOption = optGotOption else { return false }
            guard gotOption is Int else { return false }
            return (gotOption as! Int).isEqual(to: option)
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
        let optionsObserver = CustomObserver<FieldKey>(identifier: "") { sentKey in
            counter += 1
            if counter >= 9 {
                counterWillReach9.fulfill()
            }
        }
        self.optionsObserver = optionsObserver
        storage.addObserver(optionsObserver)
        
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
        
        property("'setHidde' and 'getHidden' should be consistent") <- forAll { (ab: Bool, av: OptionalOf<Int>, ak: FieldKey) in
            storage.set(value: av.getOptional as FieldValue?, at: ak)
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
        let hiddenObserver = CustomObserver<FieldKey>(identifier: "") { sentKey in
            counter += 1
            if counter >= 6 {
                counterWillReach6.fulfill()
            }
        }
        
        storage.addObserver(hiddenObserver)
        
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
