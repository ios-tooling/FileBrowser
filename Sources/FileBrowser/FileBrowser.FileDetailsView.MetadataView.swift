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
import Combine

// AudioPlayerController manages AVPlayer lifecycle properly
@MainActor
class AudioPlayerController: ObservableObject {
	@Published var isPlaying = false
	private var player: AVPlayer?
	private var timeObserver: Any?
	private var statusObservation: AnyCancellable?
	private let url: URL

	init(url: URL) {
		self.url = url
	}

	func togglePlayback() {
		// Lazy initialize player
		if player == nil {
			player = AVPlayer(url: url)
			setupObservers()
		}

		guard let player else { return }

		if isPlaying {
			player.pause()
			isPlaying = false
		} else {
			player.play()
			isPlaying = true
		}
	}

	private func setupObservers() {
		guard let player else { return }

		// Observe playback status
		statusObservation = player.publisher(for: \.timeControlStatus)
			.sink { [weak self] status in
				Task { @MainActor in
					self?.isPlaying = (status == .playing)
				}
			}
	}

	func cleanup() {
		player?.pause()
		isPlaying = false

		// Remove time observer if exists
		if let timeObserver, let player {
			player.removeTimeObserver(timeObserver)
			self.timeObserver = nil
		}

		// Cancel status observation
		statusObservation?.cancel()
		statusObservation = nil

		// Release player
		player = nil
	}

	deinit {
		// Clean up non-isolated resources
		// Player will be deallocated when controller is deallocated
		// Cancellable will cancel on dealloc
		statusObservation?.cancel()
	}
}

extension FileBrowserScreen.FileDetailsView {
	struct MetadataView: View {
		let url: URL
		let resourceValues: [URLResourceKey: Any]
		@State private var audioDuration: TimeInterval?
		@Environment(\.fileHandlerForFile) var fileHandler
		@StateObject private var audioPlayer: AudioPlayerController
		
		init(url: URL) {
			self.url = url
			_audioPlayer = StateObject(wrappedValue: AudioPlayerController(url: url))

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
		}
		
		@ViewBuilder var controls: some View {
			if url.fileType?.isAudio == true {
				Button(action: { audioPlayer.togglePlayback() }) {
					Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
						.font(.system(size: 22))
						.padding(10)
				}
			}
		}
		

		var body: some View {
			List {
				controls
				if let view = fileHandler(FileBrowserDirectory(url: url), .details) {
					view
				}
				
				if let audioDuration {
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
							LabeledMeta(label: key.rawValue, data: number.int64Value.formatted() + "b")
						} else if let desc = object as? CustomStringConvertible {
							LabeledMeta(label: key.rawValue, data: desc.description)
						} else {
							LabeledMeta(label: key.rawValue, data: nil)
						}
					}
				}
			}
			.listStyle(.plain)
			.task {
				audioDuration = try? await url.audioDuration
			}
			.onDisappear {
				audioPlayer.cleanup()
			}
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
