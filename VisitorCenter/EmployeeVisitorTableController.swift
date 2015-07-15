//
//  EmployeeVisitorTableController.swift
//  VisitorCenter
//
//  Created by Aakash on 10/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class EmployeeVisitorTableController: UITableViewController {
	
	var rows = [Visitor]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.backgroundColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		self.refreshControl!.tintColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		self.refreshControl!.addTarget(self, action: "sendRequest", forControlEvents: .ValueChanged)
		self.refreshControl!.beginRefreshing()
		self.sendRequest()
    }
	
	func sendRequest() {
		let userId: String = SFAuthenticationManager.sharedManager().idCoordinator.idData.userId
		let query = "select Id, Date__c, FirstName__c, MiddleName__c, LastName__c, Organization__c, Phone__c, Email__c from Visitor__c where User__c = '\(userId)' and Status__c = 'Checkedin' order by Date__c asc"
		let request: SFRestRequest = SFRestAPI.sharedInstance().requestForQuery(query)
		SFRestAPI.sharedInstance().sendRESTRequest(request,
		failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to retrieve records: \(error)")
			dispatch_async(dispatch_get_main_queue(), {
				self.refreshControl!.endRefreshing()
			})
		},
		completeBlock: { (dataResponse) -> Void in
			let records = dataResponse.objectForKey("records") as! NSArray
			self.log(SFLogLevelInfo, msg: "Retrieved \(records.count) records")
			self.rows.removeAll(keepCapacity: false)
			
			for record in records {
				let dateNS = SFDateUtil.SOQLDateTimeStringToDate(record.objectForKey("Date__c") as! String)
				let date = NSDateFormatter.localizedStringFromDate(dateNS, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
				self.rows.append(Visitor(
					date: date,
					vid: record.objectForKey("Id") as! String,
					fname: record.objectForKey("FirstName__c") as! String,
					mname: nullToString(record.objectForKey("MiddleName__c")),
					lname: record.objectForKey("LastName__c") as! String,
					phone: record.objectForKey("Phone__c") as! String,
					email: record.objectForKey("Phone__c") as! String,
					org: nullToString(record.objectForKey("Organization__c")),
					remark: "", empName: "", empDept: "", photoUrl: "", idUrl: "", signUrl: ""
				))
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
				self.refreshControl!.endRefreshing()
			})
		})
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if self.rows.count == 0 {
			var messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
			messageLabel.text = "No visitors found. Pull down to refresh."
			messageLabel.textColor = UIColor.lightGrayColor()
			messageLabel.numberOfLines = 0
			messageLabel.textAlignment = .Center
			messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
			messageLabel.sizeToFit()
			self.tableView.backgroundView = messageLabel
			self.tableView.separatorStyle  = .None
			return 0
		} else {
			self.tableView.backgroundView = nil
			self.tableView.separatorStyle = .SingleLine
			return 1
		}
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		let row = rows[indexPath.row]
		cell.textLabel?.text = row.date
		cell.textLabel?.textColor = UIColor.whiteColor()
		cell.detailTextLabel?.text = "\(row.fname) \(row.lname)"
		cell.detailTextLabel?.textColor = buttonColor
        return cell
    }
	
	@IBAction func logout(sender: AnyObject) {
		var logoutAlert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .Alert)
		logoutAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
			SFAuthenticationManager.sharedManager().logoutAllUsers()
			self.performSegueWithIdentifier("EmployeeLogoutUnwind", sender: self)
		}))
		logoutAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
		self.presentViewController(logoutAlert, animated: true, completion: nil)
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "EmployeeVisitorDetailSegue" {
			if let destination = segue.destinationViewController as? EmployeeVisitorDetailController {
				if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
					destination.record = rows[indexPath.row]
				}
			}
		}
		super.prepareForSegue(segue, sender: sender)
    }
	
}
