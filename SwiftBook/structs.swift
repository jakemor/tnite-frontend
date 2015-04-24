//
//  structs.swift
//  SwiftBook
//
//  Created by Jake Mor on 4/20/15.
//  Copyright (c) 2015 Brian Coleman. All rights reserved.
//

import Foundation

struct Set<T: Hashable> {
	typealias Element = T
	private var contents: [Element: Bool]
	
	init() {
		self.contents = [Element: Bool]()
	}
 
	/// The number of elements in the Set.
	var count: Int { return contents.count }
	
	/// Returns `true` if the Set is empty.
	var isEmpty: Bool { return contents.isEmpty }
	
	/// The elements of the Set as an array.
	var elements: [Element] { return Array(self.contents.keys) }
 
	/// Returns `true` if the Set contains `element`.
	func contains(element: Element) -> Bool {
		return contents[element] ?? false
	}
	
	/// Add `newElements` to the Set.
	mutating func add(newElements: Element...) {
		newElements.map { self.contents[$0] = true }
	}
	
	/// Remove `element` from the Set.
	mutating func remove(element: Element) -> Element? {
		return contents.removeValueForKey(element) != nil ? element : nil
	}
}