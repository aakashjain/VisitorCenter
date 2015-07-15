//
//  AdminRelatedDetailController.swift
//  VisitorCenter
//
//  Created by Aakash on 15/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class AdminRelatedDetailController: UITableViewController {
	
	var record = Visitor()
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
		switch (indexPath.section, indexPath.row) {
		case (0, 4):
			ImageViewController.url = self.photoUrl
			self.performSegueWithIdentifier("SearchShowImageSegue", sender: self)
		case(2, 2):
			ImageViewController.url = self.idUrl
			self.performSegueWithIdentifier("SearchShowImageSegue", sender: self)
		case (2, 3):
			ImageViewController.url = self.signUrl
			self.performSegueWithIdentifier("SearchShowImageSegue", sender: self)
		default:
			break
		}
	}
	
}
