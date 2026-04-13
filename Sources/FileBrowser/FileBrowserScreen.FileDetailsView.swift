//
//  FileBrowserScreen.FileDetailsView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI
import FileViewer

extension FileBrowserScreen {
	struct FileDetailsView: View {
		let url: URL

		var body: some View {
			FileViewer(url: url)
		}
	}
}
