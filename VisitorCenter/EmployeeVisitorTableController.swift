//
//  EmployeeVisitorTableController.swift
//  VisitorCenter
//
//  Created by Aakash on 10/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeVisitorTableController: UITableViewController, SFRestDelegate {
	
	struct Record {
		var id: String
		var date: String
		var vid: String
		var fname: String
		var lname: String
	}
	
	var rows = [Record]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
		self.sendRequest();
    }
	
	func sendRequest() {
		SwiftSpinner.show("Loading...")
		let userId: String = SFAuthenticationManager.sharedManager().idCoordinator.idData.userId
		let query = "select Id, Date__c, Visitor__r.Id, Visitor__r.FirstName__c, Visitor__r.LastName__c from Visit__c where User__c = '\(userId)' and Status__c = 'Checkedin' order by Date__c asc"
		let request: SFRestRequest = SFRestAPI.sharedInstance().requestForQuery(query)
		SFRestAPI.sharedInstance().send(request, delegate: self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.viewControllers.removeAtIndex(1) //remove auth screen from nav controller
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
	}

	override func viewWillDisappear(animated: Bool) {
		if self.isMovingFromParentViewController() {
			SFAuthenticationManager.sharedManager().logoutAllUsers()
		}
		super.viewWillDisappear(animated)
	}
	
	override func navigationShouldPopOnBackButton() -> Bool {
		var logout = true
		var logoutAlert = UIAlertController(title: "Logout?", message: "This will log you out. Proceed?", preferredStyle: .Alert)
		logoutAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
			logout = true
		}))
		logoutAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
			logout = false
		}))
		self.presentViewController(logoutAlert, animated: true, completion: nil)
		return logout
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		let row = rows[indexPath.row]
		cell.textLabel?.text = row.date
		cell.textLabel?.textColor = UIColor.whiteColor()
		cell.detailTextLabel?.text = "\(row.fname) \(row.lname))"
		cell.detailTextLabel?.textColor = UIColor.whiteColor()
        return cell
    }
	
	override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	// MARK: - SFRestDelegate
	
	func request(request: SFRestRequest!, didLoadResponse dataResponse: AnyObject!) {
		
		let records = dataResponse.objectForKey("records") as! NSArray
		self.log(SFLogLevelInfo, msg: "Retrieved \(records.count) records")
		
		for record in records {
			let visitor: AnyObject = record.objectForKey("Visitor__r")!
			let dateNS = SFDateUtil.SOQLDateTimeStringToDate(record.objectForKey("Date__c") as! String)
			let date = NSDateFormatter.localizedStringFromDate(dateNS, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
			self.rows.append(Record(
				id: record.objectForKey("Id") as! String,
				date: date,
				vid: visitor.objectForKey("Id") as! String,
				fname: visitor.objectForKey("FirstName__c") as! String,
				lname: visitor.objectForKey("LastName__c") as! String
			))
		}
		
		dispatch_async(dispatch_get_main_queue(), {
			self.tableView.reloadData()
			SwiftSpinner.hide()
		})
	}
	
	func request(request: SFRestRequest!, didFailLoadWithError error: NSError!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve records: \(error)")
		dispatch_async(dispatch_get_main_queue(), {
			SwiftSpinner.hide()
		})
	}
	
	func requestDidCancelLoad(request: SFRestRequest!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve records: Server cancelled request")
		dispatch_async(dispatch_get_main_queue(), {
			SwiftSpinner.hide()
		})
	}
	
	func requestDidTimeout(request: SFRestRequest!) {
		self.log(SFLogLevelError, msg: "Failed to retrieve records: Request timed out")
		dispatch_async(dispatch_get_main_queue(), {
			SwiftSpinner.hide()
		})
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
		if segue.identifier == "EmployeeVisitorDetailSegue" {
			if let destination = segue.destinationViewController as? EmployeeVisitorDetailController {
				if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
					
				}
			}
		}
    }
	
}
