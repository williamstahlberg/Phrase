//
//  TableCell.swift
//  Phrase
//
//  Created by subli on 5/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

import UIKit

protocol TableCellDelegate {
	func cancelTapped(_ cell: TableCell)
	func downloadTapped(_ cell: TableCell)
	func pauseTapped(_ cell: TableCell)
	func resumeTapped(_ cell: TableCell)
}

class TableCell: UITableViewCell {
	static let identifier = "TableCell"
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var progressLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var pauseOrResumeButton: UIButton!
	@IBOutlet weak var downloadButton: UIButton!
	
	@IBAction func cancelTapped(_ sender: Any) {
		delegate?.cancelTapped(self)
	}
	
	@IBAction func pauseOrResumeTapped(_ sender: Any) {
		if(pauseOrResumeButton.titleLabel?.text == "Pause") {
			delegate?.pauseTapped(self)
		} else {
			delegate?.resumeTapped(self)
		}
	}
	
	@IBAction func downloadTapped(_ sender: Any) {
		delegate?.downloadTapped(self)
	}
	
	// Delegate identifies track for this cell, then passes this to a download service method.
	var delegate: TableCellDelegate?
	
	func configure(track: DownloadableItem, downloaded: Bool, download: Download?, processing: Bool) {
		titleLabel.text = track.title
		subtitleLabel.text = track.subTitle

		// Show/hide download controls Pause/Resume, Cancel buttons, progress info.
		var showDownloadControls = false

		// Non-nil Download object means a download is in progress.
		if let download = download {
			showDownloadControls = true

			let title = download.isDownloading ? "Pause" : "Resume"
			pauseOrResumeButton.setTitle(title, for: .normal)

			progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
		}
		
		if processing {
			showDownloadControls = true
		}

		pauseOrResumeButton.isHidden = !showDownloadControls
		cancelButton.isHidden = !showDownloadControls

		progressView.isHidden = !showDownloadControls
		progressLabel.isHidden = !showDownloadControls

		// If the track is already downloaded, enable cell selection and hide the Download button.
		selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
		downloadButton.isHidden = downloaded || showDownloadControls
	}

	func updateDisplay(progress: Float, status: String) {
		progressView.progress = progress
		progressLabel.text = status
	}
}
