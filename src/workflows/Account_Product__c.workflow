<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_product_s_owner_is_inactive</fullName>
        <description>Account product&apos;s owner is inactive</description>
        <protected>false</protected>
        <recipients>
            <recipient>Client_Manager_Team_A_Leader</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sign_Up/Account_product_owner_inactive</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_of_CovertoPages</fullName>
        <description>Cancellation of CovertoPages</description>
        <protected>false</protected>
        <recipients>
            <recipient>doug.carpenter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CM_Email_Templates/Cancellation_of_ConvertoPages</template>
    </alerts>
    <alerts>
        <fullName>GMT_Product_Resume_Reminder</fullName>
        <description>GMT Product Resume Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/GMT_Product_Resume</template>
    </alerts>
    <alerts>
        <fullName>Inconsistent_Currency_Alert</fullName>
        <description>Inconsistent Currency Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ben@bjbglobal.com.au</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/Check_SLX_Products</template>
    </alerts>
    <alerts>
        <fullName>Products_Activate_Today</fullName>
        <description>Products Activate Today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CM_Email_Templates/Products_Activate_Today</template>
    </alerts>
    <alerts>
        <fullName>SLX_Product_Resume_Reminder</fullName>
        <description>SLX Product Resume Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/SLX_Product_Resume</template>
    </alerts>
    <alerts>
        <fullName>Send_Doug_Notifications_when_Adwords_Advanced_Products_Cancelled</fullName>
        <description>Send Doug Notifications When Adwords Advanced+ Products Cancelled</description>
        <protected>false</protected>
        <recipients>
            <recipient>doug.carpenter@sponsoredlinx.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/Cancelled_Adwords_Advance_Products</template>
    </alerts>
    <alerts>
        <fullName>Send_First_Management_Invoice_to_CM</fullName>
        <description>Send First Management Invoice to CM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/First_Invoice_Alert</template>
    </alerts>
    <alerts>
        <fullName>X14_Days_Pending_Linking_Alert</fullName>
        <ccEmails>daniel.sharman@sponsoredlinx.com</ccEmails>
        <description>14 Days Pending Linking Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/Facebook_Pending_Linking_Alert_14_Days</template>
    </alerts>
    <alerts>
        <fullName>X1st_Management_Invoice_Not_Paid_Alert</fullName>
        <description>1st Management Invoice Not Paid Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Team_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/X1st_Management_Invoice_Not_Paid</template>
    </alerts>
    <alerts>
        <fullName>X21_Days_Pending_Linking_Alert</fullName>
        <ccEmails>daniel.sharman@sponsoredlinx.com</ccEmails>
        <ccEmails>accounts@sponsoredlinx.com</ccEmails>
        <description>21 Days Pending Linking Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/Facebook_Pending_Linking_Alert_21_Days</template>
    </alerts>
    <alerts>
        <fullName>X7_Days_Pending_Linking_Alert</fullName>
        <ccEmails>daniel.sharman@sponsoredlinx.com</ccEmails>
        <description>7 Days Pending Linking Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_Product/Facebook_Pending_Linking_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Activate_Social_Product</fullName>
        <field>Product_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Activate Social Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Calculate_Paid_Waiting_Time</fullName>
        <description>Calculate Paid Waiting Time</description>
        <field>From_Last_Paid_Date__c</field>
        <formula>IF(ISNULL(Last_Paid_Date__c), NULL , TODAY() - Last_Paid_Date__c)</formula>
        <name>Calculate Paid Waiting Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Price</fullName>
        <field>Product_Price__c</field>
        <formula>Product_Price__c - Relationship_Discount__c</formula>
        <name>Change Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_back_to_normal_price</fullName>
        <field>Product_Price__c</field>
        <formula>Product_Price__c + Relationship_Discount__c</formula>
        <name>Change back to normal price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Last_Paid_Date</fullName>
        <description>Clear Last Paid Date</description>
        <field>Last_Paid_Date__c</field>
        <name>Clear Last Paid Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivate_Social_Product</fullName>
        <field>Product_Status__c</field>
        <literalValue>Suspended</literalValue>
        <name>Deactivate Social Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Discount_Product_Price</fullName>
        <field>Product_Price__c</field>
        <formula>Product_Price__c - Relationship_Discount__c</formula>
        <name>Discount Product Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_Reassigned_Update</fullName>
        <field>First_Reassigned_Date__c</field>
        <formula>NOW()</formula>
        <name>First Reassigned Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Product_Discription</fullName>
        <field>Description__c</field>
        <formula>&apos;Relationship Discount - $&apos;+ TEXT(Relationship_Discount__c) +&apos; Off&apos;</formula>
        <name>Update Account Product Description Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Product_Discription_1</fullName>
        <field>Description__c</field>
        <name>Update Account Product Description End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Invoice_Date</fullName>
        <description>Update Last Invoice Date to make sure the invoice will be generated on next day</description>
        <field>Last_Invoice_Date__c</field>
        <formula>TODAY() - 6</formula>
        <name>Update Last Invoice Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Changed_Time</fullName>
        <field>Last_Status_Changed_Time__c</field>
        <formula>now()</formula>
        <name>Update Status Changed Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Changed_Time_Deactivate</fullName>
        <description>Update Status Changed Time</description>
        <field>Last_Status_Changed_Time__c</field>
        <formula>now()</formula>
        <name>Update Status Changed Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Move_paused_to_MOH</fullName>
        <apiVersion>42.0</apiVersion>
        <endpointUrl>http://staging.clientpanel.sponsoredlinx.com.au/api/adwordsapi/transfer</endpointUrl>
        <fields>Adwords_ID__c</fields>
        <fields>BJB_Company__c</fields>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <fields>Product_Status__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ben@bjbglobal.com.au</integrationUser>
        <name>Move Active/Paused/Cancelled between MOH</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>1st Management Invoice Not Paid Alert</fullName>
        <actions>
            <name>X1st_Management_Invoice_Not_Paid_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>adwords,facebook</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Recurring_Period__c</field>
            <operation>equals</operation>
            <value>Weekly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Payment_Made_So_Far__c</field>
            <operation>equals</operation>
            <value>AUD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Active_Days__c</field>
            <operation>equals</operation>
            <value>9</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Last_Invoice_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activate Product Base On Paid Date</fullName>
        <actions>
            <name>Activate_Social_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Invoice_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_Changed_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For any social product only, activate the product if last paid date is less than 7days</description>
        <formula>( FIND(&apos;Social Engage&apos;, Name)&gt;-1 ) 
&amp;&amp;  (!ISNULL(Last_Paid_Date__c)) 
&amp;&amp; ((From_Last_Paid_Date__c &lt; 6) || (activeat__c = TODAY()))
&amp;&amp; ( ISPICKVAL(Product_Status__c,&apos;Cancel&apos;)
     || ISPICKVAL(Product_Status__c,&apos;Suspended&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto Task for resumed product</fullName>
        <actions>
            <name>Account_resumes_today_please_contact</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>notContain</operation>
            <value>Setup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.activeat__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Paid Waiting Time</fullName>
        <actions>
            <name>Calculate_Paid_Waiting_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>Social Engage</value>
        </criteriaItems>
        <description>Calculate Paid Waiting Time</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Capture First Reassigned Date</fullName>
        <actions>
            <name>First_Reassigned_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account_Product__c.First_Reassigned_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.OwnerId</field>
            <operation>notContain</operation>
            <value>Checkout</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.OwnerId</field>
            <operation>equals</operation>
            <value>Ben Bradshaw</value>
        </criteriaItems>
        <description>The first reassignment from CM To CM will be captured here</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ConvertoPages Cancellation</fullName>
        <actions>
            <name>Cancellation_of_CovertoPages</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>convertopages,GO! Pages</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deactivate Product Base On Paid Date</fullName>
        <actions>
            <name>Clear_Last_Paid_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Deactivate_Social_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_Changed_Time_Deactivate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For any social product only, deactivate the product if last paid date is over from 7days</description>
        <formula>( FIND(&apos;Social Engage&apos;, Name)&gt;-1 ) 
&amp;&amp; (!ISNULL(Last_Paid_Date__c))
&amp;&amp; (From_Last_Paid_Date__c &gt; 5)
&amp;&amp; ISPICKVAL(Product_Status__c , &apos;Active&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Facebook Pending Linking Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Pending Linking</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X7_Days_Pending_Linking_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>X21_Days_Pending_Linking_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>X14_Days_Pending_Linking_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>GMT - Product Resume Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.activeat__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Paused</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Owner_Role__c</field>
            <operation>contains</operation>
            <value>gmt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>adwords,facebook,seo</value>
        </criteriaItems>
        <description>Send product resume reminder to product owner 4 days before resume date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>GMT_Product_Resume_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account_Product__c.activeat__c</offsetFromField>
            <timeLength>-4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Move Active%2FPaused%2FCancelled between MOH %26 CM MCC</fullName>
        <actions>
            <name>Move_paused_to_MOH</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Paused,Cancelled,Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Adwords_ID__c</field>
            <operation>notEqual</operation>
            <value>000-000-0000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Adwords_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Product Cancellation Notification - Adwords Advanced%2B</fullName>
        <actions>
            <name>Send_Doug_Notifications_when_Adwords_Advanced_Products_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>Adwords Advanced+</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Recurring_Period__c</field>
            <operation>equals</operation>
            <value>Weekly,Fortnightly,Monthly,Quarterly,Half Yearly,Yearly,2 Yearly</value>
        </criteriaItems>
        <description>Create a cancellation notification for Doug Carpenter when the Adwords Advanced+ SEM/Trade are cancelled so he can take their Website down.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Product Resume Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.activeat__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Paused</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Owner_Role__c</field>
            <operation>notContain</operation>
            <value>gmt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>adwords,facebook,seo</value>
        </criteriaItems>
        <description>Send product resume reminder to product owner 4 days before resume date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SLX_Product_Resume_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account_Product__c.activeat__c</offsetFromField>
            <timeLength>-4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Products Activate Today</fullName>
        <actions>
            <name>Products_Activate_Today</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.activeat__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Relationship Discount</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Relationship_Discount__c</field>
            <operation>greaterThan</operation>
            <value>AUD 0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Change_back_to_normal_price</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Account_Product_Discription_1</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account_Product__c.To__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Discount_Product_Price</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Account_Product_Discription</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account_Product__c.From__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send First Invoice Alert to CM</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account_Product__c.Name</field>
            <operation>contains</operation>
            <value>adwords,facebook</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Recurring_Period__c</field>
            <operation>equals</operation>
            <value>Weekly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Product__c.Product_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_First_Management_Invoice_to_CM</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account_Product__c.CreatedDate</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Account_resumes_today_please_contact</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Product resumes today, please contact client</subject>
    </tasks>
</Workflow>
