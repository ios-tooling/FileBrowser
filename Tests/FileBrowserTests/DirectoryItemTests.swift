//
//  DirectoryItemTests.swift
//  FileBrowserTests
//

import Testing
import Foundation
@testable import FileBrowser

@Suite("DirectoryItem sorting")
struct DirectoryItemTests {
	private func item(_ name: String) -> DirectoryItem {
		DirectoryItem(directory: FileBrowserDirectory(url: URL(fileURLWithPath: "/tmp/\(name)")))
	}

	@Test("Regular files sort alphabetically")
	func alphabeticalSort() {
		let sorted = [item("zebra.txt"), item("apple.txt"), item("mango.txt")].sorted()
		#expect(sorted.map(\.filename) == ["apple.txt", "mango.txt", "zebra.txt"])
	}

	@Test("Hidden files sort after regular files")
	func hiddenFilesAfterRegular() {
		let sorted = [item(".hidden"), item("visible.txt")].sorted()
		#expect(sorted[0].filename == "visible.txt")
		#expect(sorted[1].filename == ".hidden")
	}

	@Test("Hidden files sort alphabetically among themselves")
	func hiddenFilesSortAlphabetically() {
		let sorted = [item(".zebra"), item(".apple"), item(".mango")].sorted()
		#expect(sorted.map(\.filename) == [".apple", ".mango", ".zebra"])
	}

	@Test("Mixed hidden and regular files sort correctly")
	func mixedSort() {
		let sorted = [item(".hidden"), item("beta.txt"), item(".alpha"), item("alpha.txt")].sorted()
		#expect(sorted.map(\.filename) == ["alpha.txt", "beta.txt", ".alpha", ".hidden"])
	}

	@Test("Filename comparison is case-insensitive")
	func caseInsensitive() {
		let sorted = [item("Zebra.txt"), item("apple.txt")].sorted()
		#expect(sorted[0].filename == "apple.txt")
		#expect(sorted[1].filename == "zebra.txt")
	}

	@Test("Equality is based on URL")
	func equality() {
		let url = URL(fileURLWithPath: "/tmp/file.txt")
		let a = DirectoryItem(directory: FileBrowserDirectory(url: url))
		let b = DirectoryItem(directory: FileBrowserDirectory(url: url))
		#expect(a == b)
	}

	@Test("Items with different URLs are not equal")
	func inequality() {
		let a = item("file1.txt")
		let b = item("file2.txt")
		#expect(a != b)
	}
}
