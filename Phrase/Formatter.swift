//
//  Formatter.swift
//  Phrase
//
//  Created by subli on 3/7/19.
//  Copyright © 2019 subli. All rights reserved.
//

import Foundation

class Formatter {
	static let template = """
		<?xml version="1.0" encoding="utf-8" standalone="no"?>
		<html>
			<head>
				<meta name="viewport" content="width=device-width, initial-scale=0.95, user-scalable=no">
				<style>
					body {
						background: #FCFCFC; margin-left: 18.5pt; margin-right: 18pt;
						font-family: Menlo; text-size: 8pt; word-wrap: break-word;
					}
					.a {color: #3d4858}
					.b {color: #909299}
				</style>
			</head>
			<body>
				<br />%@
			</body>
		</html>
		"""
	
	static func empty() -> String {
		return String(format: template, "")
	}
	
	static func historyAsHTML(history: [String]) -> String {
		var body = ""
		for (i,item) in history.enumerated() {
			body += """
				<b>\(i+1). </b>
				<span class='a'>\(item) </span><br />
				"""
		}
		let htmlOutput = String(format: template, body)

		return htmlOutput
	}
	
	static func resultsAsHTML(text: String, highlight: String) -> String {
		var body = ""
		
		if text.count > 0 {
			let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
			let entries = text.components(separatedBy: "\n")
			
			for (i,entry) in entries.enumerated() {
				let entryList = entry.components(separatedBy: "\u{1f}")
				
				let a = entryList[1].replacingOccurrences(of: highlight, with: "<b>\(highlight)</b>")
				let b = entryList[0].replacingOccurrences(of: highlight, with: "<b>\(highlight)</b>")
				
				body += """
				<div>
				<b>\(i+1). </b>
				<span class='a'>\(a)</span>
				<span class='b'> — \(b)</span>
				<br /><br /></div>
				"""
			}
		} else {
			body += """
			<div>
			<span class='a'>No results found.</span>
			</div>
			"""
		}
		
		let htmlOutput = String(format: template, body)
		
		return htmlOutput
	}
	
	static func numberWithCommas(number: Int) -> String {
		return NumberFormatter.localizedString(from: NSNumber(value: number), number: NumberFormatter.Style.decimal)
	}
}
