//
//  EmployeeVisitorDetailController.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeVisitorDetailController: UIViewController {
	
	var record = Visitor()
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var orgLabel: UILabel!
	@IBOutlet var phoneLabel: UILabel!
	@IBOutlet var emailLabel: UILabel!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SwiftSpinner.show("Loading...")
	
		self.nameLabel.text = "\(self.record.fname) \(self.record.mname) \(self.record.lname)"
		self.dateLabel.text = self.record.date
		self.orgLabel.text = "Organization: \(self.record.org)"
		self.phoneLabel.text = "Phone: \(self.record.phone)"
		self.emailLabel.text = "Email: \(self.record.email)"
		self.phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("makeCall:")))
		self.phoneLabel.userInteractionEnabled = true
		self.emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("sendEmail:")))
		self.emailLabel.userInteractionEnabled = true
		
		let picInfoQuery = "select Body from Attachment where Name = '\(self.record.vid)photo.jpeg'"
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
						SwiftSpinner.hide()
					})
				}
			}
		)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func makeCall(recognizer: UITapGestureRecognizer) {
		if UIDevice.currentDevice().model == "iPhone" {
			UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.record.phone)")!)
		} else {
			var phoneAlert = UIAlertController(title: "Invalid", message: "Your device cannot make calls", preferredStyle: .Alert)
			phoneAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			presentViewController(phoneAlert, animated: true, completion: nil)
		}
	}
	
	func sendEmail(recognizer: UITapGestureRecognizer) {
		UIApplication.sharedApplication().openURL(NSURL(string: "mailto://\(self.record.email)")!)
	}
	
}
