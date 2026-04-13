//
//  FileBrowserDirectoryTests.swift
//  FileBrowserTests
//

import Testing
import Foundation
@testable import FileBrowser

@Suite("FileBrowserDirectory")
struct FileBrowserDirectoryTests {
	@Test("Title defaults to last path component without extension")
	func defaultTitle() {
		let dir = FileBrowserDirectory(url: URL(fileURLWithPath: "/tmp/MyFile.txt"))
		#expect(dir.title == "MyFile")
	}

	@Test("Custom title overrides default")
	func customTitle() {
		let dir = FileBrowserDirectory(url: URL(fileURLWithPath: "/tmp/MyFile.txt"), title: "Custom Name")
		#expect(dir.title == "Custom Name")
	}

	@Test("id is the URL")
	func idIsURL() {
		let url = URL(fileURLWithPath: "/tmp/test.txt")
		#expect(FileBrowserDirectory(url: url).id == url)
	}

	@Test("filename is lastPathComponent")
	func filename() {
		let dir = FileBrowserDirectory(url: URL(fileURLWithPath: "/a/b/c/file.json"))
		#expect(dir.filename == "file.json")
	}

	@Test("Equality depends only on URL, not title")
	func equalityIgnoresTitle() {
		let url = URL(fileURLWithPath: "/tmp/test.txt")
		let dir1 = FileBrowserDirectory(url: url, title: "Title A")
		let dir2 = FileBrowserDirectory(url: url, title: "Title B")
		#expect(dir1 == dir2)
	}

	@Test("Different URLs are not equal")
	func inequalityForDifferentURLs() {
		let dir1 = FileBrowserDirectory(url: URL(fileURLWithPath: "/tmp/a.txt"))
		let dir2 = FileBrowserDirectory(url: URL(fileURLWithPath: "/tmp/b.txt"))
		#expect(dir1 != dir2)
	}

	@Test("URL.fileDirectory convenience creates directory with correct URL")
	func urlConvenience() {
		let url = URL(fileURLWithPath: "/tmp/test.txt")
		#expect(url.fileDirectory.url == url)
	}

	@Test("isDirectory is true for a real directory")
	func isDirectoryForRealDirectory() throws {
		let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
		defer { try? FileManager.default.removeItem(at: tempDir) }

		let dir = FileBrowserDirectory(url: tempDir)
		#expect(dir.isDirectory == true)
		#expect(dir.isFile == false)
	}

	@Test("isFile is true for a real file")
	func isFileForRealFile() throws {
		let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".txt")
		try "hello".write(to: tempFile, atomically: true, encoding: .utf8)
		defer { try? FileManager.default.removeItem(at: tempFile) }

		let dir = FileBrowserDirectory(url: tempFile)
		#expect(dir.isFile == true)
		#expect(dir.isDirectory == false)
	}
}
