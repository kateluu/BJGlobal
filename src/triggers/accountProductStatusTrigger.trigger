trigger accountProductStatusTrigger on Account_Product__c (after insert, after update) {
    /**
      This trigger will create a client history when the product status change
    **/
    for (Account_Product__c newPro : Trigger.new) {
        if (Trigger.isInsert) { //insert a new product
            // only consider whether the new product is an once-off pay product or recursive pay product. They should all be 'Active'.
            if (newPro.product_status__c != null && newPro.Recurring_Period__c != null && newPro.Recurring_Period__c != 'N/A') {
              try {
                  Client_History__c ch = new Client_History__c();
                  ch.Account_Product__c = newPro.Id;
                  ch.Type__c = newPro.product_status__c;
                  ch.Name = newPro.product_status__c + ' at ' + Date.today().format(); 
                  ch.Sold_To_Pause__c = newPro.Sold_To_Pause__c; 
                  ch.start_date__c = Date.today();
                  /*if (newPro.Recurring_Period__c == null || newPro.Recurring_Period__c == 'N/A') { //once-off product
                      ch.end_date__c = Date.today();
                  }*/
                  system.debug(ch);
                  insert ch;
              } catch (Exception e) {
                System.debug('ERROR: '+e);
            newPro.addError('There is a problem creating client history: ' + e);
              }
            }
            
            // create a converto project when converto management product is created
            if(newPro.Name.contains('ConvertoPages') && 
                   newPro.Recurring_Period__c != null && 
                   newPro.Recurring_Period__c != 'N/A'){

        String projectName = [select Name from Account where Id  = :newPro.Account__c][0].Name;
        if (projectName.Length() >= 68){
          projectName = projectName.substring(0, 68);
        }
        projectName = projectName + ' - Converto';

        SFDC_Projects__c project   = new SFDC_Projects__c();
        project.Account__c         = newPro.Account__c;
        project.Account_Product__c = newPro.Id;
        project.Project_Type__c    = 'ConvertoPages';
        project.Name               = projectName;
        project.Email__c           = [select username__c from Account where Id =: newPro.Account__c][0].username__c;
        project.Phone_Number__c    = [select Phone from Contact where AccountId =: newPro.Account__c and Title = 'Billing'][0].Phone;
        project.Sold_by__c         = 'Unknown';
        insert project;
            }
            
        } else { // update a product
            // make no sense to change the status of a once-off product, but it happened! We just ignore it.
            Account_product__c oldPro = Trigger.oldMap.get(newPro.Id);
            if (newPro.Product_Status__c != oldPro.Product_status__c && newPro.product_status__c != null) {
                if (oldPro.Recurring_Period__c != null && oldPro.Recurring_Period__c != 'N/A') { //only create for recursive payment product
                    // modify the previous product history
                    try {
                      Client_History__c[] c = [select start_date__c, end_date__c from client_history__c where Account_Product__c =: newPro.Id and end_date__c = null limit 1];
                      if (c.size() != 0) {
                        //Sometimes the status change more than one time in a day. So delete the former one in the same date.
                        if (c[0].start_date__c == Date.today()) {
                          delete c;
                        } else {
                          c[0].end_date__c = Date.today().addDays(-1);
                          update c;
                        }
                      }
                      
                      // add a new history
                      Client_History__c ch = new Client_History__c();
                      ch.Type__c = newPro.product_status__c;
                      ch.Account_Product__c = newPro.Id;
                      ch.Name = newPro.product_status__c + ' at ' + Date.today().format(); 
                      ch.start_date__c = Date.today();
                      if (newPro.product_status__c == 'Cancelled') { //cancel 
                          ch.end_date__c = Date.today();
                      }
                      ch.Sold_To_Pause__c = newPro.Sold_To_Pause__c; 
                      // end_date__c = null for active and pause
                      insert ch;
                    } catch (Exception e) {
                      System.debug('ERROR: '+e);
                newPro.addError('There is a problem creating client history: ' + e);
                    }
                }
                
                //send reminder email to client when his facebook or adwords management service is being cancelled
                if(newPro.product_status__c == 'Cancelled' && (newPro.name.contains('Facebook') || newPro.name.contains('Adwords'))) { 
          Contact contact = [Select Id, Name, firstName, lastName, Email From Contact Where AccountId =:newPro.Account__c And Title = 'Billing' limit 1];
          SLX_Product__c product = [select company_name__c from SLX_Product__c where id =: newPro.SLX_Product__c limit 1];
             Company__c company = [select Name, Customer_Service_Email__c, Phone__c, Website__c from Company__c where Name =: product.company_name__c limit 1];
       
                  String template = 'Adwords_Account_Cancellation_Reminder';
                  if(newPro.name.contains('Facebook')) {
                    template = 'Facebook_Account_Cancellation_Reminder';
                  }
                  EmailTemplate email_template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName =:template];
          String body = email_template.Body;
          String subject = email_template.Subject;
          
          body = body.replace('[FIRSTNAME]', contact.firstName);
          body = body.replace('[PRODUCTNAME]', newPro.name);
          body = body.replace('[COMPANY_NAME]', company.Name);
          body = body.replace('[COMPANY_PHONE]', company.phone__c);
          body = body.replace('[COMPANY_WEBSITE]', company.website__c);
          body = body.replace('[CUSTOMER_SERVICE_EMAIL]', company.customer_service_email__c);
        
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setToAddresses(new String[] {contact.email});
          mail.setReplyTo(company.customer_service_email__c);
          mail.setSenderDisplayName('Customer Service');
          mail.setSubject(subject);
          mail.setPlainTextBody(body);
          mail.setUseSignature(false);
          Messaging.sendEmail(new Messaging.Email[] { mail });
                }
            }
        }
    }
}