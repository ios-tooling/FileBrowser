//
//  DirectoryTabs.swift
//  FileBrowser
//
//  Created by Ben Gottlieb on 1/18/26.
//

import Suite

struct DirectoryTabs: View {
	let tabs: [FileBrowserDirectory]
	@Binding var root: FileBrowserDirectory

	var body: some View {
		HStack {
			ForEach(tabs, id: \.id) { tab in
				let isSelected = tab == root
				Button(action: { root = tab }) {
					Text(tab.title)
						.overlay(alignment: .bottom) {
							if isSelected {
								Rectangle()
									.fill(.primary)
									.frame(height: 2)
							}
						}
						.padding(8)
						.bold(isSelected)
						.background {
							if !isSelected {
								Rectangle()
									.fill(.quinary)
							}
						}
						.padding(.bottom, 2)
				}
			}
			.buttonStyle(.plain)

			Spacer()
		}
		.padding(.horizontal)
		.padding(.bottom, 2)
	}
}
