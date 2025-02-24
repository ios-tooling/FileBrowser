//
//  FileBrowserView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

public enum FileBrowserButtonPlacement { case list, details }
struct FileHandlerForFileEnvironmentKey: EnvironmentKey {
	static let defaultValue: (URL, FileBrowserButtonPlacement) -> AnyView? = { _, _ in nil }
}

extension EnvironmentValues {
	var fileHandlerForFile: (URL, FileBrowserButtonPlacement) -> AnyView? {
		get { self[FileHandlerForFileEnvironmentKey.self] }
		set { self[FileHandlerForFileEnvironmentKey.self] = newValue }
	}
}

public struct FileBrowserView<FileHandlerView: View>: View {
	private let root: URL
	@State private var directoryPath = NavigationPath()
	@Environment(\.presentationMode) var presentationMode
	let fileBrowersOptions: FileBrowserViewOption
	@ViewBuilder var fileHandlerForFile: (URL, FileBrowserButtonPlacement) -> FileHandlerView

	public init(root url: URL, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion], @ViewBuilder fileHandler: @escaping (URL, FileBrowserButtonPlacement) -> FileHandlerView) {
		root = url
		fileBrowersOptions = options
		fileHandlerForFile = fileHandler
		
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
		.environment(\.fileBrowserOptions, fileBrowersOptions)
		.environment(\.fileHandlerForFile) { url, placement in
			FileHandlerView.self == EmptyView.self ? nil : AnyView(fileHandlerForFile(url, placement))
		}

	}
}

extension FileBrowserView where FileHandlerView == EmptyView {
	public init(root url: URL, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion]) {
		
		self.init(root: url, current: current, options: options) { _, _ in EmptyView() }
	}
}

//extension FileBrowserView where FileBrowserView == EmptyView {
//	public static var appBundle: some View { FileBrowserView(root: Bundle.main.bundleURL) { _ in EmptyView() } }
//	public static var home: some View { FileBrowserView(root: URL.homeDirectory) { _ in EmptyView() } }
//	public static var root: some View { FileBrowserView(root: URL(fileURLWithPath: "/"), current: .homeDirectory) { _ in EmptyView() } }
//}
