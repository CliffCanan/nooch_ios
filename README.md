nooch_ios
=========

iOS development

3rd Party Libraries Used
------------------------
* FPPopover
  - displays a popup-style menu in the form of a table) 
  - used in History and Transfer
* ECSlidingViewController
  - for the side menus that reveal when you slide to the left or right 
  - only accessible from NoochHome and History
* Google Analytics
  - for data analysis
* CardIO
  - for the card scanning functionality
  - used in AddCard only
* OBShapedButton
  - for circular buttons where you don't want to register touches outside the circle
  - only used on the NoochHome send money button

assist
------
- essentially the user object holding a user's information, performing frequent tasks, and storing values for use anywhere in the app

core
-----
- frontend for working with the assist class, also has helper methods for commonly needed returns

AppSkel
-------
- Initial navigation controller, it's rootViewController is NoochHome

NoochHome
---------
- redirects to Tutorial1 if someone was left logged in, if user is logged in and has remember me enabled redirects to PIN screen to validate user

serve.m
------
- Handles all the API calls to the server for easily calling them from anywhere else in the app