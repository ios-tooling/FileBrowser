//
//  FileBrowserView.FileDetailsView.swift
//
//  Created by Ben Gottlieb on 9/3/23.
//

import SwiftUI

extension FileBrowserView {
	struct FileDetailsView: View {
		let url: URL
		enum Tab: String { case metadata, content }
		@State var formatDetails: FileBrowserFileFormat?
		
		@AppStorage("file_viewer_tab") private var currentTab = Tab.metadata
		
		var body: some View {
			VStack {
				TabView(selection: $currentTab) {
					MetadataView(url: url)
						.tabItem { Label("Metadata", systemImage: "list.clipboard") }
						.tag(Tab.metadata)
					
					ContentsView(url: url)
						.tabItem { Label("Contents", systemImage: "doc") }
						.tag(Tab.content)

					DataView(url: url)
						.tabItem { Label("Data", systemImage: "doc.text.magnifyingglass") }
						.tag(Tab.content)
					
					if let formatter = fileBrowserViewFormatter(for: url.pathExtension), let formatDetails {
						formatDetails.contentView
							.tabItem { Label(formatter.name, systemImage: "eye") }
							.tag(Tab.content)
					}
				}
			}
			.navigationTitle(url.lastPathComponent)
			.onAppear {
				if let formatter = fileBrowserViewFormatter(for: url.pathExtension) {
					do {
						formatDetails = try formatter.init(url: url)
					} catch {
						print("Unable to parse \(url.lastPathComponent) for \(formatter)")
					}
				}
			}
		}

		var content: some View {
			Text("Content")
		}
	}
}
