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
	
	override func viewWillDisappear(animated: Bool) {
		VisitorForm2Controller.selected = false
		VisitorForm3Controller.selectedIndex = 0
		VisitorForm3Controller.idNumber = ""
		VisitorForm3Controller.photoSet = false
		VisitorForm3Controller.idPhotoSet = false
		super.viewWillDisappear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func finishPressed(sender: AnyObject) {
		if let sig = self.view.viewWithTag(1337) as? SignatureView {
			
			if !sig.isSigned() {
				
				let incompleteAlert = UIAlertController(title: "Incomplete", message: "Please sign your request", preferredStyle: .Alert)
				incompleteAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
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
			let visitorUpsertResult = client.upsert("IDNumber__c", sObjects: [visitor]) as! [ZKUpsertResult]
			var visitorId = visitorUpsertResult[0].id
			
			let sigView = self.view.viewWithTag(1337) as! SignatureView
			let sig64 = sigView.signatureData().base64EncodedStringWithOptions(nil)
			var sigAttach = ZKSObject(type: "Attachment")
			sigAttach.setFieldValue(visitorId, field: "ParentId")
			sigAttach.setFieldValue("\(visitorId)signature.png", field: "Name")
			sigAttach.setFieldValue(sig64, field: "Body")
			
			let photoImg = self.resizeImage(VisitorForm3Controller.photo)
			let photo64 = UIImageJPEGRepresentation(photoImg, 0.8).base64EncodedStringWithOptions(nil)
			var photoAttach = ZKSObject(type: "Attachment")
			photoAttach.setFieldValue(visitorId, field: "ParentId")
			photoAttach.setFieldValue("\(visitorId)photo.jpeg", field: "Name")
			photoAttach.setFieldValue(photo64, field: "Body")
			
			let idImg = self.resizeImage(VisitorForm3Controller.idPhoto)
			let id64 = UIImageJPEGRepresentation(idImg, 0.8).base64EncodedStringWithOptions(nil)
			var idAttach = ZKSObject(type: "Attachment")
			idAttach.setFieldValue(visitorId, field: "ParentId")
			idAttach.setFieldValue("\(visitorId)id.jpeg", field: "Name")
			idAttach.setFieldValue(id64, field: "Body")
				
			client.upsert("Name", sObjects: [sigAttach, photoAttach, idAttach])
			
			var visit = ZKSObject(type: "Visit__c")
			visit.setFieldValue(VisitorForm1Controller.date, field: "Date__c")
			visit.setFieldValue("Pending", field: "Status__c")
			visit.setFieldValue(visitorId, field: "Visitor__c")
			visit.setFieldValue(VisitorForm2Controller.empId, field: "User__c")
			let visitResult = client.create([visit]) as! [ZKSaveResult]
			self.visitId = visitResult[0].id
			
			client.logout()
			
			dispatch_async(dispatch_get_main_queue(), {
				SwiftSpinner.hide()
				self.performSegueWithIdentifier("VisitorLoungeSegue", sender: self)
			})
		})
	}
	
	var visitId = ""
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let lounge = segue.destinationViewController as? VisitorLoungeController {
			lounge.visitId = self.visitId
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
