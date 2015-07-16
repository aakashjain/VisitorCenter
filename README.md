# VisitorCenter
Native iOS app for a company's visitor registration process using Salesforce

##Salesforce Org setup

###User
- VisitorApp_IsEmployee__c: Checkbox: Indicates that the user is to be given employee access in the app.
- VisitorApp_IsAdmin__c: Checkbox: Indicates that the user is to be given admin access in the app.
- Country: Text: This standard field needs to be filled out for all employees and admins. The app restricts
Visitor__c records available to a user by their country. Currently the app is hardcoded to support USA and UK.

###Visitor__c
- FirstName__c: Text, Reqd
- MiddleName__c: Text
- LastName__c: Text, Reqd
- Organization__c: Text
- Phone__c: Phone, Reqd
- Email__c: Email, Reqd
- IDType__c: Picklist: Voter Card, Driver License, Passport, PAN, SSN
- IDNumber__c: Text, Reqd
- Date__c: DateTime, Reqd
- Status__c: Picklist: Pending, Checkedin, Checkedout, Rejected
- User__c: Lookup(User), Reqd
- Remarks__c: Text

###Attachment
No additional fields required. When adding a record to Attachment, 
ParentId must be set to the related Visitor__c record's Id.

###Trigger for notification email
When a Visitor__c record is updated from Pending to Checkedin, the related User is sent an email notifying
them of the visitor's name and date/time of visit.
[See this gist.](https://gist.github.com/aakashjain/01e82fef1c316dda0bee)

