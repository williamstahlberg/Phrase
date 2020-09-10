//
//  AppDelegate.swift
//  Phrase
//
//  Created by subli on 3/2/19.
//  Copyright © 2019 subli. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var backgroundSessionCompletionHandler: (() -> Void)?
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		return true
	}
	
	func application(_ application: UIApplication, handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String, completionHandler: @escaping () -> Void) {
		backgroundSessionCompletionHandler = completionHandler
	}
	
}
