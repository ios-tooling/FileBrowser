//
//  FileBrowserScreen.DirectoryView.DirectoryRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserScreen.DirectoryView {
	struct DirectoryRow: View {
		let url: any FileBrowserDirectory
		@Environment(\.fileHandlerForFile) var fileHandler

		var body: some View {
			NavigationLink(value: url) {
				HStack {
					Image(systemName: "folder")
						.imageScale(.small)
						.opacity(0.5)
					
					if let view = fileHandler(url, .list) {
						view
					}
					Text(url.filename)
					
					Spacer()
					
					if url.isFile {
						let size = url.directoryURL.fileSize
						
						Spacer()
						
						Text(size.bytesString)
							.font(.caption)
							.opacity(0.66)
					}
					
					ShareFileButton(url: url)
						.frame(width: 1)
						.opacity(0)
				}
				.contentShape(Rectangle())
			}
		}
	}
}
