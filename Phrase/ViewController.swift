//
//  ViewController.swift
//  Phrase
//
//  Created by subli on 3/2/19.
//  Copyright © 2019 subli. All rights reserved.
//
//  This project is made possible courtesy of
//  http://www.opensubtitles.org/
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
	@IBOutlet weak var outputWebView: WKWebView!
	@IBOutlet weak var searchField: UISearchBar!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var N_approxLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	
	let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	let datasetFileName = "OpenSubtitles.en-es_Dataset"
	let resultLimit: Int32 = 100
	let historyKey = "searchHistory"
	
	enum State {
		case query
		case progress
		case history
	}
	
	var state: State = .query
	var htmlQuery = ""
	var htmlHistory = ""
	var N_approx: Int32 = 0
	var progress: Float = 0
	var timer = Timer()
	
	var datasetUrl: URL?
	
	func updateDisplay() {
		if state == .query {

			progressView.isHidden = true
			N_approxLabel.isHidden = false
			let N_approxFormatted = Formatter.numberWithCommas(number: Int(N_approx))
			N_approxLabel.text = (N_approx > 0) ? "Approx.\n\(N_approxFormatted) results" : "";
			titleLabel.text = "Search phrase:"
			outputWebView.loadHTMLString(htmlQuery, baseURL: nil)

		} else if state == .progress {

			searchField.resignFirstResponder()
			progressView.isHidden = false
			N_approxLabel.isHidden = true
			titleLabel.text = "Search phrase:"
			outputWebView.loadHTMLString(Formatter.empty(), baseURL: nil)
			progressView.progress = progress

		} else if state == .history {

			searchField.resignFirstResponder()
			progressView.isHidden = true
			N_approxLabel.isHidden = true
			titleLabel.text = "History:"
			outputWebView.loadHTMLString(htmlHistory, baseURL: nil)

		}
		
		searchField.searchTextField.clearButtonMode = timer.isValid ? .never : .always
		outputWebView.setNeedsDisplay() /* DELETE? */
	}
	
	@objc func titleTapped(sender: UITapGestureRecognizer?) {
		if state == .query || state == .progress {
			let history = UserDefaults.standard.object(forKey: historyKey) as? [String] ?? [String]()
			htmlHistory = Formatter.historyAsHTML(history: history.reversed())
			state = .history
		} else if timer.isValid {
			state = .progress
		} else {
			state = .query
		}
		
		updateDisplay()
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		state = timer.isValid ? .progress : .query
		updateDisplay()
	}
	
	@objc func updateQueryProgress() {
		var a: Double = 0
		var b: Int32 = 0
		C_ffind_get_globals(&a, &b)

		let aProgress = Float(a)
		let bProgress = Float(b)/Float(self.resultLimit)
		
		// Whichever progress value will finish first is used.
		progress = aProgress > bProgress ? aProgress : bProgress
		updateDisplay()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchString = searchField.text?.lowercased() else {
			return
		}
		
		guard let datasetUrl = self.datasetUrl else {
			print("Error: datasetUrl not set.")
			let datasetUrl = documentDirectory.appendingPathComponent(datasetFileName)
			presentInitialViewControllerWith(datasetFileName: datasetUrl.path)
			return
		}
		print("datasetUrl set:\n\(datasetUrl.path)")
		
		print("------------")
		let fileManager = FileManager.default
		do {
			let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
			let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let enumerator = FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
				return true
			})!
			
			for case let url as URL in enumerator {
				print(url)
			}
		} catch {
			print(error)
		}
		print("------------")

		guard FileManager.default.fileExists(atPath: datasetUrl.path) else {
			print("File does not exist:\n\(datasetUrl.path)")
			presentInitialViewControllerWith(datasetFileName: datasetUrl.path)
			return
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
			var error: Int32 = 0
			let C_output: UnsafeMutablePointer<Int8> = C_ffind(datasetUrl.path, searchString, self.resultLimit, &self.N_approx, &error)
			guard error == 0 else {
				return
			}
			let output = String(cString: C_output)
			free(C_output)
			
			DispatchQueue.main.async {
				let html = Formatter.resultsAsHTML(text: output, highlight: searchString)
				self.htmlQuery = html
				self.appendToHistory(entry: searchString)
				
				self.timer.invalidate()
				if self.state != .history {
					self.state = .query
				}
				self.updateDisplay()
			}
		}
		
		state = .progress
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateQueryProgress), userInfo: nil, repeats: true)
		searchBar.resignFirstResponder()
	}
	
	func appendToHistory(entry: String) {
		var history = UserDefaults.standard.object(forKey: self.historyKey) as? [String] ?? [String]()
		let trimmed = entry.trimmingCharacters(in: .whitespaces)
		history.removeAll { $0 == trimmed } // Remove identical entries.
		history.append(trimmed)
		UserDefaults.standard.set(history, forKey: self.historyKey)
	}
	
	func presentInitialViewControllerWith(datasetFileName: String) {
		let main: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
		let view  = main.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
		view.datasetFileName = datasetFileName
		present(view, animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Configure title */
		let titleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.titleTapped))
		titleLabel.addGestureRecognizer(titleTap)
				
		/* Configure search bar */
		searchField.delegate = self

		let textField = searchField.value(forKey: "searchField") as! UITextField
		textField.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		textField.autocapitalizationType = .none

		let glassIcon = textField.leftView as! UIImageView
		glassIcon.image = glassIcon.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		glassIcon.tintColor = UIColor.white
		
		let clearIcon = UIImage(systemName: "xmark.circle.fill")
		searchField.setImage(clearIcon, for: .clear, state: .normal)
		searchField.setImage(clearIcon, for: .clear, state: .highlighted)

		/* Configure approximate results label */
		N_approxLabel.text = ""

		/* Configure web view */
		htmlQuery = Formatter.empty()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		let datasetUrl = documentDirectory.appendingPathComponent(datasetFileName)
		
		/* Present Initial View Controller Scene if the file has not yet been downloaded. */
		if !FileManager.default.fileExists(atPath: datasetUrl.path) {
//			print("Missing:")
			presentInitialViewControllerWith(datasetFileName: datasetFileName)
		}
		print(datasetUrl.path)
		self.datasetUrl = datasetUrl
	}
}

