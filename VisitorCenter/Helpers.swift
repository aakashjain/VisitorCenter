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