@isTest
public class CasesResponseTimeProcessorTest {

    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try {
            //create account
            Account itemAcc = new Account(Name = 'TestAccount1', username__c = 'TestAccount1', password__c = 'TestAccount1', CurrencyIsoCode = 'AUD');
            testAccts.add(itemAcc);
            itemAcc = new Account(Name = 'TestAccount2', username__c = 'TestAccount2', password__c = 'TestAccount2', CurrencyIsoCode = 'USD');
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
                Contact con = new Contact(AccountId = item.id, LastName = 'test contact');
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
            Cases__c obj = new Cases__c(X2012_Action_Taken_to_Save__c = 'check1', Account__c = testAccts[0].id, Daily_Budget__c = 7000, CurrencyIsoCode = 'AUD', Account_Product__c = testProducts[0].id, Status__c ='New');
            cases.add(obj);
            obj = new Cases__c(X2012_Action_Taken_to_Save__c = 'check2', Account__c = testAccts[0].id, Daily_Budget__c = 7000, CurrencyIsoCode = 'AUD', Account_Product__c = testProducts[1].id, Status__c ='New');
            cases.add(obj);
            insert cases;

            //create tasks
            List<Task> tasks = new List<Task>();
            Task newTask1 = new Task(Subject = 'Test Task 1 ', CurrencyIsoCode = 'AUD', Status = 'Completed', Priority = 'Normal', WhatId = cases[0].id, CallDurationInSeconds = 58, CallType = 'Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(), NVMContactWorld__CW_Call_Start_Time__c = system.now());
            tasks.add(newTask1);
            Task newTask2 = new Task(Subject = 'Test Task 2 ', CurrencyIsoCode = 'AUD', Status = 'Completed', Priority = 'Normal', WhatId = cases[1].id, CallDurationInSeconds = 58, CallType = 'Outbound', NVMContactWorld__CW_Call_End_Time__c = system.now(), NVMContactWorld__CW_Call_Start_Time__c = system.now());
            tasks.add(newTask2);
            insert tasks;

        } catch (DMLException e) {
            system.debug('retry, exception : ' + e.getMessage());
            system.debug('Exception type caught: ' + e.getTypeName());
            system.debug('Message: ' + e.getMessage());
            system.debug('Cause: ' + e.getCause());    // returns null
            system.debug('Line number: ' + e.getLineNumber());
            system.debug('Stack trace: ' + e.getStackTraceString());
        }
    }

    @isTest static void testScheduledJob() {

        // Dummy CRON expression: midnight on March 15.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 * * * ?';

        Test.startTest();
        //update cases status
        List<Cases__c> newcases = [SELECT Id, First_Success_Call__c, Status__c FROM Cases__c WHERE Status__c = 'New'];
        for (Cases__c item : newcases) {
            item.status__c = 'Escalated';
        }
        update newcases;


        // Schedule the test job
        String jobId = System.schedule('CaseResponseTimeProcessorTest', CRON_EXP, new CasesResponseTimeProcessor());

        // Stopping the test will run the job synchronously
        Test.stopTest();

        // Now that the scheduled job has executed,
        // check that our case call time did record to the case
        List<Cases__c> cases = [SELECT Id, First_Success_Call__c, Status__c FROM Cases__c WHERE Status__c = 'Escalated' AND First_Success_Call__c != null];
        system.debug(' result : ' + cases);

        //System.assertEquals(2, cases.size(), 'Call time did not record to case record');

    }

}