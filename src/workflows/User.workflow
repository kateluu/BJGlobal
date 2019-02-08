<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_User_First_Name</fullName>
        <description>Change User First Name</description>
        <field>FirstName</field>
        <formula>&apos;IN-&apos; + FirstName</formula>
        <name>Change User First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Rename Inactive Users</fullName>
        <actions>
            <name>Change_User_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When any user becomes inaction , &apos;IN&apos; prefix will add to the first name</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
