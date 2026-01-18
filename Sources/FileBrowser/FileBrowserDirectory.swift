//
//  FileBrowserDirectory.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Suite

public protocol FileBrowserDirectory: Identifiable, Equatable, Hashable, Sendable {
	var directoryURL: URL { get }
	var directoryTitle: String { get }
}

public extension FileBrowserDirectory {
	var id: URL { directoryURL }
	var filename: String { directoryURL.lastPathComponent }
	
	var isFile: Bool { directoryURL.isFile }
	var isDirectory: Bool { directoryURL.isDirectory }
}

extension URL: FileBrowserDirectory {
	public var directoryURL: URL { self }
	public var directoryTitle: String { deletingPathExtension().lastPathComponent }
}

public struct TitledURL: FileBrowserDirectory, Hashable, Sendable {
	public var directoryURL: URL
	public var directoryTitle: String
	
	public init(url: URL, title: String) {
		self.directoryURL = url
		self.directoryTitle = title
	}
}

public func ==(lhs: any FileBrowserDirectory, rhs: any FileBrowserDirectory) -> Bool {
	lhs.directoryURL == rhs.directoryURL
}
