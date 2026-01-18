//
//  FileBrowserScreen.DirectoryView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

struct DirectoryItem: Comparable, Identifiable, Hashable {
	let url: any FileBrowserDirectory
	let filename: String
	var id: URL { url.directoryURL }
	
	func hash(into hasher: inout Hasher) {
		url.hash(into: &hasher)
	}
	
	var isFile: Bool { url.directoryURL.isFile }
	
	init(url: URL) {
		self.url = url
		self.filename = url.directoryURL.lastPathComponent.lowercased()
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
		lhs.url == rhs.url
	}
}

extension FileBrowserScreen {
	@MainActor struct DirectoryView: View {
		let url: any FileBrowserDirectory
		@State var errors: [Error] = []
		@Environment(\.dismissParent) private var dismissParent
		@State var items: [DirectoryItem]?
		@Environment(\.fileBrowserOptions) var fileBrowserOptions
		@State var isLoading = true

		init(url: any FileBrowserDirectory) {
			self.url = url
		}
		
		func clearDirectory() {
			for item in items ?? [] {
				do {
					try FileManager.default.removeItem(at: item.url.directoryURL)
				} catch {
					errors.append(error)
				}
			}
			withAnimation { items = [] }
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
									FileRow(url: item.url)
								} else {
									DirectoryRow(url: item.url)
								}
							}
							.onDelete { indexSet in
								items[indexSet].forEach { item in
									do {
										try FileManager.default.removeItem(at: item.url.directoryURL)
									} catch {
										errors.append(error)
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
						if #available(macOS 14.0, *) {
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
			.task(id: url.directoryURL) {
				Task.detached {
					do {
						let items = try FileManager.default.contentsOfDirectory(at: url.directoryURL, includingPropertiesForKeys: URLResourceKey.propertiesOfInterest).map { DirectoryItem(url: $0) }.sorted()
						
						await MainActor.run { self.items = items }
					} catch {
						await MainActor.run { errors = [error] } 
					}
					await MainActor.run { isLoading = false }
				}
			}
			.navigationTitle(url.directoryURL.lastPathComponent)
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
