_This is no longer the recommended way to run FlexMonkey. See the new [set up instructions](GettingStarted.md)._

# Preparing your application for testing #

Build FlexMonkey from source, or [download it](http://code.google.com/p/flexmonkey/downloads/list). Then configure FlexMonkey as follows.

Add FlexMonkey.swc to the compile path of the Flex app you want to test and recompile it with the following additional Flex compiler options:

```
-include-libraries "/YOUR_FLEX_INSTALLATION/frameworks/libs/automation_agent.swc" "/YOUR_FLEX_INSTALLATION/frameworks/libs/automation.swc" "/YOUR_APP_LIBS/FlexMonkeyUI.swc"
```

If you're using Flex Builder, make sure the **Framework Linkage** on the **Flex Build Path** Library tab is set to **Merged into Code**. This will ensure that the swc's are merged into your application swf file. **automation\_agent.swc** and **automation.swc** provide the [Flex automation API](http://www.adobe.com/devnet/flex/samples/custom_automated/) required by FlexMonkey.

# Starting FlexMonkey #

Start your appliction. FlexMonkey is a Flex [Mixin](http://nondocs.blogspot.com/2007/04/metadatamixin.html) class (just for the purpose of static initialization) and it launches itself when its class is loaded. The compiler options above ensure that FlexMonkey is linked into your test app and that it gets loaded when your app runs.

# Using FlexMonkey #

See the QuickTutorial.

# More Information on the Flex Automation API #

http://www.adobe.com/devnet/flex/samples/custom_automated/