//
//  EmployeeVisitorDetailController.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeVisitorDetailController: UIViewController {
	
	var visitorId = ""
	var date = ""
	var fname = ""
	var mname = ""
	var lname = ""
	var org = ""
	var phone = ""
	var email = ""
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var orgLabel: UILabel!
	@IBOutlet var phoneLabel: UILabel!
	@IBOutlet var emailLabel: UILabel!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SwiftSpinner.show("Loading...", animated: true)
		
		let visitorQuery = "select MiddleName__c, Organization__c, Phone__c, Email__c from Visitor__c where Id = '\(self.visitorId)'"
		let visitorRequest = SFRestAPI.sharedInstance().requestForQuery(visitorQuery)
		
		SFRestAPI.sharedInstance().sendRESTRequest(visitorRequest,
			
		failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to fetch info: \(error)")
			SwiftSpinner.show("Failed to fetch info!", animated: false).addTapHandler({
				SwiftSpinner.hide()
			}, subtitle: "Tap to close")
		},
			
		completeBlock: { (response) -> Void in
			let visitor = response.objectForKey("records") as! NSArray
			self.log(SFLogLevelInfo, msg: "Fetched visitor record")
			self.mname = visitor[0].objectForKey("MiddleName__c") as! String
			self.org = visitor[0].objectForKey("Organization__c") as! String
			self.phone = visitor[0].objectForKey("Phone__c") as! String
			self.email = visitor[0].objectForKey("Email__c") as! String
			dispatch_async(dispatch_get_main_queue(), {
				self.nameLabel.text = "\(self.fname) \(self.mname) \(self.lname)"
				self.dateLabel.text = self.date
				self.orgLabel.text = "Organization: \(self.org)"
				self.phoneLabel.text = "Phone: \(self.phone)"
				self.emailLabel.text = "Email: \(self.email)"
				self.phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("makeCall:")))
				self.phoneLabel.userInteractionEnabled = true
				self.emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("sendEmail:")))
				self.emailLabel.userInteractionEnabled = true
				SwiftSpinner.hide()
			})
			
		})
		
		let picInfoQuery = "select Body from Attachment where ParentId = '\(visitorId)' and Name like '%photo.jpeg'"
		let picInfoRequest = SFRestAPI.sharedInstance().requestForQuery(picInfoQuery)
		
		SFRestAPI.sharedInstance().sendRESTRequest(picInfoRequest,
			
		failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to fetch image: \(error)")
			SwiftSpinner.show("Failed to fetch image!", animated: false).addTapHandler({
				SwiftSpinner.hide()
			}, subtitle: "Tap to close")
		},
			
		completeBlock: { (response) -> Void in
			
			let picInfo = response.objectForKey("records") as! NSArray
			let picUrl = picInfo[0].objectForKey("Body") as! String
			let picRequest = requestForAttachment(picUrl)
			
			NSURLConnection.sendAsynchronousRequest(picRequest, queue: NSOperationQueue.new()) {
				(response, data, error) -> Void in
				
				NSLog("File fetch response: \(response)")
				dispatch_async(dispatch_get_main_queue(), {
						self.imageView.image = UIImage(data: data, scale: 1.0)
				})
			}
		})
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func makeCall(recognizer: UITapGestureRecognizer) {
		if UIDevice.currentDevice().model == "iPhone" {
			UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.phone)")!)
		} else {
			var phoneAlert = UIAlertController(title: "Invalid", message: "Your device cannot make calls", preferredStyle: .Alert)
			phoneAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			presentViewController(phoneAlert, animated: true, completion: nil)
		}
	}
	
	func sendEmail(recognizer: UITapGestureRecognizer) {
		UIApplication.sharedApplication().openURL(NSURL(string: "mailto://\(self.email)")!)
	}
}
