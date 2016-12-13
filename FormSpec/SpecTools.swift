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

extension Set {
	func isEqual(to other: Set) -> Bool {
		guard count == other.count else { return false }
		for element in self {
			guard other.contains(element) else { return false }
		}
		return true
	}
}
