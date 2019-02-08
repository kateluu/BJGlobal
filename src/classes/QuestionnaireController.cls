public with sharing class QuestionnaireController {

	public Web_Content__c obj{get;set;}
    public String step{get;set;}
    public boolean isTest{get;set;}
    public final String MSG_ACCOUN_IS_BLANK = 'Client/Project ID is required';
    public final String MSG_INPUT_VALUES_IS_INVALID = 'Input value is invalid';

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public QuestionnaireController() {
        System.debug('dsdsdsadasdas 0');
        this.obj = new Web_Content__c();
        step = '1';
        System.debug('dsdsdsadasdas 00');
    }

    public PageReference save() {
        String msg ='';

        try{
            String accountId =ApexPages.currentPage().getParameters().get('accId');
            String signupId =ApexPages.currentPage().getParameters().get('projectId'); // signup
            System.debug('accountId' + accountId);
            System.debug('signupId' + signupId);
            //validate params
            
            if(accountId== null){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,MSG_ACCOUN_IS_BLANK));
                return null;
            }

            //validate input values            
            //if(isInputInvalid()){
            //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,MSG_INPUT_VALUES_IS_INVALID));
            //    return null;                
            //}


            // update Project questionnaire status
            String projectId ='';
            Sign_Up__c signup = [SELECT Id, Web_Questionnaire__c , Email__c, Account__c,Account__r.Name,Account__r.Email__c, (SELECT Id FROM Projects__r) 
                     FROM Sign_Up__c 
                     WHERE Id =:signupId];
            
            /*
            // get project ID, if not exist (for any SEO Content Pack signup created before 30/8/2018), then create the project base on sign up information
            if (signup.Projects__r!=null){
                for (SFDC_Projects__c item: signup.Projects__r){
                    if((item.Name!= null) && (item.Name.containsIgnoreCase('Content Pack'))){
                        projectId = ''+ item.id;
                    }
                }
                system.debug('QuestionnaireController: 1 : ' + projectId);

            } 

            if((projectId == null) || (projectId == '')){
                system.debug('QuestionnaireController: 2 : ' + projectId);
                SFDC_Projects__c newProject = new SFDC_Projects__c();
                newProject.name = signup.Account__r.Name + ' Content Pack';
                newProject.Account__c = signup.Account__c;                    
                newProject.Project_Type__c ='SEO Content Pack';
                newProject.Sign_Up__c = signup.Id;
                newProject.Sold_by__c = 'unknown';
                newProject.Email__c = signup.Account__r.Email__c; 
                insert newProject;  
                projectId = newProject.id;             
                system.debug('QuestionnaireController: 2 : ' + projectId);
            }

            */
            signup.Web_Questionnaire__c = 'Completed';
            update signup;
            system.debug('QuestionnaireController: 3 : ' + signup.Id);         


            // create new Questionnaire            
            this.obj.Sign_Up__c = signupId;            
           // this.obj.Project__c = projectId;
            this.obj.Email__c   = signup.Email__c;
            //this.obj.Account__c = signup.Account__c;
            //this.obj.Account_Product__c = productId;            
            insert this.obj;
            system.debug('QuestionnaireController: 4 : ');         

            //move to confirm page
            step = '2';
            System.debug('insert');

            return null;
        }catch(Exception ex) {
            system.debug('QuestionnaireController: ' + ex.getMessage() );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }        
    }


    public boolean isInputInvalid(){
        return false;
    }

}