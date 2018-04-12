trigger OpportunityUpdate on SLXOpportunity__c (after update, after insert, before insert) {

    Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
    AccountShare[] shares = new List<AccountShare>();
    SLXOpportunity__Share[] oppShares = new List<SLXOpportunity__Share>();
    User u;

    // Load the owner user and createdby user for each opp, to avoid doing it inside the loop
    List<Id> requiredUserIds = new List<Id>();
    for(SLXOpportunity__c new_opp : Trigger.new) {
        requiredUserIds.add(new_opp.CreatedById);
        requiredUserIds.add(new_opp.OwnerId);
    }
    Map<Id, User> mapUsers = new Map<Id, User>([ SELECT Id, IsActive, Email FROM User WHERE Id =: requiredUserIds ]);

    if (Trigger.isUpdate) {
        for(SLXOpportunity__c new_opp : Trigger.new) {

            // Share the opp with the user who created it
            if (new_opp.CreatedById != new_opp.OwnerId){
                // Make sure the created user is still active
                u = mapUsers.get(new_opp.CreatedById);

                if (u.IsActive == true){
                    SLXOpportunity__Share oppShare = new SLXOpportunity__Share();
                    oppShare.UserOrGroupId = new_opp.CreatedById;
                    oppShare.ParentId = new_opp.Id;
                    oppShare.AccessLevel = 'Edit';
                    oppShares.add(oppShare);
                }
            }

            SLXOpportunity__c old_opp = Trigger.oldMap.get(new_opp.Id);                                 
            if(old_opp.Status__c != new_opp.Status__c) {
                String emailBody = '<p><a href=https://ap1.salesforce.com/' + old_opp.Id +'>'+ old_opp.Name +'</a> status changed from '+old_opp.Status__c+' to '+new_opp.Status__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                try{
                    User owner = mapUsers.get(new_opp.OwnerId);
                    Account[] acc = [select Email__c from Account where Id =: new_opp.Assign_To__c];

                    String ownerEmail = owner.Email;
                    String[] toAddresses   = new String[] { ownerEmail};
                    if(acc.size()>0 && acc[0].Email__c != null){
                        String salesEmail = acc[0].Email__c;
                        toAddresses.add(salesEmail);
                    }
                    mail.setToAddresses(toAddresses);
                    mail.setSenderDisplayName('Opportunity');
                    mail.setSubject('Opportunity Status Changing Notification');
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setHtmlBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }catch(Exception e){
                    String[] toAddresses   = new String[] { 'bill.zhang@sponsoredlinx.com' };
                    mail.setToAddresses(toAddresses);
                    mail.setSenderDisplayName('Opportunity');
                    mail.setSubject('Opportunity Status Change Error');
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setHtmlBody(emailBody + e.getMessage());
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }

            if(old_opp.OwnerId != new_opp.OwnerId) {
                if (new_opp.Adwords_Daily_Budget__c >= 10) {
                    Messaging.SingleEmailMessage mail;
                    try{
                        Account acc  = [select Id, Name, ownerId from Account where Id =: new_opp.Account__c limit 1];
                        
                        String emailBody = '<p>New <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + new_opp.Id +'>Opportunity</a> Details:';
                        if(acc != null) { emailBody += '<p>Account: '+acc.Name+'</p>';}
                        emailBody += '<p>Opportunity Name: '+new_opp.Name+'</p>';
                        emailBody += '<p>Type: '+new_opp.Opp_Type__c+'</p>';
                        emailBody += '<p>Product Type: '+new_opp.Product_Type__c+'</p>';
                        emailBody += '<p>Close Date: '+new_opp.Close_Date__c+'</p>';
                        emailBody += '<p>Status: '+new_opp.Status__c+'</p>';
                        emailBody += '<p>Importance: '+new_opp.importance__c+'</p>';
                        emailBody += '<p>Amount: '+new_opp.Amount__c+'</p>';
                        emailBody += '<p>Adwords Daily Budget: '+new_opp.Adwords_Daily_Budget__c+'</p>';
                        emailBody += '<p>Reason For Opportunity: '+new_opp.Reason_For_Opportunity__c+'</p>';
                        
                        User salesperson = mapUsers.get(new_opp.OwnerId);
                        String[] toAddresses = new String[] { salesperson.email};
                        User[] salesManagers = new List<User>();
                        if(acc.Name.contains('GetMoreTraffic')) {
                          //salesManagers = [select email from user where isActive = true and UserRole.name like '%Sales Manager Assistant GMT%'];
                        } else {
                          //salesManagers = [select email from user where isActive = true and name = 'Amber Porter'];
                        }
                        if(!salesManagers.isEmpty()) {
                            for(User u : salesManagers) {
                                toAddresses.add(u.email);
                            }
                        }
                        mail = new Messaging.SingleEmailMessage();
                        //toAddresses = new String[] {'bill.zhang@sponsoredlinx.com'};
                        mail.setToAddresses(toAddresses);
                        mail.setSenderDisplayName('Opportunity');
                        mail.setSubject('New Opportunity Notification');
                        mail.setHtmlBody(emailBody);
                        mail.setUseSignature(false);
                        mails.add(mail);
                        
                        AccountShare share = new AccountShare();
                        share.userorgroupid = new_opp.OwnerId;
                        share.accountid = acc.Id;
                        share.accountaccesslevel = 'Read';
                        share.OpportunityAccessLevel = 'None';
                        share.CaseAccessLevel = 'None';
                        shares.add(share);
                        
                    }catch(Exception e){
                        mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses   = new String[] { 'bill.zhang@sponsoredlinx.com' };
                        mail.setToAddresses(toAddresses);
                        mail.setSenderDisplayName('Opportunity');
                        mail.setSubject('New Opportunity Notification Error');
                        mail.setHtmlBody(e.getMessage());
                        mail.setUseSignature(false);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                } else {
                    new_opp.addError('Current budget must be $10+ to be sent to salesperson.');
                }
            }
        }
    } else if(Trigger.isAfter && Trigger.isInsert) {
        //insert new Opportunity
        User[] salesManagers = [select email from user where isActive = true and UserRole.name = 'Digital Strategy Manager'];
        Map<Id, User> salesMap = new Map<Id, User>([SELECT name, email, Id FROM User WHERE isActive = true AND UserRole.name LIKE '%Digital Strategy%']);

        for(SLXOpportunity__c new_opp : Trigger.new) {

            // Share the opp with the user who created it
            if (new_opp.CreatedById != new_opp.OwnerId){
                u = mapUsers.get(new_opp.CreatedById);

                if (u.IsActive == true){
                    SLXOpportunity__Share oppShare = new SLXOpportunity__Share();
                    oppShare.UserOrGroupId = new_opp.CreatedById;
                    oppShare.ParentId = new_opp.Id;
                    oppShare.AccessLevel = 'Edit';
                    oppShares.add(oppShare);
                }
            }
            
            if(new_opp.Send_to_Salesperson__c != null){
                if (new_opp.Adwords_Daily_Budget__c >= 10) {
                    Messaging.SingleEmailMessage mail;
                    try{
                        String emailBody = '<p>New <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + new_opp.Id +'>Opportunity</a> Details:';
                        emailBody += '<p>Opportunity Name: '+new_opp.Name+'</p>';
                        emailBody += '<p>Type: '+new_opp.Opp_Type__c+'</p>';
                        emailBody += '<p>Product Type: '+new_opp.Product_Type__c+'</p>';
                        emailBody += '<p>Close Date: '+new_opp.Close_Date__c+'</p>';
                        emailBody += '<p>Status: '+new_opp.Status__c+'</p>';
                        emailBody += '<p>Importance: '+new_opp.importance__c+'</p>';
                        emailBody += '<p>Amount: '+new_opp.Amount__c+'</p>';
                        emailBody += '<p>Adwords Daily Budget: '+new_opp.Adwords_Daily_Budget__c+'</p>';
                        emailBody += '<p>Reason For Opportunity: '+new_opp.Reason_For_Opportunity__c+'</p>';
                        
                        User salesperson = salesMap.get(new_opp.OwnerId);
                        String[] toAddresses = new String[] { salesperson.email};
                        
                        if(!salesManagers.isEmpty()) {
                            for(User u : salesManagers) {
                                toAddresses.add(u.email);
                            }
                        }

                        mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setSenderDisplayName('Opportunity');
                        mail.setSubject('New Opportunity Notification');
                        mail.setHtmlBody(emailBody);
                        mail.setUseSignature(false);
                        mails.add(mail);
                        
                        AccountShare share = new AccountShare();
                        share.userorgroupid = new_opp.OwnerId;
                        share.accountid = new_opp.Account__c;
                        share.accountaccesslevel = 'Read';
                        share.OpportunityAccessLevel = 'None';
                        share.CaseAccessLevel = 'None';
                        shares.add(share);
            
                    }catch(Exception e){

                        mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses   = new String[] { 'devteam@sponsoredlinx.com' };
                        mail.setToAddresses(toAddresses);
                        mail.setSenderDisplayName('Opportunity');
                        mail.setSubject('New Opportunity Notification Error');
                        mail.setHtmlBody(e.getMessage());
                        mail.setUseSignature(false);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                } else {
                    new_opp.addError('Current budget must be $10+ to be sent to salesperson.');
                }
            }
        }
    } else if(Trigger.isBefore && Trigger.isInsert) {
        BJBOpportunityHelper helper = new BJBOpportunityHelper();

        for(SLXOpportunity__c new_opp : Trigger.new) {
            // set AdwordId for LostInterest data update
            new_opp.Adwords_ID__c  = helper.getValidAdwordID(new_opp);
        }
    }

    Messaging.sendEmail(mails);
    insert(shares);
    insert(oppShares);
    
}