<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
            <field>Build_Checked_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Spotchecked_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Team_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
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
            <value>Spot Check,Build Check</value>
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
            <value>Spot Check</value>
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
        <active>true</active>
        <criteriaItems>
            <field>Spot_Check__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending TL Action</value>
        </criteriaItems>
        <criteriaItems>
            <field>Spot_Check__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Spot Check,Build Check</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
