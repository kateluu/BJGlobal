<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Card_Number_Change</fullName>
        <description>Account Card Number Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>BJBGlobalAccountsAdmin</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Billing/Account_Card_Number_Is_Changed</template>
    </alerts>
</Workflow>
