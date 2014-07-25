Apigee-FacebookLogin
====================

Simple iOS app to demonstrate authenticating + creating a user in App Services via user's Facebook account.

##Screenshots

####Main View
![Main View](https://raw.githubusercontent.com/jeremyanticouni/Apigee-FacebookLogin/master/FacebookLogin/FacebookLogin-Screenshot-1.png) 


####Facebook Authorization
![Facebook Authorization](https://raw.githubusercontent.com/jeremyanticouni/Apigee-FacebookLogin/master/FacebookLogin/FacebookLogin-Screenshot-2.png) 

####Logged In
![Logged In](https://raw.githubusercontent.com/jeremyanticouni/Apigee-FacebookLogin/master/FacebookLogin/FacebookLogin-Screenshot-3.png) 

####Log Out
![Logout](https://raw.githubusercontent.com/jeremyanticouni/Apigee-FacebookLogin/master/FacebookLogin/FacebookLogin-Screenshot-4.png)

##Installation
###Dependencies
This project requires both the [Apigee iOS SDK](https://github.com/apigee/apigee-ios-sdk) and the [Facebook iOS SDK](https://developers.facebook.com/docs/ios).

###Configuration
####Framework Search Paths
#####Facebook SDK
The project will look for the Facebook SDK `FacebookSDK.framework` in the Facebook default installation path: `~/Documents/FacebookSDK`

#####Apigee SDK
The project will look for the Apigee SDK `ApigeeiOSSDK.framework` in the following path: `~/Documents/ApigeeSDK`

####Info.plist
There are a number of values that must be set before you can run the project:

* `ApigeeOrg`
* `ApigeeApp`
* `FacebookDisplayName`
* `FacebookAppID`

Additionally, you must add a new URL scheme to handle the redirection back to the app after the user authenticates with Facebook. This URL is fb + your Facebook App ID, for example, `fb1234567890`