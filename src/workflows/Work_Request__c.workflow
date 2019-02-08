<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approved_Work_Request</fullName>
        <ccEmails>marketing@sponsoredlinx.com</ccEmails>
        <description>Approved Work Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/New_Work_Request</template>
    </alerts>
    <alerts>
        <fullName>Closed_Work_Request</fullName>
        <ccEmails>william.zhang@sponsoredlinx.com</ccEmails>
        <description>Closed Work Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/IT_Work_Request_completed</template>
    </alerts>
    <alerts>
        <fullName>IT_Work_Request</fullName>
        <ccEmails>william.zhang@sponsoredlinx.com</ccEmails>
        <description>IT Work Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/IT_Work_Request</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_to_Marketing_for_new_work_request</fullName>
        <ccEmails>slxmarketing@sponsoredlinx.com</ccEmails>
        <description>Send notification to Marketing for new work request</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AssignedNotification/New_Marketing_Work_Request</template>
    </alerts>
    <alerts>
        <fullName>Web_Feed_Install_Work_Request</fullName>
        <ccEmails>shanan.howe@sponsoredlinx.com</ccEmails>
        <description>Web Feed Install Work Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/Web_Feed_Install_Request</template>
    </alerts>
    <alerts>
        <fullName>Web_Work_Request</fullName>
        <ccEmails>shanan.howe@sponsoredlinx.com</ccEmails>
        <description>Web Google Code Work Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/Web_Work_Request</template>
    </alerts>
    <alerts>
        <fullName>Work_Request_Closed</fullName>
        <ccEmails>william.zhang@sponsoredlinx.com</ccEmails>
        <description>Work Request Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Work_Request/IT_Work_Request_completed</template>
    </alerts>
    <rules>
        <fullName>Closed Work Request</fullName>
        <actions>
            <name>Closed_Work_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Web(Google Codes),Web(Data Feed),IT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed,Not Doable</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT Work Request</fullName>
        <actions>
            <name>IT_Work_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web %28Google Codes%29 Work Request</fullName>
        <actions>
            <name>Web_Work_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Web(Google Codes)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web%28Data Feed%29 Work Request</fullName>
        <actions>
            <name>Web_Feed_Install_Work_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Web(Data Feed)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
