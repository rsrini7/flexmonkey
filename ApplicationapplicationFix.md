# Introduction #

With the use of the FlexMonkeyLauncher, which is an application, the loaded application to be tested no longer allows Application.application to reference the application, but it references FlexMonkeyLauncher.  There are two workarounds to this issue.

# Details #

  1. You can link FlexMonkey into your application instead of using the FlexMonkeyLauncher.  Instructions can be found at LinkingFlexMonkeyIntoApp.  The issue with this approach is you will need to recompile your application in order to deploy or you will have the automation and FlexMonkey code included in your application.

  1. This option will require a code modification, but allows your application to function properly and use the FlexMonkeyLauncher.  In your code change Application.application to be any UIComponent in your application.parentApplication.  For example, if you have a button in your application with an id="myButton", you would write myButton.parentApplication and it will return the same result as Application.application.