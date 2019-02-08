<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SEO_Keywords_down_rank</fullName>
        <description>SEO Keywords down rank</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sponsoredlinx.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SEO_Website/SEO_Keyword_Unrank_Notification</template>
    </alerts>
</Workflow>
