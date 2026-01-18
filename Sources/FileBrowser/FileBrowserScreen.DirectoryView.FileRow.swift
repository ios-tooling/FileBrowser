//
//  FileBrowserScreen.DirectoryView.FileRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserScreen.DirectoryView {
	struct FileRow: View {
		let directory: FileBrowserDirectory
		@Environment(\.fileBrowserOptions) var fileBrowserOptions
		@Environment(\.fileHandlerForFile) var fileHandler

		var body: some View {
			ZStack {
				NavigationLink(value: directory.url) { EmptyView() }.opacity(0)
				HStack {
					Image(systemName: "folder")
						.imageScale(.small)
						.opacity(0.0)

					if let view = fileHandler(directory, .list) {
						view
					}
					Text(directory.filename)

					Spacer()

					if directory.isFile {
						let size = directory.url.fileSize

						Spacer()

						Text(size.bytesString)
							.font(.caption)
							.opacity(0.66)

						ShareFileButton(directory: directory)
						ViewFileButton(directory: directory)
					}
				}
				.buttonStyle(.plain)
				.contentShape(Rectangle())
			}
		}
	}
}
