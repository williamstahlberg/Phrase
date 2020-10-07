//
//  DownloadService.swift
//  Phrase
//
//  Created by subli on 5/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

import Foundation

class DownloadService {
	var activeDownloads: [URL: Download] = [ : ]
	var downloadsSession: URLSession! // SearchViewController creates downloadsSession

	func cancelDownload(_ track: DownloadableItem) {
		guard let download = activeDownloads[track.url] else {
			return
		}
		download.task?.cancel()

		activeDownloads[track.url] = nil
	}
	
	func pauseDownload(_ track: DownloadableItem) {
		guard let download = activeDownloads[track.url], download.isDownloading else {
			return
		}
		
		download.task?.cancel(byProducingResumeData: { data in
			download.resumeData = data
		})

		download.isDownloading = false
	}
	
	func resumeDownload(_ track: DownloadableItem) {
		guard let download = activeDownloads[track.url] else {
			return
		}
		
		if let resumeData = download.resumeData {
			download.task = downloadsSession.downloadTask(withResumeData: resumeData)
		} else {
			download.task = downloadsSession.downloadTask(with: download.track.url)
		}
		
		download.task?.resume()
		download.isDownloading = true
	}
	
	func startDownload(_ track: DownloadableItem) {
		#if VERBOSE
		print("Download started:\n\(track.url)")
		#endif
		let download = Download(track: track)
		download.task = downloadsSession.downloadTask(with: track.url)
		download.task?.resume()
		download.isDownloading = true
		activeDownloads[download.track.url] = download
	}
}
