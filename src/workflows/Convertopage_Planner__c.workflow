<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_email_alert_to_Doug_when_a_new_Convertopage_planner_is_created</fullName>
        <ccEmails>budh.bryant@sponsoredlinx.com</ccEmails>
        <description>Send email alert to Doug when a new Convertopage planner is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>doug.carpenter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Convertopages/Convertopage_planner</template>
    </alerts>
    <outboundMessages>
        <fullName>Convertopages_Account_Creation</fullName>
        <apiVersion>39.0</apiVersion>
        <endpointUrl>https://convertopages.com/user/user/apicreate</endpointUrl>
        <fields>Account__c</fields>
        <fields>Id</fields>
        <fields>What_email_add_do_you_want_your_lead__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>ben@bjbglobal.com.au</integrationUser>
        <name>Convertopages Account Creation</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>ConvertoPage Account Creation</fullName>
        <actions>
            <name>Convertopages_Account_Creation</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Convertopage_Planner__c.What_email_add_do_you_want_your_lead__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Convertopage_Planner__c.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>5/10/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Convertopage_Planner__c.Converto_password__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Create account in Convertopages whenever a convertopageplanner is submitted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ConvertoPage Salesforce Planner</fullName>
        <actions>
            <name>Send_email_alert_to_Doug_when_a_new_Convertopage_planner_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Convertopage_Planner__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
