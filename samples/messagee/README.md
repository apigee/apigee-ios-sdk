##Overview
This is a moderately complex iOS sample application that demonstrates social interaction features of
Apigee's App Services.

In order to compile and run this application, you must first add ApigeeiOSSDK.framework to this application.



##Using the app
This app uses Apigee's App Services, which is a free hosted version of the open source BaaS project called Usergrid.  We have configured a default user account for you to demo the app:

	username: myuser
	password: mypass
	
But if you are ready to get in and make your own users, learn more about App Services and sign up for a free account here:

<http://apigee.com/about/developers>

Once you have signed up, go into your App services account.  You will see that by default, every new App Services account comes with a default Application (which is like a namespace in the database) called "Sandbox". 

Either create a new application, or use the default sandbox app and make a few new users (click the users link on the left hand side of the Admin Portal, then choose "New User" in the upper right hand side of that view). 


Once you have set up your new users, navigate to this file:

	/Messagee/Client.m
	
And locate these lines on around line 20:

	//configure the org and app
	NSString * orgName = @"ApigeeOrg";
	NSString * appName = @"MessageeApp";

Change the org name to the one you signed up with (usually your username) and change the app name to the one you are using (e.g. Sandbox).  For example, if your org name is "myorgname" and you are using the sandbox, your code should look like this:

	//configure the org and app
	NSString * orgName = @"myorgname";
	NSString * appName = @"sandbox";

**Note:** Org and App names are not case sensitive.

Now you should be able to run the app again and log in with any of the new users you just created.  Try posting messages and having your users follow each other (just enter another user's username on the "Follow User" screen.

##About the app
This app uses the storyboard feature to lay out all the screens in the app.  The logic for connecting to the API happens in the Messagee/Client.m file, and an instance of this object is passed from view to view to maintain state and to provide a facility for each view to make API calls.

