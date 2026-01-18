//
//  ShareFileButton.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Suite

struct ShareFileButton: View {
	let directory: FileBrowserDirectory
	@Environment(\.fileBrowserOptions) var fileBrowserOptions

	var body: some View {
		if fileBrowserOptions.contains(.allowFileSharing) {
			ShareLink(item: directory.url) {
				Image(systemName: "square.and.arrow.up")
					.padding(5)
			}
		}
	}
}
