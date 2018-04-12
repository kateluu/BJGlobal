/**
 * Created by Kate on 8/02/2018.
 */
public class ActivityHelper {
    //config
    String fieldToUpdateEmail = 'Num_Of_Emails__c';
    String fieldToUpdateCall = 'Num_Of_Calls__c';


    //state
    set<id> CasesIds;

    public ActivityHelper(List<Task> records) {
        CasesIds = new set<id>();
        captureWhatAndWhoIds(records);
        //addAccountIdsFromRlatedObjects();
    }

    public void updateCasesHistoryActivityCount() {
        try {
            if (CasesIds.size() == 0) return;
            updateHistoryEmailCallActivityCount(getStringFromIdSet(CasesIds));
        }catch(Exception e) {
            system.debug('ActivityHelper : retry, exception : ' + e.getMessage());
            system.debug('Exception type caught: ' + e.getTypeName());
            system.debug('Message: ' + e.getMessage());
            system.debug('Cause: ' + e.getCause());    // returns null
            system.debug('Line number: ' + e.getLineNumber());
            system.debug('Stack trace: ' + e.getStackTraceString());
        }

    }

    private void updateHistoryEmailCallActivityCount( String updateIds) {
        string strQuery = 'SELECT Id,Num_Of_Emails__c , Num_Of_Calls__c, (SELECT Id , Subject, ActivityType FROM ActivityHistories WHERE Subject LIKE \'%email%\' OR Subject LIKE \'%call%\' OR ActivityType=\'Email\' OR ActivityType =\'Call\') FROM Cases__c WHERE Id IN (' + updateIds + ')';
        List<Cases__c> newCases = new list<Cases__c>();
        integer numOfEmail = 0;
        integer numOfCall = 0;
        List<Cases__c> cases = database.query(strQuery);
        for(Cases__c caseItem : cases) {
            ActivityHistory[] oActivities = caseItem.getSObjects('ActivityHistories');
            numOfEmail = 0;
            numOfCall = 0;
            if((null != oActivities) &&(oActivities.size()>0)){
                for (ActivityHistory item : oActivities) {
                    if (((item.subject!= null) && (item.subject.containsIgnoreCase('email'))) || ((item.ActivityType!= null) && (item.ActivityType.equalsIgnoreCase('Email'))) ) {
                        numOfEmail++;
                    } else if ( ((item.subject!= null) && (item.subject.containsIgnoreCase('call'))) || ((item.ActivityType!= null) && (item.ActivityType.equalsIgnoreCase('Call')))) {
                        numOfCall++;
                    }
                }
                //Integer openActivityCount = oActivities == null ? 0 : oActivities.size();
                //sObject obj = createObject('Cases__c', so.Id);
                caseItem.Num_Of_Emails__c =  numOfEmail;
                caseItem.Num_Of_Calls__c =  numOfCall;
                newCases.add(caseItem);
                system.debug('historyEmailCount: ' + numOfEmail);
                system.debug('historyCallCount: ' + numOfCall);
            }
        }

        if (newCases.size()>0){
            update newCases;
        }

    }

//    public void updateHistoryEmailCallActivityCount2( String updateIds) {
//        String strQuery = 'SELECT Id , Subject, TaskSubtype FROM Task WHERE (Subject LIKE \'%email%\' OR Subject LIKE \'%call%\' OR TaskSubtype=\'Email\' OR TaskSubtype =\'Call\') AND Status =\'Completed\' AND WhatId IN ( ' + updatedIds +' ) ORDER BY WhatId' ;
//        List<Task> tasks  = database.query(strQuery);
//        strQuery = 'SELECT Id,Num_Of_Emails__c , Num_Of_Calls__c FROM Cases__c WHERE id IN ( '+ updateIDs +')';
//        List<Cases__c> cases =  database.query(strQuery);
//
//        // need to build the map of case
//        integer numOfEmail = 0;
//        integer numOfCall = 0;
//        String caseIDString ='';
//        for (tasks item : tasks) {
//            if (caseIDString.isNotBlank() && !caseIDString.equals(item.id)) {
//                caseIDString =  item.id + '';
//            }
//
//            if ((item.subject.containsIgnoreCase('email')) || (item.TaskSubtype.equalsIgnoreCase('Email'))) {
//                numOfEmail++;
//            } else if ((item.subject.containsIgnoreCase('call')) || (item.TaskSubtype.equalsIgnoreCase('Call'))) {
//                numOfCall++;
//            }
//
//        }
//    }

    private void captureWhatAndWhoIds(List<Task> objects) {
        for(sObject o : objects) {
            Id whatId = (Id)o.get('WhatId');
            Id whoId = (Id)o.get('WhoId');
            if(whatId != null) {
                String objectName = getObjectNameFromId(whatId);
                if(objectName == 'Cases__c') casesIds.add(whatId);

            }
        }
    }

    private String getObjectNameFromId(Id objId) {
        String preFix = String.valueOf(objId).left(3).toLowercase();
        if(prefix == 'a0K') return 'cases__c';
        return '';
    }

    private String getStringFromIdSet(set<id> idSet) {
        string idString = '';
        for(Id i : idSet) idString+= '\'' + i + '\',';
        return idString == '' ? idString : idString.left(idString.length()-1); //If idString contains some ids we want to ensure we strip out the last comma
    }

    //The main part of the method below was taken from //Taken from http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_dynamic_dml.htm
    //However we've modified this to accept an object id
    private sObject createObject(String typeName, Id objId) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
        }

        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(objId);
    }

}