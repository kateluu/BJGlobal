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
        <fullName>Set_BJB_Company_Name</fullName>
        <field>BJB_Company__c</field>
        <literalValue>GetMoreTraffic</literalValue>
        <name>Set BJB Company Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SLX_Company_Process</fullName>
        <description>if the From Form value is ‘Sponsoredlinx AU &amp; NZ’, auto change the BJB Company field to SponsoredLinX</description>
        <field>BJB_Company__c</field>
        <literalValue>SponsoredLinX</literalValue>
        <name>Update SLX Company Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <rules>
        <fullName>Set GMT Company Name</fullName>
        <actions>
            <name>Set_BJB_Company_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.From_Form__c</field>
            <operation>equals</operation>
            <value>Get More Traffic</value>
        </criteriaItems>
        <description>if the From Form value is ‘Get More Traffic’, auto change the BJB Company field to GetMoreTraffic</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set SLX Company Name</fullName>
        <actions>
            <name>Update_SLX_Company_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.From_Form__c</field>
            <operation>equals</operation>
            <value>Sponsoredlinx AU &amp; NZ</value>
        </criteriaItems>
        <description>if the From Form value is ‘Sponsoredlinx AU &amp; NZ’, auto change the BJB Company field to SponsoredLinX</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
