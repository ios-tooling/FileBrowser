//
//  FileBrowser.Options.swift
//
//
//  Created by Ben Gottlieb on 12/24/23.
//

import Foundation
import SwiftUI

struct FileBrowserOptionsEnvironmentKey: EnvironmentKey {
	static var defaultValue: FileBrowserView.Option = []
}

extension EnvironmentValues {
	var fileBrowserOptions: FileBrowserView.Option {
		get { self[FileBrowserOptionsEnvironmentKey.self] }
		set { self[FileBrowserOptionsEnvironmentKey.self] = newValue }
	}
}

extension FileBrowserView {
	public struct Option: RawRepresentable, OptionSet {
		public let rawValue: Int
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		public static let allowFileDeletion = Option(rawValue: 1 << 0)
		public static let allowFileSharing = Option(rawValue: 1 << 1)
		public static let showClearDirectoryButton = Option(rawValue: 1 << 2)
		public static let showHiddenFiles = Option(rawValue: 1 << 3)
		
	}
}
