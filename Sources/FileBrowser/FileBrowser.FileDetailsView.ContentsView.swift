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
	@State var image: UXImage?
	@State var player: AVPlayer?
	
	init(url: URL) {
		self.url = url
		fileType = url.fileType ?? .data
		
		if fileType.isMovie {
			_player = State(initialValue: AVPlayer(url: url))
		} else if fileType.isImage {
			_image = State(initialValue: UXImage(contentsOf: url))
		}
	}
	
	var body: some View {
		if fileType.isMovie, let player {
			VideoPlayer(player: player)
				.onAppear {
					player.play()
				}
				.onDisappear {
					player.pause()
				}
		} else if let image {
			Image(uxImage: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
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
