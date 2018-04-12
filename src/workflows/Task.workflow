<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Callback_Request_from_LinX_App</fullName>
        <description>Callback Request from LinX App</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>william.zhang@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CM_Email_Templates/Call_Back_Request_From_LinX</template>
    </alerts>
    <fieldUpdates>
        <fullName>Tick_Call_Monitored_Tickbox</fullName>
        <field>Call_Monitored__c</field>
        <literalValue>1</literalValue>
        <name>Tick Call Monitored Tickbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Call Back Request From LinX</fullName>
        <actions>
            <name>Callback_Request_from_LinX_App</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Callback Request</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Call Monitor Details</fullName>
        <actions>
            <name>Tick_Call_Monitored_Tickbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Monitored_By__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
