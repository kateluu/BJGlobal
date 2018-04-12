/*
    Send an email to the salesperson when the lead is assigned to him/her
*/
trigger EditLead on Lead__c (after update) {
	for (Lead__c newLead : Trigger.new) {
        Lead__c oldLead = Trigger.oldMap.get(newLead.Id);
        if (oldLead.Assigned_To_Id__c != newLead.Assigned_To_Id__c && newLead.Assigned_To_Id__c != null) {
            try {
                Account salesperson = [SELECT Id,Name,Email__c FROM Account where Id =:newLead.Assigned_To_Id__c limit 1];
                	                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses   = new String[] {salesPerson.email__c};
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Salesforce');
                mail.setSubject('Lead Assignment');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                
                String emailBody = '<table border=1 cellpadding=6>';
				emailBody += '<tbody>';
				
			    if(newLead.Name != null) 
			    	emailBody += '<tr><td>Name</td><td><a href="https://ap1.salesforce.com/'+newLead.Id+'">'+newLead.Name+'</a></td></tr>';
                if(newLead.Notes__c != null) 
                	emailBody += '<tr><td>Notes</td><td>'+newLead.Notes__c+'</td></tr>';
                if(newLead.Lead_Status__c != null) 
                	emailBody += '<tr><td>Lead Status</td><td>'+newLead.Lead_Status__c+'</td></tr>';
                if(newLead.First_Name__c != null)
                	emailBody += '<tr><td>First Name</td><td>'+newLead.First_Name__c+'</td></tr>';
                if(newLead.Last_Name__c != null)
                	emailBody += '<tr><td>Last Name</td><td>'+newLead.Last_Name__c+'</td></tr>';
                if(newLead.Company__c != null)
                	emailBody += '<tr><td>Company</td><td>'+newLead.Company__c+'</td></tr>';
                if(newLead.Phone__c != null)
                	emailBody += '<tr><td>Phone</td><td>'+newLead.Phone__c+'</td></tr>';
                if(newLead.Email__c != null)
                	emailBody += '<tr><td>Email</td><td>'+newLead.Email__c+'</td></tr>';
                if(newLead.Rating__c != null)
                	emailBody += '<tr><td>Rating</td><td>'+newLead.Rating__c+'</td></tr>';
                if(newLead.Title__c != null)
                	emailBody += '<tr><td>Title</td><td>'+newLead.Title__c+'</td></tr>';
                if(newLead.Street__c != null)
                	emailBody += '<tr><td>Street</td><td>'+newLead.Street__c+'</td></tr>';
                if(newLead.Website__c != null)
                	emailBody += '<tr><td>Website</td><td>'+newLead.Website__c+'</td></tr>';
                if(newLead.City__c != null)
                    emailBody += '<tr><td>City</td><td>'+newLead.City__c+'</td></tr>';
                if(newLead.Post_Code__c != null)
                	emailBody += '<tr><td>Post Code</td><td>'+newLead.Post_Code__c+'</td></tr>';
                if(newLead.Country__c != null)
                	emailBody += '<tr><td>Country</td><td>'+newLead.Country__c+'</td></tr>';
                if(newLead.Industry__c != null)
                	emailBody += '<tr><td>Industry</td><td>'+newLead.Industry__c+'</td></tr>';
                if(newLead.Lead_Value__c != null)
                	emailBody += '<tr><td>Lead Value</td><td>'+newLead.Lead_Value__c+'</td></tr>';
                if(newLead.Description__c != null)
                	emailBody += '<tr><td>Description</td><td>'+newLead.Description__c+'</td></tr>';
                if(newLead.Followup__c != null)
                	emailBody += '<tr><td>Followup</td><td>'+newLead.Followup__c+'</td></tr>';
                if(newLead.From_Source__c != null)
                	emailBody += '<tr><td>From Source</td><td>'+newLead.From_Source__c+'</td></tr>';
                if(newLead.From_Form__c != null)
                	emailBody += '<tr><td>From Form</td><td>'+newLead.From_Form__c+'</td></tr>';
                if(newLead.HTTP_Referer__c != null)
                	emailBody += '<tr><td>HTTP Referer</td><td>'+newLead.HTTP_Referer__c+'</td></tr>';
                if(newLead.HTTP_Useragent__c != null)
                	emailBody += '<tr><td>HTTP Useragent</td><td>'+newLead.HTTP_Useragent__c+'</td></tr>';
                if(newLead.IP_Address__c != null)
                	emailBody += '<tr><td>IP Address><td>'+newLead.IP_Address__c+'</td></tr>';
                if(newLead.Session_ID__c != null)
                	emailBody += '<tr><td>Session ID</td><td>'+newLead.Session_ID__c+'</td></tr>';

				emailBody += '</tbody>';
				emailBody += '</table>';
                
                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(Exception e){
                newLead.addError(e.getMessage());
            }
        }
	}
}