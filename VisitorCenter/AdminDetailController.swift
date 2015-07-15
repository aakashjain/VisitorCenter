//
//  AdminDetailController.swift
//  VisitorCenter
//
//  Created by Aakash on 15/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class AdminDetailController: UITableViewController {
	
	var record = Visitor()
	var presentingRow = 0
	var photoUrl = ""
	var idUrl = ""
	var signUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
		
		let request = SFRestAPI.sharedInstance().requestForQuery("select Body from Attachment where ParentId = '\(self.record.vid)' order by Name asc")
		SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to fetch image URLs: \(error)")
		}) { (result) -> Void in
			let records = result.objectForKey("records") as! NSArray
			self.idUrl = records[0].objectForKey("Body") as! String
			self.photoUrl = records[1].objectForKey("Body") as! String
			self.signUrl = records[2].objectForKey("Body") as! String
			dispatch_async(dispatch_get_main_queue(), {
				let rows = [NSIndexPath(forRow: 4, inSection: 0), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 3, inSection: 2)]
				for row in rows {
					self.tableView.cellForRowAtIndexPath(row)?.userInteractionEnabled = true
				}
				self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: .None)
			})
		}
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		dispatch_async(dispatch_get_main_queue(), {
			self.tableView.reloadData()
		})
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell.detailTextLabel!.text = "\(self.record.fname) \(self.record.mname) \(self.record.lname)"
			case 1:
				cell.detailTextLabel!.text = self.record.org
			case 2:
				cell.detailTextLabel!.text = self.record.email
			case 3:
				cell.detailTextLabel!.text = self.record.phone
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 0:
				cell.detailTextLabel!.text = self.record.status
			case 1:
				cell.detailTextLabel!.text = self.record.date
			case 2:
				cell.detailTextLabel!.text = self.record.empName
			case 3:
				cell.detailTextLabel!.text = self.record.empDept
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				cell.detailTextLabel!.text = self.record.idnum
			case 1:
				cell.detailTextLabel!.text = self.record.idtype
			default:
				break
			}
		case 3:
			cell.textLabel!.text = self.record.remark
		default:
			break
		}
		
        return cell
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				AdminRelatedTableController.criteria = "Name"
				AdminRelatedTableController.clause = "FirstName__c = '\(self.record.fname)' and LastName__c = '\(self.record.lname)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			case 1:
				AdminRelatedTableController.criteria = "Organization"
				AdminRelatedTableController.clause = "Organization__c = '\(self.record.org)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			case 2:
				AdminRelatedTableController.criteria = "Email"
				AdminRelatedTableController.clause = "Email__c = '\(self.record.email)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			case 3:
				AdminRelatedTableController.criteria = "Phone no."
				AdminRelatedTableController.clause = "Phone__c = '\(self.record.phone)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			case 4:
				ImageViewController.url = self.photoUrl
				self.performSegueWithIdentifier("ShowImageSegue", sender: self)
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 2:
				AdminRelatedTableController.criteria = "Employee"
				AdminRelatedTableController.clause = "User__r.Name = '\(self.record.empName)' and User__r.Department = '\(self.record.empDept)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				AdminRelatedTableController.criteria = "ID no. & type"
				AdminRelatedTableController.clause = "IDNumber__c = '\(self.record.idnum)' and IDType__c = '\(self.record.idtype)'"
				self.performSegueWithIdentifier("SearchSegue", sender: self)
			case 2:
				ImageViewController.url = self.idUrl
				self.performSegueWithIdentifier("ShowImageSegue", sender: self)
			case 3:
				ImageViewController.url = self.signUrl
				self.performSegueWithIdentifier("ShowImageSegue", sender: self)
			default:
				break
			}
		case 3:
			var box = UIAlertController(title: "Remarks", message: "Enter your remarks", preferredStyle: .Alert)
			box.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
				textField.text = self.record.remark
			})
			box.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
				let field = box.textFields![0] as! UITextField
				let remark = field.text
				let request = SFRestAPI.sharedInstance().requestForUpdateWithObjectType("Visitor__c", objectId: self.record.vid, fields: ["Remarks__c": remark])
				SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { (error) -> Void in
					self.log(SFLogLevelError, msg: "Failed to update remark: \(error)")
				}, completeBlock: { (response) -> Void in
					dispatch_async(dispatch_get_main_queue(), {
						self.record.remark = remark
						self.tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text = remark
						if self.record.status == "Pending" {
							(self.navigationController?.viewControllers[0] as! AdminPendingTableController).pendingRows[self.presentingRow].remark = remark
						} else {
							(self.navigationController?.viewControllers[0] as! AdminPendingTableController).checkinRows[self.presentingRow].remark = remark
						}
					})
				})
			}))
			box.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			self.presentViewController(box, animated: true, completion: nil)
		default:
			break
		}
	}
	
}
