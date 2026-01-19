//
//  FileBrowser.FileDetailsView.ContentsView.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/4/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Suite

extension FileBrowserScreen.FileDetailsView {
	struct DataView: View {
		let url: URL
		@State private var data: Data?
		@State private var isLoading = true
		@State private var loadError: Error?
		@AppStorage("showHexOffsets") private var showHexOffsets = false

		let bytesPerRow = Gestalt.isOnMac ? 16 : 8
		private let maxDisplaySize = 10 * 1024 * 1024 // 10 MB limit

		init(url: URL) {
			self.url = url
		}
		

		var visibleRows: Int {
			guard let data else { return 0 }
			let fullRows = data.count / bytesPerRow
			return fullRows + (data.count % bytesPerRow == 0 ? 0 : 1)
		}

		var body: some View {
			Group {
				if let loadError {
					VStack(spacing: 16) {
						Image(systemName: "exclamationmark.triangle")
							.font(.largeTitle)
							.foregroundColor(.red)
						Text("Failed to load file")
							.font(.headline)
						Text(loadError.localizedDescription)
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.padding()
				} else if isLoading {
					VStack(spacing: 16) {
						ProgressView()
						Text("Loading...")
							.foregroundColor(.secondary)
					}
				} else if let data {
					ScrollView {
						LazyVStack(alignment: .leading, spacing: 4) {
							ForEach(0..<visibleRows, id: \.self) { row in
								HStack(spacing: 8) {
									let startIndex = row * bytesPerRow
									let endIndex = min((row + 1) * bytesPerRow, data.count)
									let rowData = data.subdata(in: startIndex..<endIndex)

									// Show byte offset in hex (8 digits for up to 4GB files)
									Text(offsetText(for: startIndex))
										.bold()
										.frame(width: 80, alignment: .trailing)
										.minimumScaleFactor(0.5)
										.padding(.trailing, 10)
										.contentShape(.rect)
										.onTapGesture { showHexOffsets.toggle() }
									
									Text(formattedHexString(for: rowData))
										.padding(.trailing, 5)
										.opacity(0.75)
										.fontWeight(.thin)

									Text(String(data: rowData, encoding: .ascii) ?? "")

									Spacer()
								}
							}
						}
						.multilineTextAlignment(.leading)
						.font(.system(size: 12).monospaced())
						.lineLimit(1)
						.padding()
					}
				} else {
					Text("No data to display")
						.foregroundColor(.secondary)
				}
			}
			.task {
				await loadData()
			}
		}
		
		private func offsetText(for index: Int) -> String {
			if showHexOffsets {
				String(format: "%04X %04X", (index >> 16) & 0xFFFF, index & 0xFFFF)
			} else {
				"\(index)"
			}
		}

		// Format hex string with spaces every 4 characters (2 bytes)
		// Example: "48656C6C6F" -> "4865 6C6C 6F"
		private func formattedHexString(for data: Data) -> String {
			let hexString = data.hexString
			var result = ""

			for (index, char) in hexString.enumerated() {
				if index > 0 && index % 4 == 0 {
					result.append(" ")
				}
				result.append(char)
			}

			return result
		}

		private func loadData() async {
			isLoading = true
			loadError = nil

			do {
				// Check file size first
				let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
				guard let fileSize = attributes[.size] as? Int64 else {
					throw URLError(.cannotOpenFile)
				}

				if fileSize > maxDisplaySize {
					throw DataViewError.fileTooLarge(size: fileSize, limit: maxDisplaySize)
				}

				// Load data asynchronously
				let loadedData = try await Task.detached {
					try Data(contentsOf: url)
				}.value

				await MainActor.run {
					self.data = loadedData
					self.isLoading = false
				}
			} catch {
				await MainActor.run {
					self.loadError = error
					self.isLoading = false
				}
			}
		}
	}

	enum DataViewError: LocalizedError {
		case fileTooLarge(size: Int64, limit: Int)

		var errorDescription: String? {
			switch self {
			case .fileTooLarge(let size, let limit):
				let sizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
				let limitStr = ByteCountFormatter.string(fromByteCount: Int64(limit), countStyle: .file)
				return "File too large to display (\(sizeStr)). Maximum size is \(limitStr)."
			}
		}
	}
}
