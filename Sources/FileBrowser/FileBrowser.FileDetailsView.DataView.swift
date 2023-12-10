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
	struct DataView: View {
		let data: Data
		let url: URL
		
		let bytesPerRow: Int
		let visibleRows: Int

		init(url: URL) {
			self.url = url
			self.data = (try? Data(contentsOf: url)) ?? Data()
			self.bytesPerRow = 12
			
			let fullRows = data.count / bytesPerRow
			self.visibleRows = fullRows + (data.count % 16 == 0 ? 0 : 1)
		}
		
		
		var body: some View {
			ScrollView {
				LazyVStack {
					ForEach(0..<visibleRows, id: \.self) { row in
						HStack {
							Text("\(row + 1)")
								.bold()
								.frame(width: 20)
								.minimumScaleFactor(0.5)
							
							let rowData = data.subdata(in: (row * bytesPerRow)..<(min((row + 1) * bytesPerRow, data.count)))
							Text(rowData.hexString)
								.padding(.trailing, 5)

							Text(String(data: rowData, encoding: .ascii) ?? "")

							Spacer()
						}
					}
				}
				.multilineTextAlignment(.leading)
				.font(.system(size: 14).monospaced())
				.lineLimit(1)
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
