//
//  Helpers.swift
//  VisitorCenter
//
//  Created by Aakash on 13/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

func requestForAttachment(bodyUrl: String) -> NSMutableURLRequest {
	let oauth = SFRestAPI.sharedInstance().coordinator.credentials
	let url = NSURL(string: "\(oauth.instanceUrl)\(bodyUrl)")!
	let header = "OAuth \(oauth.accessToken)"
	var request = NSMutableURLRequest(URL: url)
	request.addValue(header, forHTTPHeaderField: "Authorization")
	return request
}

func sfRestRequestForAttachment(bodyUrl: String) -> SFRestRequest {
	var request = SFRestRequest(method: SFRestMethodGET, path: bodyUrl, queryParams: nil)
	request.parseResponse = false
	return request
}

func nullToString(val: AnyObject?) -> String {
	if val is NSNull {
		return ""
	} else {
		return val as! String
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
		idtype: record.objectForKey("IDType__c") as! String,
		idnum: record.objectForKey("IDNumber__c") as! String,
		empName: user.objectForKey("Name") as! String,
		empDept: nullToString(user.objectForKey("Department")),
		photoUrl: "", idUrl: "", signUrl: "",
		status: record.objectForKey("Status__c") as! String
	)
}