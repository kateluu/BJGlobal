public class CasesProcessor {
    private String RESOLUTION_NOTE_MSG = 'Because of no active Manager, Ben take over the case';

    /*
    public void calEscalatedNumberManualShare(List<Cases__c> myCases,Set<Id> updateCaseIds ){
        
        //List<Cases__c> myCases = Trigger.new;
            
        integer loopOld = 0;
        Cases__c oldItem;        
        Boolean isChanged = false;    
        List<Cases__Share> mySharings = new List<Cases__Share>();  
        List<AccountShare> myAccountSharings= new List<AccountShare>(); 
        Decimal currentEscalateNo = ForCaseManage__c.getValues('EscalateNo').CaseNumber__c;    
        Integer numOfResolutionManager = TriggerUtilities.getNumberOfResolutionManager();
    
        //List<Cases__c> myOldCases = [SELECT id, Account__r.Id, Account_Product__r.id FROM Cases__c WHERE Id in :Trigger.newMap.keySet()];
        List<Cases__c> myOldCases = [SELECT id, Account__r.Id, Account_Product__r.id FROM Cases__c WHERE Id in :updateCaseIds];
    
        for(Cases__c item : myCases) {
            if((item.Status__c == 'Escalated') && (item.EscalateNo__c == null)){            
                isChanged = true;            
                item.EscalateNo__c = math.mod(Integer.valueOf(currentEscalateNo++),numOfResolutionManager) + 1;            
                User resolutionMan = TriggerUtilities.getAvailableResultionManager(Integer.valueOf(item.EscalateNo__c));           
                item.Resolution_Manager__c = resolutionMan.id;
                
                Cases__Share mySharing = new Cases__Share();
                mySharing.ParentId = item.Id;
                mySharing.UserOrGroupId = resolutionMan.id; 
                mySharing.AccessLevel = 'Edit';
                mySharing.RowCause = Schema.Cases__Share.RowCause.Manual;
                mySharings.add(mySharing);
                
                oldItem = myOldCases.get(loopOld);
                AccountShare myAccountSharing = new AccountShare();
                myAccountSharing.AccountId = oldItem.Account__r.Id;
                myAccountSharing.UserOrGroupId  = resolutionMan.id; 
                myAccountSharing.AccountAccessLevel = 'Read';
                myAccountSharing.ContactAccessLevel = 'Read';
                myAccountSharing.CaseAccessLevel = 'Read';
                myAccountSharing.OpportunityAccessLevel= 'Read';
                myAccountSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                myAccountSharings.add(myAccountSharing);            
    
                //System.debug('UpdateCaseToEscalatedStatus :: EscalateNo__c =' + item.EscalateNo__c + ' numOfResolutionManager=' + numOfResolutionManager);
            }           
        }
        
        
        if(isChanged){
            try{
                // update custom setting to get ready for next case counter
                List<ForCaseManage__c> currentNumber = [SELECT id, Name, CaseNumber__c FROM ForCaseManage__c];
                currentNumber[0].CaseNumber__c = currentEscalateNo;
                update currentNumber;
                
                // update case object sharing
                List<Database.SaveResult> results = Database.insert(mySharings,false);
                
                //update account object sharing        
                List<Database.SaveResult> accountResults = Database.insert(myAccountSharings);
                
                for(Database.SaveResult item:results){
                      if(!item.isSuccess()){
                         // Get first save result error.
                         Database.Error err = item.getErrors()[0];
                         System.debug('CasesProcessor Error' + err.getMessage());
                      }
                }
                
                for(Database.SaveResult item:results){
                      if(!item.isSuccess()){
                         // Get first save result error.
                         Database.Error err = item.getErrors()[0];
                         System.debug('CasesProcessor Error' + err.getMessage());
                      }
                }
                
            }catch(DMLException ex){
                System.debug('CasesProcessor:: DMLException occured' + ex.getMessage());
            }        
        }
    }
    */
        
    public void assignEscalatedCase(List<Cases__c> myCases,Set<Id> updateCaseIds ){    
        integer loopOld = 0;
        Cases__c oldItem;        
        Boolean isChanged = false;    
        List<Cases__Share> mySharings = new List<Cases__Share>();  
        List<AccountShare> myAccountSharings= new List<AccountShare>(); 

        
        List<Cases__c> myOldCases = [SELECT id, Account__r.Id, Account_Product__r.id, OwnerId,Account_Resolution__c , Case_Reason__c FROM Cases__c WHERE Id in :updateCaseIds];

        // get new owner 
        List<id> newOwnerIDs = new List<id>();
        for(Cases__c item: myCases){
            newOwnerIDs.add(item.OwnerId);
        }

        // get cases owner manager
        Map<Id,User> newOwners = new Map<Id, User>([SELECT id, ManagerId FROM User WHERE isActive = true AND Id in :newOwnerIDs]);
       
        //get default resolution manager 
        User defaultManager = [SELECT id FROM USER WHERE Name = 'Ben Bradshaw' AND IsActive = true];

        //Map<id, id> newOwnerMans = new Map<id,id>();
        //for(User item: newOwners){
        //    newOwnerMans.put(item.id, item.ManagerId);
        //}

        for(Cases__c item : myCases) {
            if((item.Status__c == 'Escalated') &&  ((item.Product_Type__c == 'Social Marketing') || (item.Product_Type__c == 'AdWords Management')) 
                && (item.CaseType__c == 'Cancellation') &&  ( (item.Account_Resolution__c!= null && item.Account_Resolution__c.equals('Save')) || (item.Case_Reason__c!=null && item.Case_Reason__c.containsIgnoreCase('BTS'))) ){ 
                
                isChanged = true;                
                // update Resolution Manager
                item.Resolution_Manager__c = newOwners.get(item.OwnerId).ManagerId;
                if (item.Resolution_Manager__c  == null){
                    item.Resolution_Manager__c = defaultManager.Id;
                }                
                System.debug('item.Resolution_Manager__c = ' + item.Resolution_Manager__c);

                //update case access                
                Cases__Share mySharing = new Cases__Share();
                mySharing.ParentId = item.Id;
                mySharing.UserOrGroupId = item.Resolution_Manager__c; 
                mySharing.AccessLevel = 'Edit';
                mySharing.RowCause = Schema.Cases__Share.RowCause.Manual;
                mySharings.add(mySharing);
                
                //update account access
                oldItem = myOldCases.get(loopOld++);
                AccountShare myAccountSharing = new AccountShare();
                myAccountSharing.AccountId = oldItem.Account__r.Id;
                myAccountSharing.UserOrGroupId  = item.Resolution_Manager__c; 
                myAccountSharing.AccountAccessLevel = 'Read';
                myAccountSharing.ContactAccessLevel = 'Read';
                myAccountSharing.CaseAccessLevel = 'Read';
                myAccountSharing.OpportunityAccessLevel= 'Read';
                myAccountSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                myAccountSharings.add(myAccountSharing);           
                

            }else if((item.Status__c == 'Escalated') && (item.Resolution_Manager__c == null) && ((item.Product_Type__c == 'Social Marketing') || (item.Product_Type__c == 'AdWords Management')) 
                && (item.CaseType__c == 'Cancellation')){            
                isChanged = true;            
                User resolutionMan = TriggerUtilities.getAvailableResolutionManagerByCap();

                // update Resolution Manager
                if( resolutionMan == null){                    
                    resolutionMan= defaultManager;                 
                }                
                item.Resolution_Manager__c = resolutionMan.id;
                System.debug('item.Resolution_Manager__c = ' + item.Resolution_Manager__c);

                Cases__Share mySharing = new Cases__Share();
                mySharing.ParentId = item.Id;
                mySharing.UserOrGroupId = resolutionMan.id; 
                mySharing.AccessLevel = 'Edit';
                mySharing.RowCause = Schema.Cases__Share.RowCause.Manual;
                mySharings.add(mySharing);
                
                oldItem = myOldCases.get(loopOld++);
                AccountShare myAccountSharing = new AccountShare();
                myAccountSharing.AccountId = oldItem.Account__r.Id;
                myAccountSharing.UserOrGroupId  = resolutionMan.id; 
                myAccountSharing.AccountAccessLevel = 'Read';
                myAccountSharing.ContactAccessLevel = 'Read';
                myAccountSharing.CaseAccessLevel = 'Read';
                myAccountSharing.OpportunityAccessLevel= 'Read';
                myAccountSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                myAccountSharings.add(myAccountSharing);           
                
                //System.debug('UpdateCaseToEscalatedStatus :: EscalateNo__c =' + item.EscalateNo__c + ' numOfResolutionManager=' + numOfResolutionManager);
            }           
        }
        
        
        if(isChanged){
            try{
                // update case object sharing
                List<Database.SaveResult> results = Database.insert(mySharings,false);
                
                //update account object sharing        
                List<Database.SaveResult> accountResults = Database.insert(myAccountSharings);
                
                for(Database.SaveResult item:results){
                    if(!item.isSuccess()){
                        // Get first save result error.
                        Database.Error err = item.getErrors()[0];
                        System.debug('UpdateCaseToEscalatedStatus Error' + err.getMessage());
                    }
                }
                
                for(Database.SaveResult item:accountResults){
                    if(!item.isSuccess()){
                        // Get first save result error.
                        Database.Error err = item.getErrors()[0];
                        System.debug('UpdateCaseToEscalatedStatus Error' + err.getMessage());
                    }
                }
                
            }catch(DMLException ex){
                System.debug('UpdateCaseToEscalatedStatus:: DMLException occured' + ex.getMessage());
            }      
        }    
    }    
}