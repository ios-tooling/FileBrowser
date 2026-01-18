//
//  FileBrowserScreen.DirectoryView.DirectoryRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserScreen.DirectoryView {
	struct DirectoryRow: View {
		let url: FileBrowserDirectory
		@Environment(\.fileHandlerForFile) var fileHandler

		var body: some View {
			NavigationLink(value: url) {
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
					}
				}
				.contentShape(Rectangle())
			}
		}
	}
}
