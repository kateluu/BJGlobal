<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Reset_Last_Crawl_Date</fullName>
        <field>Last_Crawl_Date__c</field>
        <name>Reset Last Crawl Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Recrawl keyword when changed</fullName>
        <actions>
            <name>Reset_Last_Crawl_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Name) || ISCHANGED(Geolocation_Override__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
