//
//  UTType+FileBrowser.swift
//  FileBrowser
//
//  Created by Claude on 1/19/26.
//

import UniformTypeIdentifiers

public extension UTType {
	// MARK: - File Viewing

	/// Returns true if FileBrowser can display this file type
	var isViewable: Bool {
		// Check if we have a viewer for this type
		conforms(to: .image) ||
		conforms(to: .movie) ||
		conforms(to: .text) ||
		conforms(to: .json) ||
		conforms(to: .xml) ||
		self == .data  // For hex viewer (DataView)
	}

	// MARK: - Media Type Detection

	/// Returns true if this is an image format
	/// Supports all standard image formats including PNG, JPEG, GIF, TIFF,
	/// HEIC, WebP, AVIF, BMP, ICO, SVG, RAW formats, etc.
	var isImage: Bool {
		conforms(to: .image)
	}

	/// Returns true if this is a video/movie format
	/// Supports all standard video formats including MP4, MOV, AVI, MKV,
	/// WebM, FLV, WMV, MPEG, QuickTime, etc.
	var isMovie: Bool {
		conforms(to: .movie)
	}

	/// Returns true if this is an audio format
	/// Supports all standard audio formats including MP3, AAC, WAV, FLAC,
	/// M4A, OGG, AIFF, etc.
	var isAudio: Bool {
		conforms(to: .audio)
	}
}
