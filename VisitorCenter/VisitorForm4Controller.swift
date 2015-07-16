//
//  VisitorForm4Controller.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class VisitorForm4Controller: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var sigView = SignatureView()
		sigView.tag = 1337
		sigView.frame = self.view.frame
		self.view.addSubview(sigView)
    }
	
	@IBAction func finishPressed(sender: AnyObject) {
		if let sig = self.view.viewWithTag(1337) as? SignatureView {
			if !sig.isSigned() {
				let incompleteAlert = UIAlertController(title: "Incomplete", message: "Please sign your request", preferredStyle: .Alert)
				incompleteAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
				presentViewController(incompleteAlert, animated: true, completion: nil)
				return
			}
		}
		registerVisitor()
	}
	
	func registerVisitor() {
		SwiftSpinner.show("Uploading..")
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
			
			let client = ZKSforceClient()
			client.login(visitorUser, password: visitorPass)
				
			var visitor = ZKSObject(type: "Visitor__c")
			visitor.setFieldValue(VisitorForm1Controller.firstName, field: "FirstName__c")
			visitor.setFieldValue(VisitorForm1Controller.middleName, field: "MiddleName__c")
			visitor.setFieldValue(VisitorForm1Controller.lastName, field: "LastName__c")
			visitor.setFieldValue(VisitorForm1Controller.email, field: "Email__c")
			visitor.setFieldValue(VisitorForm1Controller.phone, field: "Phone__c")
			visitor.setFieldValue(VisitorForm1Controller.organization, field: "Organization__c")
			visitor.setFieldValue(VisitorForm3Controller.idType, field: "IDType__c")
			visitor.setFieldValue(VisitorForm3Controller.idNumber, field: "IDNumber__c")
			visitor.setFieldValue(VisitorForm1Controller.date, field: "Date__c")
			visitor.setFieldValue("Pending", field: "Status__c")
			visitor.setFieldValue("", field: "Remarks__c")
			visitor.setFieldValue(VisitorForm2Controller.empId, field: "User__c")
			let visitorSaveResult = client.create([visitor]) as! [ZKSaveResult]
			self.visitorId = visitorSaveResult[0].id
			
			let sigView = self.view.viewWithTag(1337) as! SignatureView
			let sig64 = sigView.signatureData().base64EncodedStringWithOptions(nil)
			var sigAttach = ZKSObject(type: "Attachment")
			sigAttach.setFieldValue(self.visitorId, field: "ParentId")
			sigAttach.setFieldValue("\(self.visitorId)signature.png", field: "Name")
			sigAttach.setFieldValue(sig64, field: "Body")
			
			let photoImg = self.resizeImage(VisitorForm3Controller.photo)
			let photo64 = UIImageJPEGRepresentation(photoImg, 0.8).base64EncodedStringWithOptions(nil)
			var photoAttach = ZKSObject(type: "Attachment")
			photoAttach.setFieldValue(self.visitorId, field: "ParentId")
			photoAttach.setFieldValue("\(self.visitorId)photo.jpeg", field: "Name")
			photoAttach.setFieldValue(photo64, field: "Body")
			
			let idImg = self.resizeImage(VisitorForm3Controller.idPhoto)
			let id64 = UIImageJPEGRepresentation(idImg, 0.8).base64EncodedStringWithOptions(nil)
			var idAttach = ZKSObject(type: "Attachment")
			idAttach.setFieldValue(self.visitorId, field: "ParentId")
			idAttach.setFieldValue("\(self.visitorId)id.jpeg", field: "Name")
			idAttach.setFieldValue(id64, field: "Body")
				
			client.create([sigAttach, photoAttach, idAttach])
			client.logout()
			
			VisitorForm3Controller.selectedIndex = 0
			VisitorForm3Controller.idNumber = ""
			VisitorForm3Controller.photoSet = false
			VisitorForm3Controller.idPhotoSet = false
			
			dispatch_async(dispatch_get_main_queue(), {
				SwiftSpinner.hide()
				self.performSegueWithIdentifier("VisitorLoungeSegue", sender: self)
			})
		})
	}
	
	var visitorId = ""
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let lounge = segue.destinationViewController as? VisitorLoungeController {
			lounge.visitorId = self.visitorId
		}
	}
	
	func resizeImage(img: UIImage) -> UIImage {
		let size = CGSizeApplyAffineTransform(img.size, CGAffineTransformMakeScale(0.25, 0.25))
		UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
		img.drawInRect(CGRect(origin: CGPointZero, size: size))
		let scaled = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return scaled
	}
	
}
