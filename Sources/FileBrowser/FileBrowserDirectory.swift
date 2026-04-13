//
//  FileBrowserDirectory.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Foundation

public struct FileBrowserDirectory: Identifiable, Equatable, Hashable, Sendable {
	public let url: URL
	public let title: String

	public var id: URL { url }
	public var filename: String { url.lastPathComponent }
	public var isFile: Bool { url.isFile }
	public var isDirectory: Bool { url.isDirectory }

	public init(url: URL, title: String? = nil) {
		self.url = url
		self.title = title ?? url.deletingPathExtension().lastPathComponent
	}

	public static func == (lhs: Self, rhs: Self) -> Bool { lhs.url == rhs.url }
	public func hash(into hasher: inout Hasher) { hasher.combine(url) }
}

// Convenience extension for URL conversion
public extension URL {
	var fileDirectory: FileBrowserDirectory {
		FileBrowserDirectory(url: self)
	}
}
