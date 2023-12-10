//
//  FileBrowser.FileDetailsView.MetadataView.swift
//  Internal
//
//  Created by Ben Gottlieb on 9/4/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Suite
import AVFoundation

extension FileBrowserView.FileDetailsView {
	struct MetadataView: View {
		let url: URL
		let resourceValues: [URLResourceKey: Any]
		let audioDuration: TimeInterval?

		@State var player: AVPlayer?
		@StateObject var pokee = PokeableObject()
		
		func play() {
			if player == nil { player = AVPlayer(url: url) }
			
			if player?.isPlaying == true {
				player?.pause()
			} else {
				player?.play()
			}
			pokee.poke()
		}
		
		init(url: URL) {
			self.url = url
			
			var values: [URLResourceKey: Any] = [:]
			
			let nsURL = url as NSURL
			for key in URLResourceKey.propertiesOfInterest {
				var object: AnyObject?
				do {
					try nsURL.getResourceValue(&object, forKey: key)
					if let object {
						values[key] = object
					}
				} catch {
					print("Failed to query \(key): \(error)")
				}
			}
			
			resourceValues = values
			audioDuration = url.audioDuration
		}
		
		@ViewBuilder var controls: some View {
			if url.fileType?.isAudio == true {
				Button(action: { play() }) {
					Image(systemName: player?.isPlaying == true ? "pause.fill" : "play.fill")
						.font(.system(size: 22))
						.padding(10)
				}
			}
		}
		

		var body: some View {
			List {
				controls
				if let audioDuration = url.audioDuration {
					LabeledMeta(label: "Audio duration", data: audioDuration.durationString(style: .milliseconds, roundUp: false))
				}
				ForEach(URLResourceKey.propertiesOfInterest, id: \.rawValue) { key in
					if let object = resourceValues[key] {
						if let bool = object as? NSNumber, key.rawValue.contains("NSURLIs") {
							LabeledMeta(label: key.rawValue, data: bool.boolValue ? "true" : "false")
						} else if let date = object as? Date {
							LabeledMeta(label: key.rawValue, data: date.localTimeString())
						} else if let number = object as? NSNumber, key.rawValue.contains("Size") {
							LabeledMeta(label: key.rawValue, data: number.int64Value.bytesString)
						} else if let desc = object as? CustomStringConvertible {
							LabeledMeta(label: key.rawValue, data: desc.description)
						} else {
							LabeledMeta(label: key.rawValue, data: nil)
						}
					}
				}
			}
			.listStyle(.plain)
		}
	}
	
	struct LabeledMeta: View {
		let label: String
		let data: String?
		
		var body: some View {
			HStack {
				Text(label)
					.font(.caption)
					.bold()
				
				Spacer()
				if let data {
					Text(data)
						.font(.system(size: 14))
						.multilineTextAlignment(.trailing)
				}
			}
		}
	}
}

extension UTType {
	var isAudio: Bool {
		identifier.contains("audio")
	}
}
