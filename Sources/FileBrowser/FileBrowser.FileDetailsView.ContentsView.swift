//
//  FileBrowser.FileDetailsView.ContentsView.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/4/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Suite
import AVKit
import CrossPlatformKit

extension UTType {
	var isMovie: Bool {
		self == .movie || self == .mpeg4Movie || self == .quickTimeMovie
	}
	
	var isImage: Bool {
		self == .png || self == .jpeg || self == .gif || self == .image || self == .tiff
	}
}

struct FileContentsView: View {
	let url: URL
	let fileType: UTType
	@State private var image: UXImage?
	@State private var player: AVPlayer?
	@State private var textContent: String?
	@State private var isLoading = true
	@State private var loadError: Error?

	init(url: URL) {
		self.url = url
		self.fileType = url.fileType ?? .data
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
			} else if fileType.isMovie, let player {
				VideoPlayer(player: player)
					.onDisappear {
						player.pause()
					}
			} else if fileType.isImage, let image {
				Image(uxImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)
			} else if let textContent {
				ScrollView {
					Text(textContent)
						.multilineTextAlignment(.leading)
						.font(.system(size: 14).monospaced())
						.padding()
				}
			} else {
				Text("Unable to display file")
					.foregroundColor(.secondary)
			}
		}
		.task {
			await loadContent()
		}
	}

	private func loadContent() async {
		isLoading = true
		loadError = nil

		do {
			if fileType.isMovie {
				// AVPlayer streams from URL, no need to load
				await MainActor.run {
					self.player = AVPlayer(url: url)
					self.isLoading = false
				}
			} else if fileType.isImage {
				// Load image asynchronously
				// Note: UXImage (NSImage/UIImage) isn't Sendable in macOS 13, but we're
				// not sharing it across actors - just loading on background and using on main
				
				if #available(macOS 14, *) {
					let loadedImage: UXImage? = await Task.detached {
						UXImage(contentsOf: url)
					}.value
					
					guard let loadedImage else {
						throw URLError(.cannotDecodeContentData)
					}
					
					await MainActor.run {
						self.image = loadedImage
						self.isLoading = false
					}
				}
			} else {
				// Load text content asynchronously
				let content = try await Task.detached {
					let data = try Data(contentsOf: url)

					switch fileType {
					case .json:
						return data.prettyPrintedJSON ?? "Unable to parse JSON"
					case .text, .xml, .xmlPropertyList:
						return String(data: data, encoding: .utf8) ?? "Unable to decode text"
					default:
						// Try JSON/plist parsing
						if let json = data.jsonDictionary ?? data.propertyList?.jsonDictionary {
							return json.prettyPrinted
						}
						return "\(fileType.description)\n\nBinary file (\(data.count) bytes)"
					}
				}.value

				await MainActor.run {
					self.textContent = content
					self.isLoading = false
				}
			}
		} catch {
			await MainActor.run {
				self.loadError = error
				self.isLoading = false
			}
		}
	}
}
