@isTest(SeeAllData=true)
global class GMTGOWebservice_TEST {

    // ***********************************
    // ** TEST Methods for Webservices  **
    // ***********************************

    static testMethod void test_user_authenticate() {
        //GMTGOWebservice.WebServiceAuthenticate response = new GMTGOWebservice.user_authenticate('test@test.com','testpassword');
    }
    static testMethod void test_forget_password() {
        
    }
    static testMethod void test_update_password() {
        
    }
    
    public static testMethod void testRunAs() {
      // Setup test data
      // This code runs as the system user
     Profile p = [SELECT Id FROM Profile WHERE Name='GMTGO Profile'];
	 User u = [select Id from User where Profile.Id =:p.ID limit 1][0];

      System.runAs(u) {
         // The following code runs as user 'u' 
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId()); 
         //GMTGOWebservice.dashboard('0016F00001pqWgpQAE','7090184323','2017-04-04','2017-04-10');
         Sign_Up__c[] signups = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Account__c ='0016F00001pqWgpQAE' and Product_Type__c = 'AdWords Management' order by CreatedDate DESC];
         system.debug(signups);
         
         signups = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Product_Type__c = 'AdWords Management' order by CreatedDate DESC limit 2];
         system.debug(signups);
         
         signups = [SELECT Status__c,CreatedDate FROM Sign_Up__c order by CreatedDate DESC limit 2];
         system.debug(signups);
      }
      
      Sign_Up__c[] signups = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Account__c ='0016F00001pqWgpQAE' and Product_Type__c = 'AdWords Management' order by CreatedDate DESC];
      system.debug(signups);
   }
}