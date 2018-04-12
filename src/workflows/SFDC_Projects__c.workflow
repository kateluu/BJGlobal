<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>X60_Days_Pending_Project_Info_Alert</fullName>
        <ccEmails>molly.hanrahan@sponsoredlinx.com</ccEmails>
        <description>60 Days Pending Project Info Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Projects/Alert_Pending_Project_Info_for_60_Days</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Pending_Project_Info_Date</fullName>
        <field>Pending_Project_Info_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Pending Project Info Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Completed_Date</fullName>
        <field>Project_Completed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Project Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_In_Progress_Start_Date</fullName>
        <field>In_progress_Start_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Project In Progress Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Ready_Date</fullName>
        <field>Project_Ready_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Project Ready Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Stage</fullName>
        <field>Project_Stage__c</field>
        <literalValue>Pending 1st Contact</literalValue>
        <name>Update Project Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>60 Days Pending Project Info Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Stage__c</field>
            <operation>equals</operation>
            <value>Pending Project Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Type__c</field>
            <operation>equals</operation>
            <value>SEO,Web &amp; SEO,Additional SEO Work,Directory Listings SEO,Local Visibility SEO</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X60_Days_Pending_Project_Info_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Create Initial SEO Project Tasks</fullName>
        <actions>
            <name>Update_Project_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>First_Call</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>INTERNAL_Level_1_Audit</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( Project_Type__c ,&apos;SEO&apos;), Owner:User.LastName != &apos;Site Guest User&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Project Info Date</fullName>
        <actions>
            <name>Update_Pending_Project_Info_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Stage__c</field>
            <operation>equals</operation>
            <value>Pending Project Info</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Completed Date</fullName>
        <actions>
            <name>Update_Project_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Stage__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project In Progress Date</fullName>
        <actions>
            <name>Update_Project_In_Progress_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Stage__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Ready Date</fullName>
        <actions>
            <name>Update_Project_Ready_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Projects__c.Project_Stage__c</field>
            <operation>equals</operation>
            <value>Project Ready</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>First_Call</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>First Call</subject>
    </tasks>
    <tasks>
        <fullName>INTERNAL_Level_1_Audit</fullName>
        <assignedTo>tom.caffrey@sponsoredlinx.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>INTERNAL - Level 1 Audit</subject>
    </tasks>
</Workflow>
