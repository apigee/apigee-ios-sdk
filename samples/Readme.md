#Apigee iOS SDK Sample Apps

The sample apps in this directory are intended to show basic usage of some of the major features of App Services using the Apigee JavaScript SDK. By default, all of the sample apps are set up to use the unsecured 'sandbox' application that was created for you when you created your Apigee account.

##Included Samples Apps

* **books** - A 'list' app that lets the user create, retrieve and perform geolocation queries on a list of books. This sample also makes use of jQuery and jQuery mobile.
* **messagee** - A Twitter-like app that uses data store, social and user management features.
* **monitoringSample** - An app that lets you test the App Monitoring feature by sending logging, crash and error reports to your account.
* **push** - An app that sends push notifications to mobile devices using APNS or GCM.
* **usersAndGroups** - An app that shows you how to create and manage user and group entities.

##Running the sample apps

To run the sample apps, simply open the .xcodeproj file in Xcode, then run the app.

Before you do, however, each of the sample apps require you to do two things:

* Include the Apigee iOS SDK

For instructions on how to do this, visit our [iOS SDK install guide](http://apigee.com/docs/app-services/content/installing-apigee-sdk-ios). 

* Provide your Apigee organization name

Each of these apps are designed to use the default, unsecured 'sandbox' application that was included when you created your Apigee account. To access your data store, you will need to provide your organization name by updating the call to Apigee.Client in each sample app. Near the top of the code in each app, you should see something similar to this:

```obj-c
NSString * orgName = @"yourorgname"; //Your Apigee.com username
NSString * appName = @"sandbox"; //Your App Services app name
```

Simply change the value of the orgName property to your Apigee organization name.