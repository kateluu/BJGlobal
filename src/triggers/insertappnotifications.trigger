trigger insertappnotifications on App_Notification__c (after insert) {
    
    sendappnotification.notification(System.trigger.new[0].Account__c,System.trigger.new[0].Push_Notifications__c);
}