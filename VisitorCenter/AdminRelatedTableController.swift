//
//  AdminRelatedTableController.swift
//  VisitorCenter
//
//  Created by Aakash on 15/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class AdminRelatedTableController: UITableViewController {
	
	static var criteria = ""
	static var clause = ""
	static var id = ""
	var rows = [Visitor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.backgroundColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		self.refreshControl!.tintColor = UIColor(red: 51/255.0, green: 59/255.0, blue: 61/255.0, alpha: 1.0)
		dispatch_async(dispatch_get_main_queue(), {
			self.refreshControl!.beginRefreshing()
		})
		
		let query = "select Id, Date__c, FirstName__c, MiddleName__c, LastName__c, Organization__c, Phone__c, Email__c, Remarks__c, IDType__c, IDNumber__c, Status__c, User__r.Name, User__r.Department from Visitor__c where User__r.Country = '\(region)' and \(AdminRelatedTableController.clause) and Id != '\(AdminRelatedTableController.id)' order by Date__c asc"
		let request = SFRestAPI.sharedInstance().requestForQuery(query)
		SFRestAPI.sharedInstance().sendRESTRequest(request, failBlock: { (error) -> Void in
			self.log(SFLogLevelError, msg: "Failed to load: \(error)")
		}) { (response) -> Void in
			let records = response.objectForKey("records") as! NSArray
			for record in records {
				self.rows.append(makeVisitor(record))
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
				self.refreshControl!.endRefreshing()
                self.refreshControl = nil
			})
		}
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Searching by \(AdminRelatedTableController.criteria)"
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.rows.count == 0 {
            var messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = "No matches found."
            messageLabel.textColor = UIColor.lightGrayColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle  = .None
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
        }
        return self.rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		var row = rows[indexPath.row]
		cell.textLabel!.text = row.date
		cell.detailTextLabel!.text = "\(row.fname) \(row.lname)"
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SearchDetailSegue" {
			if let dest = segue.destinationViewController as? AdminRelatedDetailController {
				dest.record = self.rows[self.tableView.indexPathForCell(sender as! UITableViewCell)!.row]
			}
		}
    }

}
