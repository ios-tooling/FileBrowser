//
//  FileBrowserView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

public struct FileBrowserView: View {
	private let root: URL
	@State private var directoryPath = NavigationPath()
	@Environment(\.presentationMode) var presentationMode

	public init(root url: URL, current: URL? = nil) {
		root = url
		
		if let current, current.isSubdirectory(of: root), let components = current.componentDirectoryURLs {
			_directoryPath = State(initialValue: NavigationPath(components))
		}
	}
	
	public var body: some View {
		NavigationStack(path: $directoryPath) {
			DirectoryView(url: root)
				.navigationDestination(for: URL.self) { url in
					if url.isDirectory {
						DirectoryView(url: url)
					} else {
						FileDetailsView(url: url)
					}
				}
			#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
		}
		.environment(\.dismissParent) { presentationMode.wrappedValue.dismiss() }

	}
}

extension FileBrowserView {
	public static var appBundle: some View { FileBrowserView(root: Bundle.main.bundleURL) }
	public static var home: some View { FileBrowserView(root: URL.homeDirectory) }
	public static var root: some View { FileBrowserView(root: URL(fileURLWithPath: "/"), current: .homeDirectory) }
}
