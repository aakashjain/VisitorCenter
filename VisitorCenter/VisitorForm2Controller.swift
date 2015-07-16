//
//  VisitorForm2Controller.swift
//  VisitorCenter
//
//  Created by Aakash on 11/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class VisitorForm2Controller: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
	
	static var rowData = [(String, String, String)]()
	static var empId = ""
	static var regionChanged = false
	
	var searcher = UISearchController()
	var filtered = [(String, String, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
		
		self.searcher = UISearchController(searchResultsController: nil)
		self.searcher.searchResultsUpdater = self
		self.searcher.searchBar.delegate = self
		self.searcher.dimsBackgroundDuringPresentation = false
		self.searcher.searchBar.scopeButtonTitles = ["Name", "Department"]
		self.searcher.searchBar.sizeToFit()
		
		if VisitorForm2Controller.rowData.count == 0 || VisitorForm2Controller.regionChanged {
            
            self.refreshControl = UIRefreshControl()
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl!.beginRefreshing()
            })
            
			VisitorForm2Controller.regionChanged = false
			VisitorForm2Controller.rowData.removeAll(keepCapacity: false)
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
				
				let client = ZKSforceClient()
				client.login(visitorUser, password: visitorPass)
				let results: ZKQueryResult = client.query("SELECT Id, Name, Department FROM User WHERE VisitorCenterApp_IsEmployee__c = true and Country = '\(region)' ORDER BY Name ASC, Department ASC")
				client.logout()
				
				for record in results.records() {
					VisitorForm2Controller.rowData.append((record.fieldValue("Name") as! String, record.fieldValue("Department") as! String, record.fieldValue("Id") as! String))
				}
				
				dispatch_async(dispatch_get_main_queue(), {
					self.tableView.reloadData()
                    self.tableView.tableHeaderView = self.searcher.searchBar
					self.refreshControl!.endRefreshing()
                    self.refreshControl = nil
				})
			})
		}
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.searcher.active {
			return self.filtered.count
		} else {
			return VisitorForm2Controller.rowData.count
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
		var row: (String, String, String)
		if self.searcher.active {
			row = self.filtered[indexPath.row]
		} else {
			row = VisitorForm2Controller.rowData[indexPath.row]
		}
		cell.textLabel!.text = row.0
		cell.detailTextLabel!.text = row.1
		return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var row: (String, String, String)
		if self.searcher.active {
			row = self.filtered[indexPath.row]
		} else {
			row = VisitorForm2Controller.rowData[indexPath.row]
		}
		VisitorForm2Controller.empId = row.2
		performSegueWithIdentifier("VisitorForm3Segue", sender: self)
	}
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		self.updateSearchResultsForSearchController(self.searcher)
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		self.filtered.removeAll(keepCapacity: false)
		let text = searchController.searchBar.text.lowercaseString
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			for row in VisitorForm2Controller.rowData {
				if row.0.lowercaseString.rangeOfString(text) != nil {
					filtered.append(row)
				}
			}
		} else {
			for row in VisitorForm2Controller.rowData {
				if row.1.lowercaseString.rangeOfString(text) != nil {
					filtered.append(row)
				}
			}
		}
		dispatch_async(dispatch_get_main_queue(), {
			self.tableView.reloadData()
		})
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.searcher.active = false
	}

}
