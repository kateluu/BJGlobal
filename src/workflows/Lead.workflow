<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GMT_Lead_Assignment_Notification</fullName>
        <description>GMT Lead Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Leads/GMT_New_Lead_Assignment</template>
    </alerts>
    <alerts>
        <fullName>SLX_Lead_Assignment_Notification</fullName>
        <description>SLX Lead Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Leads/SLX_New_Lead_Assignment</template>
    </alerts>
    <alerts>
        <fullName>SLX_Lead_Assignment_Notifications</fullName>
        <description>SLX Lead Assignment Notifications</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Leads/SLX_New_Lead_Assignment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_Email</fullName>
        <field>Sales_Rep_Email__c</field>
        <formula>Assigned_To__r.email__c</formula>
        <name>Update Sales Rep Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GMT Update Sales Rep Email Field</fullName>
        <actions>
            <name>GMT_Lead_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Sales_Rep_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED( Assigned_To__c ), OR(ISPICKVAL( BJB_Company__c, &apos;GetMoreTraffic NZ&apos;),ISPICKVAL( BJB_Company__c, &apos;GetMoreTraffic&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SLX Update Sales Rep Email Field</fullName>
        <actions>
            <name>SLX_Lead_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Sales_Rep_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED( Assigned_To__c ), OR(ISPICKVAL( BJB_Company__c, &apos;&apos;),ISPICKVAL( BJB_Company__c, &apos;SponsoredLinX&apos;),ISPICKVAL( BJB_Company__c, &apos;SponsoredLinX NZ&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
