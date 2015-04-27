
---


**Important Note: _This document describes FlexMonkey 0.8. To find documentation for later versions, please visit the FlexMonkey [Project Home](http://flexmonkey.gorillalogic.com#resources) site._**


---


# If the launcher doesn't work for you #

The preferred way to run FlexMonkey is with the [FlexMonkeyLauncher](GettingStarted.md). However, if for any reason your swf does not work properly when run with the launcher, you can link FlexMonkey and the automation API directly into your targetSwf by compiling it according to the instructions below.

# Linking FlexMonkey into your Application #

Build FlexMonkey from source, or [download it](http://code.google.com/p/flexmonkey/downloads/list). Then configure FlexMonkey as follows.

Add FlexMonkey.swc to the compile path of the Flex app you want to test and recompile it with the following additional Flex compiler options:

```
-includes com.gorillalogic.flexmonkey.ui.Bootstrap -include-libraries "/YOUR_FLEX_INSTALLATION/frameworks/libs/automation_agent.swc" "/YOUR_FLEX_INSTALLATION/frameworks/libs/automation.swc" "/YOUR_FLEX_INSTALLATION/frameworks/libs/automation_dmv.swc" 
```

If you're using Flex Builder, make sure the **Framework Linkage** on the **Flex Build Path** Library tab is set to **Merged into Code**. This will ensure that the swc's are merged into your application swf file. **automation\_agent.swc**, **automation.swc** and **automation\_dmv.swc** provide the [Flex automation API](http://www.adobe.com/devnet/flex/samples/custom_automated/) required by FlexMonkey.

# Starting FlexMonkey #

Start your appliction. FlexMonkey is a Flex [Mixin](http://nondocs.blogspot.com/2007/04/metadatamixin.html) class (just for the purpose of static initialization) and it launches itself when its class is loaded. The compiler options above ensure that FlexMonkey is linked into your test app and that it gets loaded when your app runs.

# Using FlexMonkey #

See the QuickTutorial.

# More Information on the Flex Automation API #

http://www.adobe.com/devnet/flex/samples/custom_automated/