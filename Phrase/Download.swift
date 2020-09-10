//
//  Download.swift
//  Phrase
//
//  Created by subli on 5/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

import Foundation

class Download {
	var isDownloading = false
	var progress: Float = 0
	var resumeData: Data?
	var task: URLSessionDownloadTask?
	var track: DownloadableItem

	init(track: DownloadableItem) {
		self.track = track
	}
}
