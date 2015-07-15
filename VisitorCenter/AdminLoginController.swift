//
//  AdminLoginController.swift
//  VisitorCenter
//
//  Created by Aakash on 14/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class AdminLoginController: UIViewController {

	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var button: UIButton!
	@IBOutlet var subLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		SFAuthenticationManager.sharedManager().loginWithCompletion(
			{ (info) -> Void in
				self.log(SFLogLevelInfo, msg: "Completed login: \(info)")
				
				let userId = SFAuthenticationManager.sharedManager().idCoordinator.idData.userId
				let isAdminRequest = SFRestAPI.sharedInstance().requestForQuery("select VisitorCenterApp_IsAdmin__c from User where Id = '\(userId)'")
				
				SFRestAPI.sharedInstance().sendRESTRequest(isAdminRequest,
					failBlock: { (error) -> Void in
						self.log(SFLogLevelError, msg: "Failed to fetch IsAdmin: \(error)")
						SFAuthenticationManager.sharedManager().logoutAllUsers()
						self.allowExit()
					},
					completeBlock: { (response) -> Void in
						let records = response.objectForKey("records") as! NSArray
						let isAdmin = records[0].objectForKey("VisitorCenterApp_IsAdmin__c") as! Bool
						if isAdmin {
							self.performSegueWithIdentifier("AdminLoggedinSegue", sender: self)
						} else {
							SFAuthenticationManager.sharedManager().logoutAllUsers()
							dispatch_async(dispatch_get_main_queue(), {
								self.subLabel.hidden = false
							})
							self.allowExit()
						}
				})
				
			},
			failure: { (info, err) -> Void in
				self.log(SFLogLevelError, msg: "Failed login: ERR: \(err) INFO: \(info)")
				self.allowExit()
			}
		)
	}
	
	func allowExit() {
		dispatch_async(dispatch_get_main_queue(), {
			self.messageLabel.text = "Failed!"
			self.button.enabled = true
			self.button.hidden = false
		})
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
