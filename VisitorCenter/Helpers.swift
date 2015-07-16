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

func nullToString(val: AnyObject?) -> String {
	if val is NSNull {
		return ""
	} else {
		return val as! String
	}
}

struct Visitor {
	var date = ""
	var vid = ""
	var fname = ""
	var mname = ""
	var lname = ""
	var phone = ""
	var email = ""
	var org = ""
	var remark = ""
	var idtype = ""
	var idnum = ""
	var empName = ""
	var empDept = ""
	var photoUrl = ""
	var idUrl = ""
	var signUrl = ""
	var status = ""
}

func makeVisitor(record: AnyObject) -> Visitor {
	let user: AnyObject = record.objectForKey("User__r")!
	return Visitor(
		date: dateToString(record.objectForKey("Date__c") as! String),
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

func dateToString(soql: String) -> String {
	var formatter = NSDateFormatter()
	if region == "USA" {
		formatter.setLocalizedDateFormatFromTemplate(usFormat)
	} else {
		formatter.setLocalizedDateFormatFromTemplate(gbFormat)
	}
	return formatter.stringFromDate(SFDateUtil.SOQLDateTimeStringToDate(soql))
}

func isValidEmail(str: String) -> Bool {
	let regex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
	let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
	return emailTest.evaluateWithObject(str);
}

func isValidPhone(str: String) -> Bool {
	let regex = "\\b[0-9]{6,11}\\b"
	let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
	return phoneTest.evaluateWithObject(str)
}
