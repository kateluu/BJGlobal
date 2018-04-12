<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetSalesTeam</fullName>
        <field>Sales_Team__c</field>
        <formula>IF(BEGINS(Account__r.Name, &quot;GetMoreTraffic&quot;), &quot;Get More Traffic&quot;, &quot;SponsoredLinx&quot;)</formula>
        <name>SetSalesTeam</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Opp_Update</fullName>
        <apiVersion>42.0</apiVersion>
        <endpointUrl>http://13.54.63.17/sf/opp</endpointUrl>
        <fields>Adwords_ID__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>ben@bjbglobal.com.au</integrationUser>
        <name>Opp Update</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Update SF Opp</fullName>
        <actions>
            <name>Opp_Update</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SLXOpportunity__c.Adwords_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Sales Team</fullName>
        <actions>
            <name>SetSalesTeam</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set sales team for opportunity</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
