# Email Integration Package

This is an application that allows an email inbox to be integrated into Salesforce. 

After an initial email is sent to an external inbox it is forward to Salesforce and received by this app at which point any and all communications can be handled from the configured object's record. Initially it will be set up for Cases but it will be developed to integrate into any record.

## Install

## Post Install Config

EMAIL SETUP:

1) Setup user as context user for email service

2) Set Up Email Service using the provided apex class InboundEmailHandler

3) Set up forwarding in the email client with the provided Email Services Address.

4) Set Up and Verify Org Wide Email Address for From Address for automated emails. Change Custom Label 'Connect Team From Email Address' to match address of Org Wide Email Address if it does not match it.


SECURITY SETUP:

1) On appropriate Profiles, for Cases, under 'Page Layouts' section make Connect Team Page Layout the layout for Connect Team Record Type and under 'Record Type Settings' section assign Connect Team Record Type. Also give permission to org wide email address on profile level.

2) Assign Permission sets to appropriate users.  

3) If not visible, change field level security for Web Email and Case Age fields on Case.


MISC SETUP:

1) Add Users to Connect Team Queue and Public Group

2) Add Desired Quick Actions to Connect Team Case Page Layout. Add Email Feed Component to Page Layout if needed.