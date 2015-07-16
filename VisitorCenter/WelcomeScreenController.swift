//
//  WelcomeScreenController.swift
//  VisitorCenter
//
//  Created by Aakash on 09/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class WelcomeScreenController: UIViewController {
	
	@IBOutlet var regionLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.regionLabel.text = region
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func prepareForUnwindSegue(segue: UIStoryboardSegue) {
	}
	
	@IBAction func regionButton(sender: AnyObject) {
		var alert = UIAlertController(title: "Set Region", message: "", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "USA", style: .Default, handler: { (action) -> Void in
			if region != "USA" {
				region = "USA"
				dispatch_async(dispatch_get_main_queue(), {
					self.regionLabel.text = region
					VisitorForm2Controller.regionChanged = true
				})
			}
		}))
		alert.addAction(UIAlertAction(title: "UK", style: .Default, handler: { (action) -> Void in
			if region != "UK" {
				region = "UK"
				dispatch_async(dispatch_get_main_queue(), {
					self.regionLabel.text = region
					VisitorForm2Controller.regionChanged = true
				})
			}
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
}

