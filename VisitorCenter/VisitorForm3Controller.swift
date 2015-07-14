//
//  VisitorForm3Controller.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class VisitorForm3Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	static var selectedIndex = 0
	static var idType = ""
	static var idNumber = ""
	static var idPhotoSet = false
	static var idPhoto = UIImage()
	static var photoSet = false
	static var photo = UIImage()
	
	@IBOutlet var idTypePicker: UIPickerView!
	@IBOutlet var idNumberField: UITextField!
	@IBOutlet var idPhotoView: UIImageView!
	@IBOutlet var photoView: UIImageView!
	
	var idPhotoPicker: UIImagePickerController!
	var photoPicker: UIImagePickerController!
	
	@IBAction func captureIdPhoto(sender: AnyObject) {
		
		var infoAlert = UIAlertController(title: "ID Photo", message: "Please capture a photo of the selected ID", preferredStyle: .Alert)
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
			
			self.presentViewController(self.idPhotoPicker, animated: true, completion: nil)
			
		})
		presentViewController(infoAlert, animated: true, completion: nil)
		
	}
	
	@IBAction func capturePhoto(sender: AnyObject) {
		
		var infoAlert = UIAlertController(title: "Your Photo", message: "Please capture a photo of your face", preferredStyle: .Alert)
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
			
			self.presentViewController(self.photoPicker, animated: true, completion: nil)
		
		})
		presentViewController(infoAlert, animated: true, completion: nil)
		
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
		
		if picker == self.idPhotoPicker {
			
			VisitorForm3Controller.idPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
			self.idPhotoView.contentMode = .ScaleAspectFit
			self.idPhotoView.image = VisitorForm3Controller.idPhoto
			VisitorForm3Controller.idPhotoSet = true
			
		} else if picker == self.photoPicker {
			
			VisitorForm3Controller.photo = info[UIImagePickerControllerOriginalImage] as! UIImage
			self.photoView.contentMode = .ScaleAspectFit
			self.photoView.image = VisitorForm3Controller.photo
			VisitorForm3Controller.photoSet = true
			
		}
		
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func nextPressed(sender: AnyObject) {
		
		if self.idNumberField.text == "" || VisitorForm3Controller.idPhotoSet == false || VisitorForm3Controller.photoSet == false {
			
			var incompleteAlert = UIAlertController(title: "Incomplete", message: "Please fill all fields", preferredStyle: .Alert)
			incompleteAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
			presentViewController(incompleteAlert, animated: true, completion: nil)
			
		} else {
			
			performSegueWithIdentifier("VisitorForm4Segue", sender: self)

		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.idTypePicker.selectRow(VisitorForm3Controller.selectedIndex, inComponent: 0, animated: false)
		self.idNumberField.text = VisitorForm3Controller.idNumber
		
		if VisitorForm3Controller.idPhotoSet {
			self.idPhotoView.contentMode = .ScaleAspectFit
			self.idPhotoView.image = VisitorForm3Controller.idPhoto
		}
		if VisitorForm3Controller.photoSet {
			self.photoView.contentMode = .ScaleAspectFit
			self.photoView.image = VisitorForm3Controller.photo
		}
		
		self.idPhotoPicker = UIImagePickerController()
		self.idPhotoPicker.delegate = self
		self.photoPicker = UIImagePickerController()
		self.photoPicker.delegate = self
		
		if UIImagePickerController.isSourceTypeAvailable(.Camera) {
			self.photoPicker.sourceType = .Camera
			self.idPhotoPicker.sourceType = .Camera
		} else {
			self.photoPicker.sourceType = .PhotoLibrary
			self.idPhotoPicker.sourceType = .PhotoLibrary
		}
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		VisitorForm3Controller.selectedIndex = self.idTypePicker.selectedRowInComponent(0)
		VisitorForm3Controller.idType = self.pickerContent[VisitorForm3Controller.selectedIndex]
		VisitorForm3Controller.idNumber = self.idNumberField.text
		if VisitorForm3Controller.idPhotoSet {
			VisitorForm3Controller.idPhoto = self.idPhotoView.image!
		}
		if VisitorForm3Controller.photoSet {
			VisitorForm3Controller.photo = self.photoView.image!
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK: - UIPickerView
	
	var pickerContent = ["Voter Card", "Driver License", "Passport", "PAN", "SSN"]
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.pickerContent.count
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		return self.pickerContent[row]
	}

}
