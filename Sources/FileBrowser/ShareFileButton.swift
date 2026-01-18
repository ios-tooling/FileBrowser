//
//  ShareFileButton.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Suite

struct ShareFileButton: View {
	let url: any FileBrowserDirectory
	@Environment(\.fileBrowserOptions) var fileBrowserOptions
	
	var body: some View {
		if fileBrowserOptions.contains(.allowFileSharing) {
			ShareLink(item: url.directoryURL) {
				Image(systemName: "square.and.arrow.up")
					.padding(5)
			}
		}
	}
}
