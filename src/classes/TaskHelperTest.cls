@isTest
private class TaskHelperTest {
	
	 @testSetup static void setup(){

		// Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{               
                //create account
                Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD');            
                testAccts.add(itemAcc);
                itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='USD');            
                testAccts.add(itemAcc);        
                insert testAccts; 
                
                List<Contact> contacts= new List<Contact>();
                for(Integer i =0; i< testAccts.size(); i++){
                    Account item = testAccts.get(i);
                    Contact con = new Contact (AccountId = item.id,LastName = 'test contact', Title ='Billing'); 
                    contacts.add(con);
                }
                insert contacts;
                
                //create user with Resolution Manager Profiles
                Profile p = [select Id, name from Profile where Name = 'Resolution Manager' limit 1];        
                List<User> users = new List<User>();
                for(Integer i =0; i< testAccts.size(); i++){
                    User newUser = new User(profileId = p.id,
                                            username = 'myTestUser'+i+'@yahoo.com',
                                            email = 'testUser1@ff.com',
                                            emailencodingkey = 'UTF-8',
                                            localesidkey = 'en_US',
                                            languagelocalekey = 'en_US',
                                            timezonesidkey = 'America/Los_Angeles',
                                            alias='nuser',
                                            lastname='testuser_lastname' + i,
                                            IsActive = true
                                            );
                    users.add(newUser);
                }
                insert users;
                
                List<VoiceMail__c> calles = new List<VoiceMail__c>(); 
				VoiceMail__c voicemail = new VoiceMail__c(Status__c='New',  Account__c = testAccts[0].id, Contact__c = contacts[0].id);
				calles.add(voicemail);
				voicemail = new VoiceMail__c(Status__c='New', Account__c = testAccts[1].id, Contact__c = contacts[1].id);
				calles.add(voicemail);
				insert(calles);
                
                //create tasks
                List<Task> tasks = new List<Task>();                
                Task newTask1 = new Task(Subject='Outbound call to ' , CurrencyIsoCode='AUD' , Status = 'Completed', Priority='Normal', WhatId = calles[0].id, CallDurationInSeconds  =58,CallType='Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(),NVMContactWorld__CW_Call_Start_Time__c =system.now());
                tasks.add(newTask1);
                Task newTask2 = new Task(Subject='Outbound call to ' , CurrencyIsoCode='AUD' , Status = 'Completed', Priority='Normal', WhatId = calles[1].id, CallDurationInSeconds  =58,CallType='Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(),NVMContactWorld__CW_Call_Start_Time__c =system.now());
				tasks.add(newTask2);
				insert tasks;

         }catch(DMLException e){
            system.debug('retry, exception : ' + e.getMessage());
            system.debug('Exception type caught: ' + e.getTypeName());    
		    system.debug('Message: ' + e.getMessage());    
		    system.debug('Cause: ' + e.getCause());    // returns null
		    system.debug('Line number: ' + e.getLineNumber());    
		    system.debug('Stack trace: ' + e.getStackTraceString());   
        }	 
    }


	@isTest static void test_setupContact() {
		TaskHelper helper = new TaskHelper();
		List<Task> tasks = [SELECT id, Whatid, Subject, Status, WhoId, CallType FROM Task ];
		helper.setupContactToReurnCallTasks(tasks);
		for(task item: tasks){
			System.assertNotEquals(null,item.WhoId);
		}
	}
	
}