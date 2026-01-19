//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/27/24.
//

import SwiftUI
import AVKit

#if canImport(UIKit)
struct MovieViewer: UIViewControllerRepresentable {
	let url: URL
	
	func makeUIViewController(context: Context) -> some UIViewController {
		context.coordinator.controller
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(url: url)
	}
	
	class Coordinator {
		let url: URL
		let player: AVPlayer
		let controller: AVPlayerViewController
		
		init(url: URL) {
			self.url = url
			self.player = AVPlayer(url: url)
			self.controller = AVPlayerViewController()

			self.controller.player = player
			self.controller.showsPlaybackControls = true
			// Note: Removed auto-play for better UX and accessibility
			// Users can manually start playback using the built-in controls
		}
	}
}
#endif
