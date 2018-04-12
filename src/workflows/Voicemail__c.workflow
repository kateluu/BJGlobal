<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Miss_Call_Notification_Email</fullName>
        <description>Miss Call Notification Email</description>
        <protected>false</protected>
        <recipients>
            <field>Client_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AssignedNotification/Miss_Call_Notification</template>
    </alerts>
    <alerts>
        <fullName>URGENT_Miss_Call_Notification_Email_Need_To_Solve_ASAP</fullName>
        <description>URGENT : Miss Call Notification Email Need To Solve ASAP</description>
        <protected>false</protected>
        <recipients>
            <field>Client_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AssignedNotification/Miss_Call_Notification</template>
    </alerts>
    <alerts>
        <fullName>Urgent_notification_for_any_longer_than_2hour_waiting_miss_call</fullName>
        <description>Urgent notification for any longer than 2hour waiting miss call</description>
        <protected>false</protected>
        <recipients>
            <field>Client_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AssignedNotification/ASAP_Response_Miss_Call_Notification</template>
    </alerts>
    <rules>
        <fullName>Miss Call Notification</fullName>
        <actions>
            <name>Miss_Call_Notification_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Voicemail__c.Client_Manager__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>Voicemail__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Miss Call Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Urgent_notification_for_any_longer_than_2hour_waiting_miss_call</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Voicemail__c.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
