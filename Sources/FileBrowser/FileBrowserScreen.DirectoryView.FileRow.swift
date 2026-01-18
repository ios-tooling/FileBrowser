//
//  FileBrowserScreen.DirectoryView.FileRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserScreen.DirectoryView {
	struct FileRow: View {
		let url: any FileBrowserDirectory
		@Environment(\.fileBrowserOptions) var fileBrowserOptions
		@Environment(\.fileHandlerForFile) var fileHandler

		func shareFile() {
			
		}
		
		var body: some View {
			ZStack {
				NavigationLink(value: url) { EmptyView() }.opacity(0)
				HStack {
					Image(systemName: "folder")
						.imageScale(.small)
						.opacity(0.0)
					
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
						
						ShareFileButton(url: url)
					}
				}
				.buttonStyle(.plain)
				.contentShape(Rectangle())
			}
		}
	}
}
