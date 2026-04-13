//
//  UTTypeFileBrowserTests.swift
//  FileBrowserTests
//

import Testing
import UniformTypeIdentifiers
@testable import FileBrowser

@Suite("UTType+FileBrowser")
struct UTTypeFileBrowserTests {
	// MARK: - isViewable

	@Test("Common image types are viewable", arguments: [UTType.png, .jpeg, .gif, .tiff, .heic])
	func imagesAreViewable(type: UTType) {
		#expect(type.isViewable)
	}

	@Test("Common movie types are viewable", arguments: [UTType.mpeg4Movie, .quickTimeMovie])
	func moviesAreViewable(type: UTType) {
		#expect(type.isViewable)
	}

	@Test("Plain text is viewable")
	func plainTextIsViewable() {
		#expect(UTType.plainText.isViewable)
	}

	@Test("JSON is viewable")
	func jsonIsViewable() {
		#expect(UTType.json.isViewable)
	}

	@Test("XML is viewable")
	func xmlIsViewable() {
		#expect(UTType.xml.isViewable)
	}

	@Test("Raw data type is viewable (for hex viewer)")
	func dataIsViewable() {
		#expect(UTType.data.isViewable)
	}

	// MARK: - isImage / isMovie / isAudio

	@Test("PNG is an image, not a movie or audio")
	func pngIsImage() {
		#expect(UTType.png.isImage)
		#expect(!UTType.png.isMovie)
		#expect(!UTType.png.isAudio)
	}

	@Test("MP4 is a movie, not an image or audio")
	func mp4IsMovie() {
		#expect(UTType.mpeg4Movie.isMovie)
		#expect(!UTType.mpeg4Movie.isImage)
		#expect(!UTType.mpeg4Movie.isAudio)
	}

	@Test("MP3 is audio, not an image or movie")
	func mp3IsAudio() {
		#expect(UTType.mp3.isAudio)
		#expect(!UTType.mp3.isImage)
		#expect(!UTType.mp3.isMovie)
	}

	@Test("M4A is audio")
	func m4aIsAudio() {
		#expect(UTType.mpeg4Audio.isAudio)
	}

	@Test("JPEG is an image")
	func jpegIsImage() {
		#expect(UTType.jpeg.isImage)
	}
}
