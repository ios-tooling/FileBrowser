//
//  FileBrowser.FileDetailsView.ContentsView.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/4/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Suite

extension FileBrowserView.FileDetailsView {
	struct ContentsView: View {
		let url: URL
		let fileType: UTType

		init(url: URL) {
			self.url = url
			fileType = url.fileType ?? .data
		}
		

		var body: some View {
			ScrollView {
				VStack {
					switch fileType {
					case .json:
						Text((try? Data(contentsOf: url).prettyPrintedJSON) ?? "Unable to display")
												
					case .text, .xml, .xmlPropertyList:
						Text((try? String(contentsOf: url)) ?? "Unable to display")
						
					default:
						Text("\(fileType.description)")

						Text(url.displayed?.prettyPrinted ?? "Unable to display")
					}
				}
				.multilineTextAlignment(.leading)
				.font(.system(size: 14).monospaced())
			}
		}
	}
}

fileprivate extension URL {
	var displayed: JSONDictionary? {
		guard let data = try? Data(contentsOf: self) else { return nil }
		let json = data.jsonDictionary ?? data.propertyList?.jsonDictionary
		return json
	}
}
