@isTest
public class CasesProcessorTest {
    @testSetup static void setup(){
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        try{               
                Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213');
                testAccts.add(itemAcc);
                itemAcc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='78456213');
                testAccts.add(itemAcc);        
                insert testAccts; 
                
                // create account products
                List<Account_Product__c> testProducts = new List<Account_Product__c>();
                for(Integer i=0;i<2;i++) {            
                    Account_Product__c item = new Account_Product__c(Name ='Social'+1, Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c =testAccts.get(0).id );
                    testProducts.add(item);
                }
                insert testProducts; 
                
                List<Contact> contacts= new List<Contact>();
                for(Integer i =0; i< testAccts.size(); i++){
                    Account item = testAccts.get(i);
                    Contact con = new Contact (AccountId = item.id,LastName = 'test contact'); 
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
                                            IsActive = true);
                    users.add(newUser);
                }
                insert users;

                users[0].ManagerId = users[1].Id;
                users[1].ManagerId = UserInfo.getUserId();
                update users;
                                
                // create cases with status=new  
                System.runAs(users[0]){
                    List<Cases__c> cases = new List<Cases__c>();
                    Cases__c obj = new Cases__c(X2012_Action_Taken_to_Save__c='check1',Account__c=testAccts[0].id, Daily_Budget__c=7000, CurrencyIsoCode='AUD', Account_Product__c = testProducts[0].id , Status__c ='New', Account_Resolution__c = 'Save', Case_Reason__c = 'BTS: Act of God');
                    cases.add(obj);
                    obj = new Cases__c(X2012_Action_Taken_to_Save__c='check2',Account__c=testAccts[0].id, Daily_Budget__c=7000, CurrencyIsoCode='AUD', Account_Product__c = testProducts[0].id , Status__c ='New', Account_Resolution__c = 'Pause');
                    cases.add(obj); 
                    insert cases;   
                }
         }catch(DMLException e){
            system.debug('retry' + e.getMessage());
        }
    }
    
    @isTest static void testEscalateCase(){                
        List<Cases__c> testCase = [SELECT Account__c,Account_Product__c, Product_Type__c, Resolution_Manager__c, Daily_Budget__c, Status__c FROM Cases__c WHERE Status__c <> 'Escalated'  ];
        for(Cases__c item: testCase){
            item.Status__c = 'Escalated';
            
        }
        update testCase;
        Cases__c realCase = [SELECT Account__c,Account_Product__c, Resolution_Manager__r.lastname, Daily_Budget__c, Status__c FROM Cases__c WHERE Status__c = 'Escalated' AND Account_Resolution__c = 'Save' LIMIT 1];
        System.assertNotEquals(null, realCase.Resolution_Manager__c);        
        realCase = [SELECT Account__c,Account_Product__c, Resolution_Manager__r.lastname, Daily_Budget__c, Status__c FROM Cases__c WHERE  Status__c = 'Escalated' AND Account_Resolution__c <> 'Save' LIMIT 1];
        System.assertNotEquals(null, realCase.Resolution_Manager__c);        
    }
}