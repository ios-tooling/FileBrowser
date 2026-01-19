//
//  FileBrowserScreen.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

public enum FileBrowserButtonPlacement { case list, details }
struct FileHandlerForFileEnvironmentKey: EnvironmentKey {
	static let defaultValue: (FileBrowserDirectory, FileBrowserButtonPlacement) -> AnyView? = { _, _ in nil }
}

extension EnvironmentValues {
	var fileHandlerForFile: (FileBrowserDirectory, FileBrowserButtonPlacement) -> AnyView? {
		get { self[FileHandlerForFileEnvironmentKey.self] }
		set { self[FileHandlerForFileEnvironmentKey.self] = newValue }
	}
}

public struct FileBrowserScreen<FileHandlerView: View>: View {
	private let roots: [FileBrowserDirectory]
	@State private var root: FileBrowserDirectory
	@State private var directoryPath = NavigationPath()
	@Environment(\.presentationMode) var presentationMode
	let fileBrowersOptions: FileBrowserViewOption
	@ViewBuilder var fileHandlerForFile: (FileBrowserDirectory, FileBrowserButtonPlacement) -> FileHandlerView

	public init(root: FileBrowserDirectory, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing], @ViewBuilder fileHandler: @escaping (FileBrowserDirectory, FileBrowserButtonPlacement) -> FileHandlerView) {
		roots = [root]
		_root = State(initialValue: root)
		fileBrowersOptions = options
		fileHandlerForFile = fileHandler

		if let current, current.isSubdirectory(of: root.url), let components = current.componentDirectoryURLs {
			_directoryPath = State(initialValue: NavigationPath(components))
		}
	}
	
	public init(roots: [FileBrowserDirectory], current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing], @ViewBuilder fileHandler: @escaping (FileBrowserDirectory, FileBrowserButtonPlacement) -> FileHandlerView) {
		let actual = roots.isEmpty ? [FileBrowserDirectory(url: .homeDirectory)] : roots
		self.roots = actual
		_root = State(initialValue: actual[0])
		fileBrowersOptions = options
		fileHandlerForFile = fileHandler

		if let current, current.isSubdirectory(of: actual[0].url), let components = current.componentDirectoryURLs {
			_directoryPath = State(initialValue: NavigationPath(components))
		}
	}
	
	public var body: some View {
		NavigationStack(path: $directoryPath) {
			VStack(spacing: 0) {
				if roots.count > 0 { DirectoryTabs(tabs: roots, root: $root) }
				DirectoryView(directory: root)
					.navigationDestination(for: URL.self) { url in
						if url.isDirectory {
							DirectoryView(directory: FileBrowserDirectory(url: url))
						} else {
							FileDetailsView(url: url)
						}
					}
					#if os(iOS)
						.navigationBarTitleDisplayMode(.inline)
					#endif
			}
		}
		.frame(minWidth: Gestalt.isOnMac ? 600 : 300, minHeight: 500)
		.environment(\.dismissParent) { presentationMode.wrappedValue.dismiss() }
		.environment(\.fileBrowserOptions, fileBrowersOptions)
		.environment(\.fileHandlerForFile) { directory, placement in
			FileHandlerView.self == EmptyView.self ? nil : AnyView(fileHandlerForFile(directory, placement))
		}

	}
}

extension FileBrowserScreen where FileHandlerView == EmptyView {
	public init(root: FileBrowserDirectory, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing]) {
		self.init(root: root, current: current, options: options) { _, _ in EmptyView() }
	}

	public init(roots: [FileBrowserDirectory], current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing]) {
		self.init(roots: roots, current: current, options: options) { _, _ in EmptyView() }
	}

	// Convenience initializers for URL
	public init(rootURL: URL, current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing]) {
		self.init(root: FileBrowserDirectory(url: rootURL), current: current, options: options) { _, _ in EmptyView() }
	}

	public init(rootURLs: [URL], current: URL? = nil, options: FileBrowserViewOption = [.showHiddenFiles, .allowFileSharing, .allowFileDeletion, .allowFileViewing]) {
		self.init(roots: rootURLs.map { FileBrowserDirectory(url: $0) }, current: current, options: options) { _, _ in EmptyView() }
	}
}

//extension FileBrowserScreen where FileBrowserScreen == EmptyView {
//	public static var appBundle: some View { FileBrowserScreen(root: Bundle.main.bundleURL) { _ in EmptyView() } }
//	public static var home: some View { FileBrowserScreen(root: URL.homeDirectory) { _ in EmptyView() } }
//	public static var root: some View { FileBrowserScreen(root: URL(fileURLWithPath: "/"), current: .homeDirectory) { _ in EmptyView() } }
//}
