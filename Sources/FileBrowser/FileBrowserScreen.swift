//
//  FileBrowserScreen.swift
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

public struct FileBrowserScreen<FileHandlerView: View>: View {
	private let roots: [URL]
	@State private var root: URL
	@State private var directoryPath = NavigationPath()
	@Environment(\.presentationMode) var presentationMode
	let fileBrowersOptions: FileBrowserViewOption
	@ViewBuilder var fileHandlerForFile: (URL, FileBrowserButtonPlacement) -> FileHandlerView

	public init(root url: URL, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion], @ViewBuilder fileHandler: @escaping (URL, FileBrowserButtonPlacement) -> FileHandlerView) {
		roots = [url]
		_root = State(initialValue: url)
		fileBrowersOptions = options
		fileHandlerForFile = fileHandler
		
		if let current, current.isSubdirectory(of: url), let components = current.componentDirectoryURLs {
			_directoryPath = State(initialValue: NavigationPath(components))
		}
	}
	
	public init(root urls: [URL], current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion], @ViewBuilder fileHandler: @escaping (URL, FileBrowserButtonPlacement) -> FileHandlerView) {
		roots = urls
		_root = State(initialValue: urls[0])
		fileBrowersOptions = options
		fileHandlerForFile = fileHandler
		
		if let current, current.isSubdirectory(of: urls[0]), let components = current.componentDirectoryURLs {
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
		.frame(minWidth: 300, minHeight: 500)
		.environment(\.dismissParent) { presentationMode.wrappedValue.dismiss() }
		.environment(\.fileBrowserOptions, fileBrowersOptions)
		.environment(\.fileHandlerForFile) { url, placement in
			FileHandlerView.self == EmptyView.self ? nil : AnyView(fileHandlerForFile(url, placement))
		}

	}
}

extension FileBrowserScreen where FileHandlerView == EmptyView {
	public init(root url: URL, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion]) {
		
		self.init(root: url, current: current, options: options) { _, _ in EmptyView() }
	}
	
	public init(root urls: [URL], current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion]) {
		
		self.init(root: urls, current: current, options: options) { _, _ in EmptyView() }
	}
}

//extension FileBrowserScreen where FileBrowserScreen == EmptyView {
//	public static var appBundle: some View { FileBrowserScreen(root: Bundle.main.bundleURL) { _ in EmptyView() } }
//	public static var home: some View { FileBrowserScreen(root: URL.homeDirectory) { _ in EmptyView() } }
//	public static var root: some View { FileBrowserScreen(root: URL(fileURLWithPath: "/"), current: .homeDirectory) { _ in EmptyView() } }
//}
