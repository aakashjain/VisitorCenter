//
//  EmployeeVisitorDetailController.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeVisitorDetailController: UIViewController, SFRestDelegate {
	
	
	
	var visitId = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SwiftSpinner.show("Loading...", animated: true)
		let query: String = "SELECT Id, Visitor__r.FirstName__c, Visitor__r.MiddleName__c, Visitor__r.LastName__c, Visitor__r.Phone__c, Visitor__r.Email__c, Visitor__r.Organization__c, Visitor__r.Photo__c, Time__c, Date__c FROM Visit__c where Employee__r.Id = '\(visitId)'"
		let request = SFRestAPI.sharedInstance().requestForQuery(query)
		SFRestAPI.sharedInstance().send(request, delegate: self)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK: - SFRestDelegate
	
	func request(request: SFRestRequest!, didLoadResponse dataResponse: AnyObject!) {
		self.log(SFLogLevelInfo, msg: "Retrieved visit info")
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
			SwiftSpinner.hide()
		})
	}
	
	func request(request: SFRestRequest!, didFailLoadWithError error: NSError!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve visit info: \(error)")
		SwiftSpinner.hide()
	}
	
	func requestDidCancelLoad(request: SFRestRequest!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve visit info: Server cancelled request")
		SwiftSpinner.hide()
	}
	
	func requestDidTimeout(request: SFRestRequest!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve visit info: Request timed out")
		SwiftSpinner.hide()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
