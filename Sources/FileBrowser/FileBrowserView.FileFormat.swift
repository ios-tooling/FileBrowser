//
//  FileBrowserView.FileFormat.swift
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

public extension FileBrowserView {
	static var formats: [FileBrowserFileFormat.Type] = []
	
	static func register(format: FileBrowserFileFormat.Type) {
		formats.append(format)
	}
	
	static func formatter(for fileExtension: String) -> (any FileBrowserFileFormat.Type)? {
		formats.first { $0.fileExtension.lowercased() == fileExtension.lowercased() }
	}
}
