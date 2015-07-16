//
//  AppDelegate.swift
//  VisitorCenter
//
//  Created by Aakash on 09/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit
import CoreData

let RemoteAccessConsumerKey = "3MVG9ZL0ppGP5UrAfHjVwH3cEhsWx26SlLgvi1jt3USM03ar9z1YQi7Yuj.kUxn7Z5Ajc6RpIwLLHkIvBUNYc"
let OAuthRedirectURI = "sfdc://auth/success"
let scopes = ["api", "web", "refresh_token", "offline_access"]

let visitorUser = "visitor@app.test"
let visitorPass = "guest1234K8sopfoKUJOb9mb0DAcDM1oEd"

let buttonColor = UIColor(red: 236/255.0, green: 241/255.0, blue: 102/255.0, alpha: 1.0)
let backColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 62/255.0, alpha: 1.0)

var region = "USA"
let usFormat = NSDateFormatter.dateFormatFromTemplate("EdMMM HH:mm", options: 0, locale: NSLocale(localeIdentifier: "en_US"))!
let gbFormat = NSDateFormatter.dateFormatFromTemplate("EdMMM HH:mm", options: 0, locale: NSLocale(localeIdentifier: "en_GB"))!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	override init() {
		super.init()
		SFLogger.setLogLevel(SFLogLevelDebug)
		SalesforceSDKManager.sharedManager().connectedAppId = RemoteAccessConsumerKey
		SalesforceSDKManager.sharedManager().connectedAppCallbackUri = OAuthRedirectURI
		SalesforceSDKManager.sharedManager().authScopes = scopes
		SalesforceSDKManager.sharedManager().authenticateAtLaunch = false
		SalesforceSDKManager.sharedManager().useSnapshotView = false
		SalesforceSDKManager.sharedManager().postLaunchAction = {
			[unowned self] (launchActionList: SFSDKLaunchAction) in
			let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
			self.log(SFLogLevelInfo, msg:"Post-launch: launch actions taken: \(launchActionString)");
			SFAuthenticationManager.sharedManager().logoutAllUsers()
		}
		SalesforceSDKManager.sharedManager().launchErrorAction = {
			[unowned self] (error: NSError?, launchActionList: SFSDKLaunchAction) in
			if let actualError = error {
				self.log(SFLogLevelError, msg:"Error during SDK launch: \(actualError.localizedDescription)")
			} else {
				self.log(SFLogLevelError, msg:"Unknown error during SDK launch.")
			}
			SalesforceSDKManager.sharedManager().launch()
		}
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		SalesforceSDKManager.sharedManager().launch()
		return true
	}

}

