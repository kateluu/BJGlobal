/**
 * Created by Kate on 12/02/2018.
 */
@isTest
public class ActivityHelperTest {
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{
            //create account
            Account itemAcc = new Account(Name = 'TestAccount1', username__c = 'TestAccount1', password__c = 'TestAccount1', CurrencyIsoCode = 'AUD',Num_of_Escalated_Case__c =10, phone='1300859600');
            testAccts.add(itemAcc);
            itemAcc = new Account(Name = 'TestAccount2', username__c = 'TestAccount2', password__c = 'TestAccount2', CurrencyIsoCode = 'USD',Num_of_Escalated_Case__c =10, phone='1300859600');
            testAccts.add(itemAcc);
            insert testAccts;

            // create account products
            List<Account_Product__c> testProducts = new List<Account_Product__c>();
            for (Integer i = 0; i < 2; i++) {
                Account_Product__c item = new Account_Product__c(Name = 'Social' + 1, Product_Price__c = 1000, CurrencyIsoCode = 'AUD', Account__c = testAccts.get(0).id);
                testProducts.add(item);
            }
            insert testProducts;

            List<Contact> contacts = new List<Contact>();
            for (Integer i = 0; i < testAccts.size(); i++) {
                Account item = testAccts.get(i);
                Contact con = new Contact(AccountId = item.id, LastName = 'test contact', Title='Billing');
                contacts.add(con);
            }
            insert contacts;

            //create user with Resolution Manager Profiles
            Profile p = [select Id, name from Profile where Name = 'Resolution Manager' limit 1];
            List<User> users = new List<User>();
            for (Integer i = 0; i < testAccts.size(); i++) {
                User newUser = new User(profileId = p.id,
                        username = 'myTestUser' + i + '@yahoo.com',
                        email = 'testUser1@ff.com',
                        emailencodingkey = 'UTF-8',
                        localesidkey = 'en_US',
                        languagelocalekey = 'en_US',
                        timezonesidkey = 'America/Los_Angeles',
                        alias = 'nuser',
                        lastname = 'testuser_lastname' + i,
                        IsActive = true
                );
                users.add(newUser);
            }
            insert users;

            // create cases
            List<Cases__c> cases = new List<Cases__c>();
            Cases__c obj = new Cases__c(CaseType__c='Domain Issue', X2012_Action_Taken_to_Save__c = 'check1', Account__c = testAccts[0].id, Daily_Budget__c = 7000, CurrencyIsoCode = 'AUD', Account_Product__c = testProducts[0].id, Status__c ='New');
            cases.add(obj);
            //obj = new Cases__c(CaseType__c='Domain Issue', X2012_Action_Taken_to_Save__c = 'check2', Account__c = testAccts[0].id, Daily_Budget__c = 7000, CurrencyIsoCode = 'AUD', Account_Product__c = testProducts[1].id, Status__c ='New');
            //cases.add(obj);
            insert cases;

            //create tasks
            List<Task> tasks = new List<Task>();
            Task newTask1 = new Task(Subject = 'Call: call client in 2 hours to sign the signup', CurrencyIsoCode = 'AUD', Status = 'Completed', Priority = 'Normal', WhatId = cases[0].id, CallDurationInSeconds = 58, CallType = 'Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(), NVMContactWorld__CW_Call_Start_Time__c = system.now());
            tasks.add(newTask1);
            newTask1 = new Task(Subject = 'Email: contact client to clarify the issue ', CurrencyIsoCode = 'AUD', Status = 'Completed', Priority = 'Normal', WhatId = cases[0].id, CallDurationInSeconds = 58, CallType = 'Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(), NVMContactWorld__CW_Call_Start_Time__c = system.now());
            tasks.add(newTask1);
            //Task newTask2 = new Task(Subject = 'Email: contact client to clarify the issue ', CurrencyIsoCode = 'AUD', Status = 'Completed', Priority = 'Normal', WhatId = cases[1].id, CallDurationInSeconds = 58, CallType = 'Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(), NVMContactWorld__CW_Call_Start_Time__c = system.now());
            //tasks.add(newTask2);
            insert tasks;

        }catch(Exception e){
            system.debug('ActivityHelperTest : retry, exception : ' + e.getMessage());
            system.debug('Exception type caught: ' + e.getTypeName());
            system.debug('Message: ' + e.getMessage());
            system.debug('Cause: ' + e.getCause());    // returns null
            system.debug('Line number: ' + e.getLineNumber());
            system.debug('Stack trace: ' + e.getStackTraceString());
        }

    }

    @isTest static void testUpdateCasesHistoryActivityCount() {
        List<Task> tasks = [SELECT ID, whatid, whoid, subject, status FROM Task];

        ActivityHelper act = new ActivityHelper((sObject[]) tasks);
        act.updateCasesHistoryActivityCount();
        List<Cases__c> cases =[SELECT id, Num_Of_Emails__c, Num_Of_Calls__c, X2012_Action_Taken_to_Save__c FROM Cases__c ];
        for(Cases__c item: cases){
            if(item.X2012_Action_Taken_to_Save__c =='check1'){
                System.assertEquals(1,item.Num_Of_Emails__c );
                System.assertEquals(1,item.Num_Of_Calls__c );
            }
        }
    }
}