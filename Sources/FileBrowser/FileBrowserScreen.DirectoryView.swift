//
//  FileBrowserScreen.DirectoryView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

struct DirectoryItem: Comparable, Identifiable, Hashable {
	let directory: FileBrowserDirectory
	let filename: String
	var id: URL { directory.url }

	func hash(into hasher: inout Hasher) {
		directory.hash(into: &hasher)
	}

	var isFile: Bool { directory.isFile }

	init(directory: FileBrowserDirectory) {
		self.directory = directory
		self.filename = directory.url.lastPathComponent.lowercased()
	}

	static func <(lhs: Self, rhs: Self) -> Bool {
		if lhs.filename.hasPrefix(".") {
			if !rhs.filename.hasPrefix(".") { return false }
		} else if rhs.filename.hasPrefix(".") {
			return true
		}

		return lhs.filename < rhs.filename
	}

	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.directory == rhs.directory
	}
}

extension FileBrowserScreen {
	@MainActor struct DirectoryView: View {
		let directory: FileBrowserDirectory
		@State var errors: [Error] = []
		@Environment(\.dismissParent) private var dismissParent
		@State var items: [DirectoryItem]?
		@Environment(\.fileBrowserOptions) var fileBrowserOptions
		@State var isLoading = true

		init(directory: FileBrowserDirectory) {
			self.directory = directory
		}
		
		func clearDirectory() {
			var deletionErrors: [Error] = []

			for item in items ?? [] {
				do {
					try FileManager.default.removeItem(at: item.directory.url)
				} catch {
					deletionErrors.append(error)
				}
			}

			// Reload directory to reflect actual filesystem state
			Task {
				do {
					let urls = try FileManager.default.contentsOfDirectory(at: directory.url, includingPropertiesForKeys: URLResourceKey.propertiesOfInterest)
					let loadedItems = urls.map { DirectoryItem(directory: FileBrowserDirectory(url: $0)) }.sorted()

					await MainActor.run {
						withAnimation {
							self.items = loadedItems
						}
						// Show errors if any deletions failed
						if !deletionErrors.isEmpty {
							self.errors = deletionErrors
						}
					}
				} catch {
					await MainActor.run {
						self.errors = [error]
					}
				}
			}
		}
		
		var navigationTitle: String {
			if let count = items?.count {
				"\(directory.url.lastPathComponent) (\(count))"
			} else {
				directory.url.lastPathComponent
			}
		}
		
		var body: some View {
			VStack(spacing: 0) {
				if errors.isNotEmpty {
					ForEach(errors.indices, id: \.self) { idx in
						let error = errors[idx]
						Text(error.localizedDescription)
							.padding()
					}
					Button("OK") {
						errors = []
					}
					.buttonStyle(.bordered)
				} else {
					if let items {
						List {
							ForEach(items, id: \.self) { item in
								if item.isFile {
									FileRow(directory: item.directory)
								} else {
									DirectoryRow(directory: item.directory)
								}
							}
								.onDelete { indexSet in
								var deletionErrors: [Error] = []

								items[indexSet].forEach { item in
									do {
										try FileManager.default.removeItem(at: item.directory.url)
									} catch {
										deletionErrors.append(error)
									}
								}

								// Reload directory to reflect actual filesystem state
								Task {
									do {
										let urls = try FileManager.default.contentsOfDirectory(at: directory.url, includingPropertiesForKeys: URLResourceKey.propertiesOfInterest)
										let loadedItems = urls.map { DirectoryItem(directory: FileBrowserDirectory(url: $0)) }.sorted()

										await MainActor.run {
											withAnimation {
												self.items = loadedItems
											}
											// Show errors if any deletions failed
											if !deletionErrors.isEmpty {
												self.errors = deletionErrors
											}
										}
									} catch {
										await MainActor.run {
											self.errors = [error]
										}
									}
								}
							}
							.deleteDisabled(!fileBrowserOptions.contains(.allowFileDeletion))
						}
						.listStyle(.plain)
					} else if isLoading {
						Text("Loading…")
							.opacity(0.5)
					} else {
						if #available(iOS 17, macOS 14.0, *) {
							ContentUnavailableView {
								Image(systemName: "folder")
								Text("Empty Directory")
							}
							.frame(maxHeight: .infinity)
						} else {
							Text("Empty Directory")
								.font(.title)
								.frame(maxHeight: .infinity)
						}
					}
				}
				Spacer(minLength: 0)
			}
			.task(id: directory.url) {
				Task {
					do {
						let urls = try FileManager.default.contentsOfDirectory(at: directory.url, includingPropertiesForKeys: URLResourceKey.propertiesOfInterest)
						let items = urls.map { DirectoryItem(directory: FileBrowserDirectory(url: $0)) }.sorted()

						await MainActor.run {
							self.items = items
							self.isLoading = false
						}
					} catch {
						await MainActor.run {
							self.errors = [error]
							self.isLoading = false
						}
					}
				}
			}
			.navigationTitle(navigationTitle)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(action: { dismissParent() }) {
						Image(systemName: "chevron.down")
					}
				}
				
				if fileBrowserOptions.contains(.showClearDirectoryButton) {
					ToolbarItem(placement: .automatic) {
						Button(action: { clearDirectory() }) {
							Image(systemName: "trash")
						}
					}
				}
			}
		}
	}
}

extension URLResourceKey {
	static var propertiesOfInterest: [URLResourceKey] {
		[.contentTypeKey, .isSymbolicLinkKey, .isPackageKey, .isSystemImmutableKey, .isHiddenKey, .hasHiddenExtensionKey, .creationDateKey, .attributeModificationDateKey, .linkCountKey, .labelColorKey, .isReadableKey, .isWritableKey, .isExecutableKey, .addedToDirectoryDateKey, .fileContentIdentifierKey, .mayHaveExtendedAttributesKey, .fileAllocatedSizeKey, .totalFileSizeKey, .totalFileAllocatedSizeKey, .isAliasFileKey, .ubiquitousItemIsUploadedKey, .ubiquitousItemIsDownloadingKey, .ubiquitousItemUploadingErrorKey, .ubiquitousItemDownloadingErrorKey, .localizedNameKey, .localizedLabelKey, .localizedTypeDescriptionKey, .fileProtectionKey, .canonicalPathKey]
	}
}
