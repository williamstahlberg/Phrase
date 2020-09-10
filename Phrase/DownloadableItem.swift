//
//  DownloadableItem.swift
//  Phrase
//
//  Created by subli on 5/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

import Foundation.NSURL

class DownloadableItem {
	let title: String
	let subTitle: String
	let url: URL
	let index: Int
	
	var downloaded = false

	init(title: String, subTitle: String, url: URL, index: Int) {
		self.title = title
		self.subTitle = subTitle
		self.url = url
		self.index = index
	}
}
