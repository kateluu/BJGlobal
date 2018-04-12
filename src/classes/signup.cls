global class signup {
    WebService static void changeSignupOwner(Id signupID, Id userID) {
        Sign_Up__c signupRec = [SELECT Id,Account__c FROM Sign_Up__c WHERE Id =:signupID];
        Account signupAcc = [SELECT Id FROM Account WHERE Id=:signupRec.Account__c];
        signupRec.OwnerId = userID;
        signupAcc.OwnerId = userID;
        update signupRec;
        update signupAcc;   
        List<Account_Product__c> accountproducts = [SELECT Id FROM Account_Product__c WHERE Sign_Up_del__c =: signupID];
        for (Account_Product__c accprod : accountproducts) {
            accprod.OwnerId = userID;                   
        }
        update accountproducts;
    }

    WebService static void changeSEOSignupOwner(Id signupID, Id userID) {
        Sign_Up__c signupRec = [SELECT Id, Account__c FROM Sign_Up__c WHERE Id =:signupID];
        Account signupAcc = [SELECT Id, OwnerID FROM Account WHERE Id=:signupRec.Account__c];
        signupRec.OwnerId = userID;
        
        update signupRec;
         
        List<Account_Product__c> accountproducts = [SELECT Id FROM Account_Product__c WHERE Sign_Up_del__c =: signupID];
        for (Account_Product__c accprod : accountproducts) {
            accprod.OwnerId = userID;                   
        }
        List<Account_Product__c> aps = [SELECT Id FROM Account_Product__c WHERE Account__c =: signupAcc.Id];
        if (aps.size() <=2){
          signupAcc.OwnerId = userID;
          update signupAcc;  
        } else {
            if(signupAcc.OwnerID != userID){
                AccountShare share = new AccountShare();
                share.userorgroupid = userID;
                share.accountid = signupAcc.Id;
                share.accountaccesslevel = 'Read';
                share.OpportunityAccessLevel = 'None';
                share.CaseAccessLevel = 'None';
                upsert share;
            }
        }
        update accountproducts;
        
        // SEO Project
        List<SFDC_Projects__c> seoprojects = [SELECT Id FROM SFDC_Projects__c WHERE Sign_Up__c =: signupID];
        for (SFDC_Projects__c seoproject : seoprojects) {
            seoproject.OwnerId = userID;                   
        }
        update seoprojects;
    }


    public static testMethod void signupTest() {
        Test.startTest();
        
        Account newAcc = new Account(name='yogi bear acc');
        insert newAcc;
        
        Sign_Up__c signupacc = new Sign_Up__c(name='yogi bear');
        signupacc.Account__c = newAcc.Id;
        signupacc.Is_Test__c = true;
        insert signupacc;
        
        Account_Product__c accprod = new Account_Product__c();
        accprod.Name = 'Test Product';
        accprod.Account__c = newAcc.Id;
        accprod.Sign_Up_del__c = signupacc.Id;
        accprod.Product_Price__c = 33.45;
        accprod.Description__c = 'test decription';
        
        User useracc = [SELECT Id FROM User WHERE Name='Ben Bradshaw' AND IsActive = true][0];
        
        signup.changeSignupOwner(signupacc.id,useracc.id);
        Test.stopTest();
    }
}