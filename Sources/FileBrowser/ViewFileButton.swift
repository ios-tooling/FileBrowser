//
//  ViewFileButton.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Suite
import UniformTypeIdentifiers

struct ViewFileButton: View {
	let directory: FileBrowserDirectory
	@Environment(\.fileBrowserOptions) var fileBrowserOptions
	@State private var isViewing = false

	var body: some View {
		if fileBrowserOptions.contains(.allowFileViewing), directory.url.fileType?.isViewable == true {
			Button(action: { isViewing.toggle() }) {
				Image(systemName: "eye")
					.padding(5)
			}
			.sheet(isPresented: $isViewing) {
				FileContentsView(url: directory.url)
					.frame(minWidth: 400, minHeight: 400)
			}
		}
	}
}

extension UTType {
	var isViewable: Bool {
		// Only show "View" button for file types we can actually display
		conforms(to: .image) ||
		conforms(to: .movie) ||
		conforms(to: .text) ||
		conforms(to: .json) ||
		conforms(to: .xml) ||
		self == .data  // For hex viewer (DataView)
	}
}
