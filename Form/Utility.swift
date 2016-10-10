extension Collection {
	func get(at index: Index) -> Iterator.Element? {
		guard indices.contains(where: {
			guard let current = $0 as? Index else { return false }
			return current == index
		}) else { return nil }
		return self[index]
	}
}
