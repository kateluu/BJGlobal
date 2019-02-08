<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Create_activity_history_for_email</fullName>
        <ccEmails>emailtosalesforce@3mufylm3fwa5eomuuz1a8zkvv.in.salesforce.com</ccEmails>
        <description>Create activity history for email</description>
        <protected>false</protected>
        <senderAddress>signup@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>End_of_Month/Spot_Check_Alert_For_Activity_History</template>
    </alerts>
    <alerts>
        <fullName>Send_Completed_Spot_Build_Check_Alert</fullName>
        <description>Send Completed Spot/Build Check Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Build_Checked_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Spotchecked_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>End_of_Month/Completed_Spot_Build_Check</template>
    </alerts>
    <alerts>
        <fullName>Send_Spotcheck_Alert_to_CMs</fullName>
        <description>Send Spotcheck Alert to CMs</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>End_of_Month/Spot_Check_Alert</template>
    </alerts>
    <alerts>
        <fullName>Send_Spotcheck_Alert_to_TLs</fullName>
        <description>Send Spotcheck Alert to TLs</description>
        <protected>false</protected>
        <recipients>
            <field>Team_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>signup@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>End_of_Month/Spot_Check_Alert</template>
    </alerts>
    <alerts>
        <fullName>Send_Spotcheck_Alert_to_TLs_History</fullName>
        <ccEmails>emailtosalesforce@3mufylm3fwa5eomuuz1a8zkvv.in.salesforce.com</ccEmails>
        <description>Send Spotcheck Alert to TLs History</description>
        <protected>false</protected>
        <senderAddress>signup@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>End_of_Month/Spot_Check_Alert</template>
    </alerts>
    <rules>
        <fullName>Completed Spot%2FBuild Check Alert</fullName>
        <actions>
            <name>Send_Completed_Spot_Build_Check_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Spot_Check__c.Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Spot_Check__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Spot Check,Build Check,Auto Build Check,Auto Build Check Edit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Spotcheck Alert to CMs</fullName>
        <actions>
            <name>Send_Spotcheck_Alert_to_CMs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Spot_Check__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending CM Action</value>
        </criteriaItems>
        <criteriaItems>
            <field>Spot_Check__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Spot Check,Build Check,Auto Build Check Edit,Auto Build Check</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Spotcheck Alert to TLs</fullName>
        <actions>
            <name>Send_Spotcheck_Alert_to_TLs</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_Email_To_TL</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Spot_Check__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending TL Action</value>
        </criteriaItems>
        <criteriaItems>
            <field>Spot_Check__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Spot Check,Auto Build Check Edit,Build Check,Auto Build Check</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Send_Email_To_TL</fullName>
        <assignedToType>owner</assignedToType>
        <description>This is the activity history for sending email TL</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Send Email To TL</subject>
    </tasks>
</Workflow>
