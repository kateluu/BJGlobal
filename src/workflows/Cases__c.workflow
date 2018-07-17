<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Unresolved</fullName>
        <description>Case Unresolved</description>
        <protected>false</protected>
        <recipients>
            <recipient>SLX_CM_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>david.powell@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Unresolve_Case_Save</template>
    </alerts>
    <alerts>
        <fullName>New_assignment_notification</fullName>
        <description>New assignment notification to Amber</description>
        <protected>false</protected>
        <recipients>
            <recipient>amber.porter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/NewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Send_out_email_notification_to_assigned_resolution_manager_1_when_a_case_is_esca</fullName>
        <description>Send out email notification to assigned resolution manager when a case is escalated</description>
        <protected>false</protected>
        <recipients>
            <field>Resolution_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>contact@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cases/NewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>X48_Hours_Alert</fullName>
        <description>48 Hours Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Case_been_escalated_for_more_than_48_hrs</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Cancelled</fullName>
        <field>Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Case Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_status</fullName>
        <description>Change Case status</description>
        <field>Status__c</field>
        <literalValue>Unresolved</literalValue>
        <name>Change Case status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_as_Saved</fullName>
        <field>Saved__c</field>
        <literalValue>1</literalValue>
        <name>Mark as Saved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status</fullName>
        <description>Change Case Status to Unresolved</description>
        <field>Status__c</field>
        <literalValue>Unresolved</literalValue>
        <name>Update Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Date</fullName>
        <field>Case_Closed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Closed Date(Old Field)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Date1</fullName>
        <field>Closed_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Escalated_Date</fullName>
        <field>escalated_date__c</field>
        <formula>NOW()</formula>
        <name>Update Escalated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Resolution_Manager</fullName>
        <description>Update Resolution Manager To Courtney</description>
        <field>Resolution_Manager__c</field>
        <lookupValue>courtney.leech@sponsoredlinx.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Resolution Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>saved_date</fullName>
        <field>Save_Date__c</field>
        <formula>NOW()</formula>
        <name>saved date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_unresolved_datetime</fullName>
        <description>record the time when status was changed to unresolved</description>
        <field>unresolved_date__c</field>
        <formula>NOW()</formula>
        <name>update unresolved datetime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Move_Escalated_Cases_TO_RM_MCC</fullName>
        <apiVersion>43.0</apiVersion>
        <endpointUrl>http://13.210.18.161/adwordsapi/transfer</endpointUrl>
        <fields>Adwords_ID__c</fields>
        <fields>BJB_Company__c</fields>
        <fields>Id</fields>
        <fields>Linked_to_MCC__c</fields>
        <fields>Name</fields>
        <fields>OwnerId</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ben@bjbglobal.com.au</integrationUser>
        <name>Move Escalated Cases TO RM MCC</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Closed Cases</fullName>
        <actions>
            <name>Update_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Closed_Date1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Timestamp closed date when case status changed to closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Direct Social Escalated Case to FB team</fullName>
        <actions>
            <name>Update_Resolution_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Cases__c.CaseType__c</field>
            <operation>includes</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Product_Type__c</field>
            <operation>contains</operation>
            <value>Social</value>
        </criteriaItems>
        <description>Direct Social Escalated Case to FB team mananger. All facebook cancelation requests send to Courtney</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Amber when case changed to her name</fullName>
        <actions>
            <name>New_assignment_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Amber Porter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.OwnerId</field>
            <operation>equals</operation>
            <value>Amber Porter</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Escalated Cases</fullName>
        <actions>
            <name>Update_Escalated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Move Escalated Cases TO RM MCC</fullName>
        <actions>
            <name>Move_Escalated_Cases_TO_RM_MCC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Resolution_Manager__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Product_Type__c</field>
            <operation>equals</operation>
            <value>AdWords Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.CaseType__c</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Account_Resolution__c</field>
            <operation>notEqual</operation>
            <value>Save</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner Once Case Unresolved</fullName>
        <actions>
            <name>Case_Unresolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Unresolved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Account_Resolution__c</field>
            <operation>equals</operation>
            <value>Save</value>
        </criteriaItems>
        <description>Notify Case Owner Once Case Unresolved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Saved by Date</fullName>
        <actions>
            <name>Mark_as_Saved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>saved_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Account_Resolution__c</field>
            <operation>equals</operation>
            <value>Save</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sendout assigned email to RM</fullName>
        <actions>
            <name>Send_out_email_notification_to_assigned_resolution_manager_1_when_a_case_is_esca</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Resolution_Manager__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cases__c.Name</field>
            <operation>notEqual</operation>
            <value>98510</value>
        </criteriaItems>
        <description>Sendout assigned email to RM if there is any escalated case assigned to him</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Share Cases Account</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Cases__c.OwnerId</field>
            <operation>equals</operation>
            <value>Kerry</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unsolved Cases</fullName>
        <actions>
            <name>update_unresolved_datetime</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Please_edit</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cases__c.Status__c</field>
            <operation>equals</operation>
            <value>Unresolved</value>
        </criteriaItems>
        <description>when cases was changed to unresolved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Please_edit</fullName>
        <assignedTo>grace.james@sponsoredlinx.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please change the subject</subject>
    </tasks>
</Workflow>
