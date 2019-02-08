trigger SignUpAssignTo on Sign_Up__c (after update) {
  for(Sign_Up__c newSignUp : Trigger.new) {
    Sign_Up__c oldSignUp = Trigger.oldMap.get(newSignUp.Id);
    if(newSignUp.Assign_To_User__c!= null && oldSignUp.Assign_To_User__c != newSignUp.Assign_To_User__c){
      if(newSignUp.Product_Type__c == 'Adwords Management'){
        signup.changeSignupOwner(newSignUp.Id, newSignUp.Assign_To_User__c);
      }else if(newSignUp.Product_Type__c == 'SEO' || newSignUp.Product_Type__c == 'Social Marketing'|| newSignUp.Product_Type__c == 'Social Engage'){
        // transfer sign up, account products and projects to the new SEO CM
        //newSignUp.OwnerId = newSignUp.Assign_To_User__c;
        // Account prodcts
        //List<Account_Product__c> accountproducts = [SELECT Id FROM Account_Product__c WHERE Sign_Up_del__c =: newSignUp.Id];
            //for (Account_Product__c accprod : accountproducts) {
            //    accprod.OwnerId = newSignUp.Assign_To_User__c;                   
            //}
            //update accountproducts;
            // SEO Project
            //List<SFDC_Projects__c> seoprojects = [SELECT Id FROM SFDC_Projects__c WHERE Sign_Up__c =: newSignUp.Id];
            //for (SFDC_Projects__c seoproject : seoprojects) {
            //    seoproject.OwnerId = newSignUp.Assign_To_User__c;                   
           // }
            //update seoprojects;
            signup.changeSEOSignupOwner(newSignUp.Id, newSignUp.Assign_To_User__c);
      }
      
    }
    
  }

}