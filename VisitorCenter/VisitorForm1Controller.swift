//
//  VisitorForm1Controller.swift
//  VisitorCenter
//
//  Created by Aakash on 09/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

var visitIntervalHours = 6.0

class VisitorForm1Controller: UIViewController, UITextFieldDelegate {

	@IBOutlet var firstName: UITextField!
	@IBOutlet var middleName: UITextField!
	@IBOutlet var lastName: UITextField!
	@IBOutlet var phone: UITextField!
	@IBOutlet var email: UITextField!
	@IBOutlet var organization: UITextField!
	@IBOutlet var date: UIDatePicker!
	
	static var firstName = "", middleName = "", lastName = "",
		phone = "", email = "", organization = "", date = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.date.minimumDate = NSDate()
		self.date.maximumDate = NSDate(timeIntervalSinceNow: 3600 * visitIntervalHours)
        self.firstName.delegate = self
        self.middleName.delegate = self
        self.lastName.delegate = self
        self.phone.delegate = self
        self.email.delegate = self
        self.organization.delegate = self
	}
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if(self.isMovingFromParentViewController()) {
			VisitorForm3Controller.selectedIndex = 0
			VisitorForm3Controller.idNumber = ""
			VisitorForm3Controller.photoSet = false
			VisitorForm3Controller.idPhotoSet = false
		}
		VisitorForm1Controller.firstName = self.firstName.text
		VisitorForm1Controller.middleName = self.middleName.text
		VisitorForm1Controller.lastName = self.lastName.text
		VisitorForm1Controller.phone = self.phone.text
		VisitorForm1Controller.email = self.email.text
		VisitorForm1Controller.organization = self.organization.text
		VisitorForm1Controller.date = SFDateUtil.toSOQLDateTimeString(self.date.date, isDateTime: true)
	}
	
    // MARK: - Navigation
	
	@IBAction func nextPressed(sender: AnyObject) {
		if self.formComplete() {
			self.performSegueWithIdentifier("VisitorForm2Segue", sender: self)
		} else {
			var incompleteAlert = UIAlertController(title: "Invalid", message: "Please fill all mandatory fields correctly", preferredStyle: .Alert)
			incompleteAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			presentViewController(incompleteAlert, animated: true, completion: nil)
		}
	}
	
	func formComplete() -> Bool {
		return !(self.firstName.text == "" || self.lastName.text == "" || self.phone.text == "" || self.email.text == "") && isValidEmail(self.email.text) && isValidPhone(self.phone.text)
	}

}
