//
//  VisitorLoungeController.swift
//  VisitorCenter
//
//  Created by Aakash on 12/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class VisitorLoungeController: UIViewController {
	
	var state = "Pending"
	var client = ZKSforceClient()
	var visitorId = ""

	@IBOutlet var message: UILabel!
	@IBOutlet var button: UIButton!
	
	@IBAction func buttonPressed(sender: AnyObject) {
		
		if self.state == "Pending" {
			
			SwiftSpinner.showWithDelay(2.0, title: "Checking...")
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
				
				let result = self.client.query("select Status__c from Visitor__c where Id = '\(self.visitorId)'") as ZKQueryResult
				self.state = result.records()[0].fieldValue("Status__c") as! String
				
				dispatch_async(dispatch_get_main_queue(), {
					
					if self.state == "Rejected" || self.state == "Checkedout" {
						
						self.message.text = "Your request has been rejected. Please contact a staff member for help."
						self.button.setTitle("Done", forState: .Normal)
						
					} else if self.state == "Checkedin" {
						
						self.message.text = "You've been approved! Please checkout before you leave the building."
						self.button.setTitle("Checkout", forState: .Normal)
						
					}
					self.button.titleLabel?.textAlignment = .Center
					
					SwiftSpinner.hide()
				})
			})
			
		} else if self.state == "Rejected" || self.state == "Checkedout" {
			
			self.performSegueWithIdentifier("HomeUnwindSegue", sender: self)
			
		} else if self.state == "Checkedin" {
			
			SwiftSpinner.showWithDelay(2.0, title: "Loading...")
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
			
				var visit = ZKSObject(type: "Visitor__c")
				visit.setFieldValue("Checkedout", field: "Status__c")
				visit.setFieldValue(self.visitorId, field: "Id")
				self.client.update([visit])
				
				dispatch_async(dispatch_get_main_queue(), {
					SwiftSpinner.hide()
					self.performSegueWithIdentifier("HomeUnwindSegue", sender: self)
				})
			})
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.client.login(visitorUser, password: visitorPass)
    }
	
	override func viewWillDisappear(animated: Bool) {
		self.client.logout()
		super.viewWillDisappear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
