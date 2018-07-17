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
        this.obj = new Web_Content__c();
        step = '1';
    }

    public PageReference save() {
        String msg ='';

        try{
            String accountId =ApexPages.currentPage().getParameters().get('accId');
            String projectId =ApexPages.currentPage().getParameters().get('projectId');

            //validate params
            if((accountId== null) ||(projectId==null)){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,MSG_ACCOUN_IS_BLANK));
                return null;
            }

            //validate input values
            if(isInputInvalid()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,MSG_INPUT_VALUES_IS_INVALID));
                return null;                
            }


            // update Project questionnaire status
            SFDC_Projects__c project = [SELECT Id, Web_Questionnaire__c , Email__c FROM SFDC_Projects__c WHERE Id = :projectId];
            project.Web_Questionnaire__c = 'Completed';
            update project;


            // create new Questionnaire            
            this.obj.Project__c = projectId;
            this.obj.Account__c = accountId;
            this.obj.Email__c = project.Email__c;
            insert this.obj;
            step = '2';

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