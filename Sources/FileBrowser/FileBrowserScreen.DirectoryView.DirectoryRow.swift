//
//  FileBrowserScreen.DirectoryView.DirectoryRow.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import Suite

extension FileBrowserScreen.DirectoryView {
	struct DirectoryRow: View {
		let directory: FileBrowserDirectory
		@Environment(\.fileHandlerForFile) var fileHandler

		var body: some View {
			NavigationLink(value: directory.url) {
				HStack {
					Image(systemName: "folder")
						.imageScale(.small)
						.opacity(0.5)

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
					}

					ShareFileButton(directory: directory)
						.frame(width: 1)
						.opacity(0)
				}
				.contentShape(Rectangle())
			}
		}
	}
}
