//
//  FileBrowserView.DirectoryView.FileRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserView.DirectoryView {
	struct FileRow: View {
		let url: URL
		@Environment(\.fileBrowserOptions) var fileBrowserOptions
		@Environment(\.fileHandlerForFile) var fileHandler

		func shareFile() {
			
		}
		
		var body: some View {
			ZStack {
				NavigationLink(value: url) { EmptyView() }.opacity(0)
				HStack {
					if let view = fileHandler(url, .list) {
						view
					}
					Text(url.lastPathComponent)
					
					Spacer()
					
					if url.isFile {
						let size = url.fileSize
						
						Spacer()
						
						Text(size.bytesString)
							.font(.caption)
							.opacity(0.66)
						
						if fileBrowserOptions.contains(.allowFileSharing) {
							ShareLink(item: url) {
								Image(systemName: "square.and.arrow.up")
									.padding(5)
							}
						}
					}
				}
				.buttonStyle(.plain)
				.contentShape(Rectangle())
			}
		}
	}
}
