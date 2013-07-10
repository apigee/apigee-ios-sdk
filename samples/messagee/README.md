##Version

Current Version: **0.9.2**

Change log:

<https://github.com/apigee/usergrid-sample-ios-messagee/blob/master/changelog.md>

**About this version:** 
This is basically a complete rebuild of our previous Messagee example.  I used the existing artwork and a very small portion of the display code.  The two main improvements are removing the dependency on RestKit and properly incorporating the Usergrid iOS SDK.  

Please feel free to send comments:

	twitter: @rockerston
	email: rod at apigee.com
	
Or just open github issues.  I truly want to know what you think, and will address all suggestions / comments / concerns.

Thank you!

Rod


##Overview
This project is open source.  Download it, use it, modify it.  Find it here:

<https://github.com/apigee/usergrid-sample-ios-messagee>

The project already comes with the iOS SDK (in the Usergrid directory), but you can download the latest version from the github repo here:

<https://github.com/apigee/usergrid-ios-sdk>

To find out more about Apigee App Services, see:

<http://apigee.com/about/developers>

To view the Apigee App Services documentation, see:

<http://apigee.com/docs/app_services>


##iOS Development
You must have a Mac to develop native iOS applications.  If you don't, consider developing your app using Javascript/HTML5 or Java Android.  We have SDKs for both these platforms:

<https://github.com/apigee/usergrid-javascript-sdk>

<https://github.com/apigee/usergrid-java-sdk>


##Installing
The first thing you will need to do is install Xcode.  Get it here:

<https://developer.apple.com/xcode>

Next, clone this repo or download it directly:

* Download as a zip file: <https://github.com/apigee/usergrid-sample-ios-messagee/archive/master.zip>
* Download as a tar.gz file: <https://github.com/apigee/usergrid-sample-ios-messagee/archive/master.tar.gz>
 
Extract the archive and double click this file, located in the root of the project:

	Messagee.xcodeproj

This should launch Xcode with all project settings ready to go. To run the app, select your output device and press the run button in the upper left hand corner of Xcode.


**Note:** This app is formatted for iPhone.  It will work on iPad, but will appear in a small window in the middle of the screen.


##Using the app
This app uses Apigee's App Services, which is a free hosted version of the open source BaaS project called Usergrid.  We have configured a default user account for you to demo the app:

	username: myuser
	password: mypass
	
But if you are ready to get in and make your own users, learn more about App Services and sign up for a free account here:

<http://apigee.com/about/developers>

Once you have signed up, go into your App services account.  You will see that by default, every new App Services account comes with a default Application (which is like a namespace in the database) called "Sandbox". 

Either create a new application, or use the default sandbox app and make a few new users (click the users link on the left hand side of the Admin Portal, then choose "New User" in the upper right hand side of that view). 


Once you have set up your new users, navigate to this file:

	/Messagee/client.m
	
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
This app uses the storyboard feature to lay out all the screens in the app.  The logic for connecting to the API happens in the Messagee/client.m file, and an instance of this object is passed from view to view to maintain state and to provide a facility for each view to make API calls.

The SDK is located in the /Messagee/Usergrid folder.  Use this same structure in apps you create.  More advanced users can also choose to create a separate project and include the SDK that way.

##Getting help
We are here to help!

You can reach out for support directly from Apigee:

<http://support.apigee.com/>

Drop by our Google group:

<https://groups.google.com/forum/?hl=en#!forum/usergrid>

Or go new-school and just open a github issue:

<https://github.com/apigee/usergrid-sample-ios-messagee/issues>

## Contributing
We welcome your enhancements!

Messagee is open source and licensed under the Apache License, Version 2.0.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push your changes to the upstream branch (`git push origin my-new-feature`)
5. Create new Pull Request (make sure you describe what you did and why your mod is needed)

##More information
For more information on Apigee App Services, visit <http://apigee.com/about/developers>.

## Copyright
Copyright 2012 Apigee Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.