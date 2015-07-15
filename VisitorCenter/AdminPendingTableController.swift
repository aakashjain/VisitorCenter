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
				let dateNS = SFDateUtil.SOQLDateTimeStringToDate(record.objectForKey("Date__c") as! String)
				let date = NSDateFormatter.localizedStringFromDate(dateNS, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
				let user: AnyObject = record.objectForKey("User__r")!
				self.pendingRows.append(Visitor(
					date: date,
					vid: record.objectForKey("Id") as! String,
					fname: record.objectForKey("FirstName__c") as! String,
					mname: record.objectForKey("MiddleName__c") as! String,
					lname: record.objectForKey("LastName__c") as! String,
					phone: record.objectForKey("Phone__c") as! String,
					email: record.objectForKey("Phone__c") as! String,
					org: record.objectForKey("Organization__c") as! String,
					remark: record.objectForKey("Remark__c") as! String,
					empName: user.objectForKey("Name") as! String,
					empDept: user.objectForKey("Department") as! String,
					photoUrl: "", idUrl: "", signUrl: ""
				))
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
				let dateNS = SFDateUtil.SOQLDateTimeStringToDate(record.objectForKey("Date__c") as! String)
				let date = NSDateFormatter.localizedStringFromDate(dateNS, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
				let user: AnyObject = record.objectForKey("User__r")!
				self.checkinRows.append(Visitor(
					date: date,
					vid: record.objectForKey("Id") as! String,
					fname: record.objectForKey("FirstName__c") as! String,
					mname: record.objectForKey("MiddleName__c") as! String,
					lname: record.objectForKey("LastName__c") as! String,
					phone: record.objectForKey("Phone__c") as! String,
					email: record.objectForKey("Phone__c") as! String,
					org: record.objectForKey("Organization__c") as! String,
					remark: record.objectForKey("Remark__c") as! String,
					empName: user.objectForKey("Name") as! String,
					empDept: user.objectForKey("Department") as! String,
					photoUrl: "", idUrl: "", signUrl: ""
				))
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			self.refreshControl!.endRefreshing()
		}
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
        /*if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }*/
    }
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		if indexPath.section == 0 {
			let accept = UITableViewRowAction(style: .Normal, title: "Accept") { (action, path) -> Void in
				let checkinRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.pendingRows[path.row].vid, fields: ["Status__c": "Checkedin"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkinRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					self.checkinRows.append(self.pendingRows[path.row])
					self.pendingRows.removeAtIndex(path.row)
					self.tableView.reloadData()
				})
			}
			accept.backgroundColor = UIColor.blueColor()
			let reject = UITableViewRowAction(style: .Normal, title: "Reject") { (action, path) -> Void in
				let checkinRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.pendingRows[path.row].vid, fields: ["Status__c": "Rejected"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkinRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					self.pendingRows.removeAtIndex(path.row)
					self.tableView.reloadData()
				})
			}
			return [accept, reject]
		} else {
			let checkout = UITableViewRowAction(style: .Normal, title: "Checkout") { (action, path) -> Void in
				let checkoutRequest = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.checkinRows[path.row].vid, fields: ["Status__c": "Checkedout"])
				SFRestAPI.sharedInstance().sendRESTRequest(checkoutRequest, failBlock: { (error) -> Void in
					self.failAlert()
				}, completeBlock: { (response) -> Void in
					self.checkinRows.removeAtIndex(path.row)
					self.tableView.reloadData()
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
	
	/*override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
		if indexPath.section == 0 {
			return "Reject"
		} else {
			return "Checkout"
		}
	}*/

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
