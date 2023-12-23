//
//  FileBrowserView.DirectoryView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

struct DirectoryItem: Comparable, Identifiable, Hashable {
	let url: URL
	let filename: String
	var id: URL { url }
	
	func hash(into hasher: inout Hasher) {
		url.hash(into: &hasher)
	}
	
	var isFile: Bool { url.isFile }
	
	init(url: URL) {
		self.url = url
		self.filename = url.lastPathComponent.lowercased()
	}
	
	static func <(lhs: Self, rhs: Self) -> Bool {
		if lhs.filename.hasPrefix(".") {
			if !rhs.filename.hasPrefix(".") { return false }
		} else if rhs.filename.hasPrefix(".") {
			return true
		}
		
		return lhs.filename < rhs.filename

	}
}

extension FileBrowserView {
	@MainActor struct DirectoryView: View {
		let url: URL
		@State var errors: [Error] = []
		@Environment(\.dismissParent) private var dismissParent
		@State var items: [DirectoryItem]?

		init(url: URL) {
			self.url = url
		}
		
		var body: some View {
			VStack {
				if errors.isNotEmpty {
					ForEach(errors.indices, id: \.self) { idx in
						let error = errors[idx]
						Text(error.localizedDescription)
							.padding()
					}
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
										try FileManager.default.removeItem(at: item.url)
									} catch {
										errors.append(error)
									}
								}
								
							}
						}
						.listStyle(.plain)
					} else {
						Text("Loading…")
							.opacity(0.5)
					}
				}
			}
			.task {
				Task.detached {
					do {
						let items = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: URLResourceKey.propertiesOfInterest).map { DirectoryItem(url: $0) }.sorted()
						
						await MainActor.run { self.items = items }
					} catch {
						await MainActor.run { errors = [error] } 
					}
				}
			}
			.navigationTitle(url.lastPathComponent)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(action: { dismissParent() }) {
						Image(systemName: "chevron.down")
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
