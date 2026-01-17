//
//  FileBrowserScreen.FileFormat.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/11/23.
//

import Foundation
import SwiftUI

public protocol FileBrowserFileFormat: AnyObject {
	static var fileExtension: String { get }
	static var name: String { get }

	init(url: URL) throws
	
	var contentView: AnyView { get }
}

public var fileBrowserViewFormats: [FileBrowserFileFormat.Type] = []

public func registerFileBrowserView(format: FileBrowserFileFormat.Type) {
	fileBrowserViewFormats.append(format)
}

public func fileBrowserViewFormatter(for fileExtension: String) -> (any FileBrowserFileFormat.Type)? {
	fileBrowserViewFormats.first { $0.fileExtension.lowercased() == fileExtension.lowercased() }
}
