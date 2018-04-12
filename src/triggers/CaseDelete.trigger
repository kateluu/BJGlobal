trigger CaseDelete on Cases__c (after delete) {
	for (Cases__c c : Trigger.old) {
		try {		
			String emailBody = '';
			
			emailBody += '<h4>Information: </h4>';
			emailBody += '<p> Case Number: '                 + c.Name            				      + '</p>';
			emailBody += '<p> Daily Budget: '                + c.Daily_Budget__c 					  + '</p>';
			if (c.Account__c != null) {
				Account acc = [select Name from Account where id =: c.Account__c limit 1];
				emailBody += '<p> Linked Account: '          + acc.Name         					  + '</p>';
			}
			if (c.OwnerId != null) {
				User owner = [select Name from User where id =: c.OwnerId limit 1];
				emailBody += '<p> Owner: ' 				     + owner.Name 		   					  + '</p>';
			}
			User u = [select Name from User where id =: c.LastModifiedById limit 1];
			emailBody += '<p> Last Modified By: ' 			 + u.Name            					  + '</p>';
			
			emailBody += '<h4>Description: </h4>';				
			emailBody += '<p> Case Type: '			   		 + c.CaseType__c                          + '</p>';
			if (c.X2012_Original_Request_Date__c != null) {
				emailBody += '<p> Original Request Date: '	 + c.X2012_Original_Request_Date__c.format()+ '</p>';	
			}
			if (c.Cancellation_Date__c != null) {
				emailBody += '<p> Cancellation Date: '		 + c.Cancellation_Date__c.format()        + '</p>';	
			}
			emailBody += '<p> Website URL: '			     + c.X2012_Website_URL__c     			  + '</p>';
			emailBody += '<p> Case Origin: '			     + c.Case_Origin__c     				  + '</p>';
			emailBody += '<p> E-mail or Phone Summary: '	 + c.X2012_E_mail_or_Phone_Summary__c     + '</p>';
			emailBody += '<p> CM Comments: '			     + c.X2012_CM_Comments__c     			  + '</p>';
			emailBody += '<p> Action Taken to Save: '		 + c.X2012_Action_Taken_to_Save__c        + '</p>';
			emailBody += '<p> CM Proposed Action: '			 + c.X2012_CM_Proposed_Action__c     	  + '</p>';
			emailBody += '<p> Final Action (FOR MANAGERS): ' + c.X2012_Final_Action_FOR_MANAGERS__c   + '</p>';
			emailBody += '<p> Subject: '			   		 + c.Subject__c     					  + '</p>';
			emailBody += '<p> Description: '			     + c.Description__c     				  + '</p>';
			emailBody += '<p> Internal Comments: '			 + c.Internal_Comments__c     			  + '</p>';
			if (c.Competitor__c != null) {
				Competitor__c co = [select Name from Competitor__c where id =: c.Competitor__c limit 1];
				emailBody += '<p> Competitor: '	 			 + co.name     							  + '</p>';
			}
					
			emailBody += '<h4>Resolution: </h4>';
			emailBody += '<p> Account Resolution: '			 + c.Account_Resolution__c     			  + '</p>';
			emailBody += '<p> Billing Resolution: '			 + c.Billing_Resolution__c     			  + '</p>';
			if (c.Reassign_To__c != null) {
				User r = [select Name from User where id =: c.Reassign_To__c limit 1];
				emailBody += '<p> Reassign to (Client Manager) : '	 + r.name     					  + '</p>';
			}
			emailBody += '<p> 2 Weeks Notice to be applied: '+ c.X2012_2_Weeks_Notice_to_be_applied__c+ '</p>';
			emailBody += '<p> Credit Request Amount: '		 + c.Credit_Amount__c     				  + '</p>';
			emailBody += '<p> Refund Request Amount: '		 + c.Refund_Amount__c     				  + '</p>';
			emailBody += '<p> Downgrade Amount: '			 + c.Downgrade_Amount__c     			  + '</p>';
			emailBody += '<p> Refund Invoice(s): '			 + c.X2012_Refund_Invoice_s__c     		  + '</p>';
			emailBody += '<p> Void Invoice(s): '			 + c.X2012_Void_Invoice_s__c     		  + '</p>';
	
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			//String[] toAddresses   = new String[] {'bill.zhang@sponsoredlinx.com'};
			String[] toAddresses   = new String[] {'accounts@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Case Deletion');
			mail.setSubject('Case Deletion Notification');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} catch (Exception e) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   			String[] toAddresses   = new String[] { 'devteam@sponsoredlinx.com' };
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Case Deletion Fail');
			mail.setSubject('Fail to Send Case Deletion Notification');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(e.getMessage());
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} 
	}
}