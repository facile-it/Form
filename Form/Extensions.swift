import Functional

extension Array: Monoid {
	public static var empty: Array<Element> {
		return []
	}

	public func compose(_ other: Array<Element>) -> Array<Element> {
		var m_self = self
		m_self.append(contentsOf: other)
		return m_self
	}
}

extension Dictionary: Monoid {
	public func compose(_ other: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
		return merged(with: other)
	}

	public static var empty: Dictionary<Key, Value> {
		return [:]
	}
}

extension Optional: Monoid {
	public static var empty: Optional {
		return nil
	}

	public func compose(_ other: Optional) -> Optional {
		return self ?? other
	}
}

extension Array where Element: OptionalType, Element: Monoid {
	var firstOptionalSomeOrNone: Element {
		for element in self {
			if element.isNotNil {
				return element
			}
		}
		return Element.empty
	}
}
