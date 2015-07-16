//
//  VisitorForm2Controller.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class VisitorForm2Controller: UITableViewController {
	
	static var rowData = []
	static var selected = false
	static var selectedPath = NSIndexPath()
	static var empId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
		
		if VisitorForm2Controller.rowData.count == 0 {
			
			SwiftSpinner.show("Loading...")
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
				
				let client = ZKSforceClient()
				client.login(visitorUser, password: visitorPass)
				let results: ZKQueryResult = client.query("SELECT Id, Name, Department FROM User WHERE VisitorCenterApp_IsEmployee__c = true and Country = '\(region)' ORDER BY Name ASC, Department ASC")
				client.logout()
				
				dispatch_async(dispatch_get_main_queue(), {
					
					VisitorForm2Controller.rowData = results.records()
					self.tableView.reloadData()
					SwiftSpinner.hide()
					
				})
			})
		}
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if VisitorForm2Controller.selected {
			self.tableView.selectRowAtIndexPath(VisitorForm2Controller.selectedPath, animated: true, scrollPosition: .None)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VisitorForm2Controller.rowData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		cell.textLabel!.text = VisitorForm2Controller.rowData.objectAtIndex(indexPath.row).fieldValue("Name") as! String!
		cell.detailTextLabel!.text = VisitorForm2Controller.rowData[indexPath.row].fieldValue("Department") as! String!
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		VisitorForm2Controller.selected = true
		VisitorForm2Controller.selectedPath = indexPath
		VisitorForm2Controller.empId = VisitorForm2Controller.rowData[indexPath.row].fieldValue("Id") as! String
		performSegueWithIdentifier("VisitorForm3Segue", sender: self)
	}

}
