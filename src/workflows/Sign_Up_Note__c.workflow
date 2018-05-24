<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_GMT_Sales_Manager_Postpone_Campaign</fullName>
        <description>Alert GMT Sales Manager Postpone Campaign</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Manager_Assistant_GMT</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up/Campaign_Start_Date_Not_ASAP</template>
    </alerts>
    <alerts>
        <fullName>Billing_Instruction_Alert</fullName>
        <ccEmails>accounts@sponsoredlinx.com</ccEmails>
        <description>Billing Instruction Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>grace.james@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up_Notes/Billing_Instructions</template>
    </alerts>
    <alerts>
        <fullName>Check_Signup_Price_GMT</fullName>
        <description>Check Signup Price GMT</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Manager_Assistant_GMT</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up/Please_check_sign_up_price</template>
    </alerts>
    <alerts>
        <fullName>Check_Signup_Price_SLX</fullName>
        <description>Check Signup Price SLX</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Manager_Assistant_SLX</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up/Please_check_sign_up_price</template>
    </alerts>
    <alerts>
        <fullName>If_campaign_start_date_is_not_asap_alert_sales_manager</fullName>
        <description>If campaign start date is not asap, alert sales manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Manager_Assistant_SLX</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up/Campaign_Start_Date_Not_ASAP</template>
    </alerts>
    <alerts>
        <fullName>Send_New_GMT_Sign_Up_Note_to_Sales_Manager</fullName>
        <description>Send New GMT Sign Up Note to Sales Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Manager_Assistant_GMT</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up_Notes/GMT_Sign_Up_Note</template>
    </alerts>
    <alerts>
        <fullName>Sign_Up_Note</fullName>
        <description>Sign Up Note</description>
        <protected>false</protected>
        <recipients>
            <recipient>gretel.phillips@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>outbound.teamleader@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up_Notes/Signup_Notes_Details</template>
    </alerts>
    <outboundMessages>
        <fullName>Adwords_Acc_Transfer</fullName>
        <apiVersion>42.0</apiVersion>
        <endpointUrl>http://13.210.18.161/adwordsapi/transfer</endpointUrl>
        <fields>Adwords_ID__c</fields>
        <fields>BJB_Company__c</fields>
        <fields>Id</fields>
        <fields>OwnerID__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>ben@bjbglobal.com.au</integrationUser>
        <name>Adwords Acc Transfer</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Adwords Acc Transfer</fullName>
        <actions>
            <name>Adwords_Acc_Transfer</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Transfer clients account from HC mcc to CM&apos;s MCC when assigned</description>
        <formula>AND(ischanged(OwnerID1__c), Sign_up__r.Owner:User.LastName != &apos;Site Guest User&apos;, Processed__c = false,  RecordType.Name = &apos;Adwords Signup Notes&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Billing Instruction Alert</fullName>
        <actions>
            <name>Billing_Instruction_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sign_Up_Note__c.Billing_Instruction__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Campaign Start Date GMT</fullName>
        <actions>
            <name>Alert_GMT_Sales_Manager_Postpone_Campaign</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Campaign_start_date__c  &lt;&gt;  TODAY() &amp;&amp; CONTAINS(Sign_up__r.Account__r.Name,&apos;GetMoreTraffic&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Campaign Start Date SLX</fullName>
        <actions>
            <name>If_campaign_start_date_is_not_asap_alert_sales_manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Campaign_start_date__c  &lt;&gt;  TODAY() &amp;&amp; NOT(CONTAINS(Sign_up__r.Account__r.Name,&apos;GetMoreTraffic&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check Signup Price GMT</fullName>
        <actions>
            <name>Check_Signup_Price_GMT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Is_Pricing_Correct__c, &apos;No&apos;)  &amp;&amp;  CONTAINS( Sign_up__r.Account__r.Name ,&apos;GetMoreTraffic&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check Signup Price SLX</fullName>
        <actions>
            <name>Check_Signup_Price_SLX</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Is_Pricing_Correct__c, &apos;No&apos;)  &amp;&amp; NOT(CONTAINS( Sign_up__r.Account__r.Name ,&apos;GetMoreTraffic&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send GMT Signup Notes</fullName>
        <actions>
            <name>Send_New_GMT_Sign_Up_Note_to_Sales_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sign_Up_Note__c.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Sign_Up__c.FromSource__c</field>
            <operation>contains</operation>
            <value>getmoretraffic</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Signup Notes to Amber</fullName>
        <actions>
            <name>Sign_Up_Note</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sign_Up_Note__c.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Sign_Up__c.FromSource__c</field>
            <operation>contains</operation>
            <value>sponsoredlinx</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
