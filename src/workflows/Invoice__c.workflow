<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Tick_the_Reminder_Task_Created</fullName>
        <field>Reminder_Task_Created__c</field>
        <literalValue>1</literalValue>
        <name>Tick the Reminder Task Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Automatic Tasks for Outstanding Invoices</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>AUTHORISED,PARTIALLY PAID</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice__c.Reminder_Task_Created__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Tick_the_Reminder_Task_Created</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Please_contact_client_Invoice_Outstanding_3_Weeks</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Invoice__c.Due_Date__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Invoice__c.Days_Overdue__c</field>
            <operation>greaterThan</operation>
            <value>21</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Invoice__c.Days_Overdue__c</field>
            <operation>greaterThan</operation>
            <value>21</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Invoice__c.Due_Date__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Please_contact_client_Invoice_Outstanding_3_Weeks</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please Contact Client: Invoice Outstanding &gt; 3 Weeks</subject>
    </tasks>
</Workflow>
