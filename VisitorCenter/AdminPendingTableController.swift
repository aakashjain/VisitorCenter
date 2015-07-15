//
//  AdminPendingTableController.swift
//  VisitorCenter
//
//  Created by Aakash on 14/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class AdminPendingTableController: UITableViewController {
	
	var pendingRows = [Visitor]()
	var checkinRows = [Visitor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.backgroundColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		self.refreshControl!.tintColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		self.refreshControl!.addTarget(self, action: "sendRequest", forControlEvents: .ValueChanged)
		self.refreshControl!.beginRefreshing()
		self.sendRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func sendRequest() {
		let pendQuery = "select Id, Date__c, FirstName__c, MiddleName__c, LastName__c, Organization__c, Phone__c, Email__c, Remarks__c, User__r.Name, User__r.Department  from Visitor__c where Status__c = 'Pending' order by Date__c asc"
		let pendRequest: SFRestRequest = SFRestAPI.sharedInstance().requestForQuery(pendQuery)
		SFRestAPI.sharedInstance().sendRESTRequest(pendRequest, failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to retrieve records: \(error)")
			dispatch_async(dispatch_get_main_queue(), {
				self.refreshControl!.endRefreshing()
			})
		}) { (result) -> Void in
			let records = result.objectForKey("records") as! NSArray
			self.pendingRows.removeAll(keepCapacity: false)
			for record in records {
				self.pendingRows.append(self.makeVisitor(record))
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
		}
		let checkinQuery = "select Id, Date__c, FirstName__c, MiddleName__c, LastName__c, Organization__c, Phone__c, Email__c, Remarks__c, User__r.Name, User__r.Department  from Visitor__c where Status__c = 'Checkedin' order by Date__c asc"
		let checkinRequest: SFRestRequest = SFRestAPI.sharedInstance().requestForQuery(checkinQuery)
		SFRestAPI.sharedInstance().sendRESTRequest(checkinRequest, failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to retrieve records: \(error)")
			dispatch_async(dispatch_get_main_queue(), {
				self.refreshControl!.endRefreshing()
			})
		}) { (result) -> Void in
			let records = result.objectForKey("records") as! NSArray
			self.checkinRows.removeAll(keepCapacity: false)
			for record in records {
				self.checkinRows.append(self.makeVisitor(record))
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			self.refreshControl!.endRefreshing()
		}
	}
	
	func makeVisitor(record: AnyObject) -> Visitor {
		let dateNS = SFDateUtil.SOQLDateTimeStringToDate(record.objectForKey("Date__c") as! String)
		let date = NSDateFormatter.localizedStringFromDate(dateNS, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
		let user: AnyObject = record.objectForKey("User__r")!
		return Visitor(
			date: date,
			vid: record.objectForKey("Id") as! String,
			fname: record.objectForKey("FirstName__c") as! String,
			mname: nullToString(record.objectForKey("MiddleName__c")),
			lname: record.objectForKey("LastName__c") as! String,
			phone: record.objectForKey("Phone__c") as! String,
			email: record.objectForKey("Email__c") as! String,
			org: nullToString(record.objectForKey("Organization__c")),
			remark: nullToString(record.objectForKey("Remarks__c")),
			empName: user.objectForKey("Name") as! String,
			empDept: nullToString(user.objectForKey("Department")),
			photoUrl: "", idUrl: "", signUrl: ""
		)
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return self.pendingRows.count
		} else {
			return self.checkinRows.count
		}
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0{
			return "PENDING VISITORS"
		} else {
			return "CHECKED IN VISITORS"
		}
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if (section == 0 && self.pendingRows.count == 0) || (section == 1 && self.checkinRows.count == 0) {
			return 0
		}
		return UITableViewAutomaticDimension
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		var data: Visitor
		if indexPath.section == 0 {
			data = self.pendingRows[indexPath.row]
		} else {
			data = self.checkinRows[indexPath.row]
		}
		cell.textLabel!.text = data.date
		cell.detailTextLabel!.text = "\(data.fname) \(data.lname)"
		cell.textLabel!.textColor = UIColor.whiteColor()
		cell.detailTextLabel!.textColor = buttonColor
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		if indexPath.section == 0 {
			let accept = UITableViewRowAction(style: .Normal, title: "Accept") { (action, path) -> Void in
				self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
				let checkinRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.pendingRows[path.row].vid, fields: ["Status__c": "Checkedin"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkinRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.checkinRows.append(self.pendingRows[indexPath.row])
						self.pendingRows.removeAtIndex(indexPath.row)
						self.tableView.reloadData()
					})
				})
			}
			let reject = UITableViewRowAction(style: .Normal, title: "Reject") { (action, path) -> Void in
				self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
				let checkinRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.pendingRows[path.row].vid, fields: ["Status__c": "Rejected"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkinRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.pendingRows.removeAtIndex(indexPath.row)
						self.tableView.reloadData()
					})
				})
			}
			reject.backgroundColor = UIColor.redColor()
			return [accept, reject]
		} else {
			let checkout = UITableViewRowAction(style: .Normal, title: "Checkout") { (action, path) -> Void in
				self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
				let checkoutRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.checkinRows[path.row].vid, fields: ["Status__c": "Checkedout"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkoutRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.checkinRows.removeAtIndex(indexPath.row)
						self.tableView.reloadData()
					})
				})
			}
			return [checkout]
		}
	}
	
	func failAlert() {
		let alert = UIAlertController(title: "Failed!", message: "Please try again", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
    }
	
	@IBAction func logout(sender: AnyObject) {
		var logoutAlert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .Alert)
		logoutAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
			SFAuthenticationManager.sharedManager().logoutAllUsers()
			self.performSegueWithIdentifier("AdminLogoutUnwind", sender: self)
		}))
		logoutAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
		self.presentViewController(logoutAlert, animated: true, completion: nil)
	}

}
