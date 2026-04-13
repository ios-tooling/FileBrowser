//
//  FileBrowserViewOptionTests.swift
//  FileBrowserTests
//

import Testing
@testable import FileBrowser

@Suite("FileBrowserViewOption")
struct FileBrowserViewOptionTests {
	@Test("Empty option set contains no options")
	func emptySet() {
		let options: FileBrowserViewOption = []
		#expect(!options.contains(.allowFileDeletion))
		#expect(!options.contains(.allowFileSharing))
		#expect(!options.contains(.showClearDirectoryButton))
		#expect(!options.contains(.showHiddenFiles))
		#expect(!options.contains(.allowFileViewing))
	}

	@Test("Single option is contained")
	func singleOption() {
		let options: FileBrowserViewOption = [.allowFileDeletion]
		#expect(options.contains(.allowFileDeletion))
		#expect(!options.contains(.allowFileSharing))
	}

	@Test("Multiple options can be combined and individually detected")
	func combinedOptions() {
		let options: FileBrowserViewOption = [.allowFileDeletion, .allowFileSharing, .allowFileViewing]
		#expect(options.contains(.allowFileDeletion))
		#expect(options.contains(.allowFileSharing))
		#expect(options.contains(.allowFileViewing))
		#expect(!options.contains(.showHiddenFiles))
		#expect(!options.contains(.showClearDirectoryButton))
	}

	@Test("All options have distinct raw values")
	func distinctRawValues() {
		let all: [FileBrowserViewOption] = [
			.allowFileDeletion, .allowFileSharing,
			.showClearDirectoryButton, .showHiddenFiles, .allowFileViewing,
		]
		let rawValues = all.map(\.rawValue)
		#expect(Set(rawValues).count == all.count)
	}

	@Test("Union and intersection work correctly")
	func setOperations() {
		let a: FileBrowserViewOption = [.allowFileDeletion, .allowFileSharing]
		let b: FileBrowserViewOption = [.allowFileSharing, .allowFileViewing]
		#expect(a.union(b).contains(.allowFileDeletion))
		#expect(a.union(b).contains(.allowFileViewing))
		#expect(a.intersection(b) == [.allowFileSharing])
	}
}
