public with sharing class TaskExtension {

	private final Task myTask;

    public TaskExtension(ApexPages.StandardController stdController) {
        this.myTask = [SELECT Id, OwnerId, CallDurationInSeconds, NVMContactWorld__CW_Call_Start_Time__c FROM Task WHERE Id = :stdController.getRecord().Id LIMIT 1];
    }

    // Get the URL for the call recording, if user has permission
    public String getCallRecordingURL() {

        // To avoid URL hacking to be able to listen to any task ID, we include a signature hash in the URL which will be checked by the console.
        String secretKey = '!BfejQCuj2RCQ<fGjuLPp]~Z>Mg5=^EyKmAD`W5^4psPZtu3aS7]s9}YR$LV';

        String URL;

        // Load the task and the owner so we can get the call details and extension
        User taskOwner = [SELECT Id, Extension, UserRoleId FROM User WHERE Id = :myTask.OwnerId LIMIT 1];

        if ( getCallRecordingAccess() ){
            String extension = taskOwner.Extension;
            String duration = string.valueof(myTask.CallDurationInSeconds);
            String timestart = myTask.NVMContactWorld__CW_Call_Start_Time__c.format('yyyy-MM-dd HH:mm:ss', 'UTC');

            if (extension != null && duration != null && timestart != null){
                String signatureString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueof(myTask.Id + extension + duration + timestart + secretKey)));
                
                URL = slxConsole.getBaseURL() + '/?c=calls&action=recordingForNvm&taskid='+myTask.Id+'&ext='+extension+'&timestart='+EncodingUtil.urlEncode(timestart, 'UTF-8')+'&duration='+duration+'&signature=' + signatureString;
            }
        }

        system.debug('URL: ' + URL);

        return URL;
    }

    // Check whether user has access to this task's call
    public Boolean getCallRecordingAccess() {

        User taskOwner = [SELECT Id, Extension, UserRoleId FROM User WHERE Id = :myTask.OwnerId LIMIT 1];

        if ( taskOwner.Id ==  UserInfo.getUserId() || isRoleAncestor(taskOwner.UserRoleId, UserInfo.getUserRoleId()) ){
            return true;
        }

        return false;
    }


    // Check if a role is the ancestor of this role. Note: does not match if it is the current role, only an ancestor of it.
    private static Boolean isRoleAncestor(String checkRoleId, String parentRoleId){

        // Otherwise keep traversing up until we hit the target parent role OR there is no more parentRoleId
        UserRole checkRole = [SELECT Id, Name, parentRoleId FROM UserRole WHERE Id = :checkRoleId LIMIT 1];

        if (!String.isEmpty(checkRole.parentRoleId)){
            // If the role we're checking matches the target parent role, we've got a match
            if (checkRole.parentRoleId == parentRoleId) {
                return true;
            }

            return isRoleAncestor(checkRole.parentRoleId, parentRoleId);
        }

        return false;
    }

}