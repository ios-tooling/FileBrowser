//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/27/24.
//

import SwiftUI
import AVKit

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
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.player.play()
			}
		}
	}
}
