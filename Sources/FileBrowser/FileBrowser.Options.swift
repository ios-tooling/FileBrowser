//
//  FileBrowser.Options.swift
//
//
//  Created by Ben Gottlieb on 12/24/23.
//

import Foundation
import SwiftUI

struct FileBrowserOptionsEnvironmentKey: EnvironmentKey {
	static var defaultValue: FileBrowserViewOption = []
}

extension EnvironmentValues {
	var fileBrowserOptions: FileBrowserViewOption {
		get { self[FileBrowserOptionsEnvironmentKey.self] }
		set { self[FileBrowserOptionsEnvironmentKey.self] = newValue }
	}
}

public struct FileBrowserViewOption: RawRepresentable, OptionSet {
	public let rawValue: Int
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	public static let allowFileDeletion = FileBrowserViewOption(rawValue: 1 << 0)
	public static let allowFileSharing = FileBrowserViewOption(rawValue: 1 << 1)
	public static let showClearDirectoryButton = FileBrowserViewOption(rawValue: 1 << 2)
	public static let showHiddenFiles = FileBrowserViewOption(rawValue: 1 << 3)
	
}
