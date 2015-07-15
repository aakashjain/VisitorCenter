//
//  EmployeeLoginController.swift
//  VisitorCenter
//
//  Created by Aakash on 10/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeLoginController: UIViewController {

	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var button: UIButton!
	@IBOutlet var subLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		SFAuthenticationManager.sharedManager().loginWithCompletion(
			{ (info) -> Void in
				self.log(SFLogLevelInfo, msg: "Completed login: \(info)")
				
				let userId = SFAuthenticationManager.sharedManager().idCoordinator.idData.userId
				let isEmpRequest = SFRestAPI.sharedInstance().requestForQuery("select VisitorCenterApp_IsEmployee__c from User where Id = '\(userId)'")
				
				SFRestAPI.sharedInstance().sendRESTRequest(isEmpRequest,
					failBlock: { (error) -> Void in
						self.log(SFLogLevelError, msg: "Failed to fetch IsEmployee: \(error)")
						SFAuthenticationManager.sharedManager().logoutAllUsers()
						self.allowExit()
					},
					completeBlock: { (response) -> Void in
						let records = response.objectForKey("records") as! NSArray
						let isEmp = records[0].objectForKey("VisitorCenterApp_IsEmployee__c") as! Bool
						if isEmp {
							self.performSegueWithIdentifier("EmployeeLoggedinSegue", sender: self)
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
