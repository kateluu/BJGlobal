<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GMT_Send_accounts_notification_when_payment_batches_finish</fullName>
        <ccEmails>accounts@sponsoredlinx.com</ccEmails>
        <description>GMT Send accounts notification when payment batches finish</description>
        <protected>false</protected>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Payment_Batches/GMT_Todays_Payment_Batches</template>
    </alerts>
    <alerts>
        <fullName>Send_accounts_notification_when_payment_batches_finish</fullName>
        <ccEmails>accounts@sponsoredlinx.com</ccEmails>
        <description>Send accounts notification when payment batches finish</description>
        <protected>false</protected>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Payment_Batches/Todays_Payment_Batches</template>
    </alerts>
    <alerts>
        <fullName>Send_accounts_notification_when_payment_nz_batch</fullName>
        <ccEmails>accounts@sponsoredlinx.com</ccEmails>
        <description>Send accounts notification when slx nz payment batches finish</description>
        <protected>false</protected>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Billing/Todays_NZ_Payment_Batches</template>
    </alerts>
    <rules>
        <fullName>Email notification when payment batches finish</fullName>
        <actions>
            <name>Send_accounts_notification_when_payment_batches_finish</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Batch__c.Batch_Type__c</field>
            <operation>equals</operation>
            <value>Payments</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Batch_Period__c</field>
            <operation>equals</operation>
            <value>Today</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Name</field>
            <operation>contains</operation>
            <value>SLX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.status__c</field>
            <operation>equals</operation>
            <value>Payments Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Name</field>
            <operation>notContain</operation>
            <value>NZ</value>
        </criteriaItems>
        <description>for SLX</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email notification when slx nz payment batches finish</fullName>
        <actions>
            <name>Send_accounts_notification_when_payment_nz_batch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Batch__c.Batch_Type__c</field>
            <operation>equals</operation>
            <value>Payments</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Batch_Period__c</field>
            <operation>equals</operation>
            <value>Today</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Name</field>
            <operation>contains</operation>
            <value>NZ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.status__c</field>
            <operation>equals</operation>
            <value>Payments Complete</value>
        </criteriaItems>
        <description>for SLX NZ</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>GMT Email notification when payment batches finish</fullName>
        <actions>
            <name>GMT_Send_accounts_notification_when_payment_batches_finish</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Batch__c.Batch_Type__c</field>
            <operation>equals</operation>
            <value>Payments</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Name</field>
            <operation>contains</operation>
            <value>Today</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.Name</field>
            <operation>contains</operation>
            <value>GMT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice_Batch__c.status__c</field>
            <operation>equals</operation>
            <value>Payments Complete</value>
        </criteriaItems>
        <description>for GMT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
