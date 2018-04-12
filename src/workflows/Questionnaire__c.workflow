<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Questionnaire_Completed_Alert</fullName>
        <description>Questionnaire Completed Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>doug.carpenter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Convertopages/New_Questionnaire</template>
    </alerts>
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
</Workflow>
