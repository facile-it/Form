import Foundation
import SwiftCheck
import Form
import JSONObject

struct ArbitraryPair<A: Arbitrary, B: Arbitrary>: Arbitrary {
	let left: A
	let right: B
	init(left: A, right: B) {
		self.left = left
		self.right = right
	}

	static var arbitrary: Gen<ArbitraryPair<A, B>> {
		return Gen<(A,B)>
			.zip(A.arbitrary, B.arbitrary)
			.map { ArbitraryPair(left: $0.0, right: $0.1) }
	}
}

extension FieldAction {
	public func isEqual(to other: FieldAction) -> (Value?) -> Bool {
		return { optValue in

			let storage1 = FormStorage()
			let storage2 = FormStorage()

			self.apply(value: optValue, storage: storage1)
			other.apply(value: optValue, storage: storage2)

			return storage1.hasSameFieldValuesAndHiddenFieldKeys(of: storage2)
		}
	}
}

extension FieldAction: Arbitrary {
	public static var arbitrary: Gen<FieldAction<Value>> {
		return Gen<(FieldKey,Bool)>
			.zip(FieldKey.arbitrary, Bool.arbitrary)
			.map { (key,hidden) in
				FieldAction { (optValue,storage) in
					storage.set(value: optValue, at: key)
					storage.set(hidden: hidden, at: key)
				}
		}
	}
}

func optFieldValuesAreEqual(_ optFirst: FieldValue?, _ optSecond: FieldValue?) -> Bool {
	if optFirst == nil && optSecond == nil { return true }
	guard let first = optFirst, let second = optSecond else { return false }
	return first.isEqual(to: second)
}

extension Date: Arbitrary {
    public static var arbitrary: Gen<Date> {
        return Gen<Date>.pure(Date.init())
    }
}

struct ArbitraryFieldValue: Arbitrary, CustomStringConvertible {
    
    let get: FieldValue
    var description: String
    
    init(value: FieldValue) {
        self.get = value
        self.description = ""
    }
    
    static var arbitrary: Gen<ArbitraryFieldValue> {
        return Gen.one(of: [Int.arbitrary.map(ArbitraryFieldValue.init),
                            String.arbitrary.map(ArbitraryFieldValue.init),
                            Bool.arbitrary.map(ArbitraryFieldValue.init),
                            Date.arbitrary.map(ArbitraryFieldValue.init)])
    }
}
