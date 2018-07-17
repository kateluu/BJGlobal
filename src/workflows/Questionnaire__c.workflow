<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Questionnaire_Completed_Alert</fullName>
        <ccEmails>shanan.howe@sponsoredlinx.com</ccEmails>
        <description>Questionnaire Completed Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>doug.carpenter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Convertopages/New_Questionnaire</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Status_To_Default</fullName>
        <field>Status__c</field>
        <literalValue>Project Ready</literalValue>
        <name>Update Status To Default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send New Questionnaire to Doug</fullName>
        <actions>
            <name>Questionnaire_Completed_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Questionnaire__c.Status__c</field>
            <operation>equals</operation>
            <value>Project Ready</value>
        </criteriaItems>
        <criteriaItems>
            <field>Questionnaire__c.Converto_Page_Required__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Status Default Value</fullName>
        <actions>
            <name>Update_Status_To_Default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Questionnaire__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Project Ready,In Progress,Complete</value>
        </criteriaItems>
        <description>Prevent User create questionnaire without status value</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
