//
//  FileBrowserScreen.FileFormat.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/11/23.
//

import Foundation
import SwiftUI
import FileViewer

public typealias FileBrowserFileFormat = FileViewerFormat

public func registerFileBrowserView(format: FileBrowserFileFormat.Type) {
	registerFileViewer(format: format)
}
