public with sharing class SnapshotNotification {

	//public String objectName {get;set;}
	//public String senderEmail {get;set;}
	public Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
	

	public SnapshotNotification(){
		setupNotificationContent();
		sendoutNotification();
	}

	private void setupNotificationContent(){
	//get the email template
        EmailTemplate template = [Select id, HtmlValue from EmailTemplate where name = 'SEO Keyword Unrank Notification'];


		//get records
		List<Snapshot_Keyword_Unrank__c>  records = [SELECT id, Name,Project_Owner_Email__c ,Google_Unranked_Count__c , Google_Unranked_Count_DaysAgo2__c, Google_Unranked_Increase_2_days__c ,Project_Owner_Name__c, 
															Keyword_Count__c, SEO_Website__c, URL__c 
													 FROM Snapshot_Keyword_Unrank__c 
													 WHERE CreatedDate = TODAY];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();											 
		String emailBody = '';
		String htmlBody = '';		

		for( Snapshot_Keyword_Unrank__c item: records){
			if((item.Project_Owner_Email__c  <> null) && (item.Project_Owner_Email__c  <> '')){
				// get user records
		        
				try{	
			    emailBody = '';
		            mail = new Messaging.SingleEmailMessage();
		            // get template
		            mail.setTemplateID(template.Id); 
		            String[] toAddresses = new String[]{};
		            toAddresses.add(item.Project_Owner_Email__c);

		            
		            // set email content
		            mail.setToAddresses(toAddresses);
		            mail.setSenderDisplayName('SeoKeywords');
                    mail.setSubject('SEO Notification for increase in unranked keywords');
		            mail.setBccSender(false);
		            mail.setUseSignature(false);
		            htmlBody = template.HtmlValue;
		            //htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.Google_Unranked_Increase_2_days__c}', item.Google_Unranked_Increase_2_days__c.toPlainString());
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.Google_Unranked_Count__c}', ''+item.Google_Unranked_Count__c.toPlainString());
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.Google_Unranked_Count_DaysAgo2__c}', ''+item.Google_Unranked_Count_DaysAgo2__c.toPlainString());
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.Keyword_Count__c}', ''+item.Keyword_Count__c.toPlainString());
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.Project_Owner_Name__c}', item.Project_Owner_Name__c);
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.URL__c}', item.URL__c);
		            htmlBody = htmlBody.replace('{!Snapshot_Keyword_Unrank__c.SEO_Website__c}', item.SEO_Website__c);
		            mail.setHtmlBody(htmlBody);        
		            mails.add(mail);
	            } catch (Exception e) {
	            	  mail = new Messaging.SingleEmailMessage();
		              emailBody = 'Cannot get email address from CM ' + e.getMessage();
		              String[] toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
		              mail.setSaveAsActivity(false);
		              mail.setToAddresses(toAddresses);
		              mail.setSubject('SeoKeywords Notification Error');
		              mail.setSenderDisplayName('SeoKeywords Notification Error');		              
		              mail.setBccSender(false);
		              mail.setUseSignature(false);
		              mail.setHtmlBody(emailBody);
		              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		              return;
	            }
			}
			
		}
	}

	private void sendoutNotification(){
        try{
        	if ( !Test.isRunningTest() ){
		          Messaging.sendEmail(mails);
		    }
          }catch(Exception e){
            System.debug(e.getMessage());
          }
    }
	
}