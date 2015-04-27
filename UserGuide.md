
---


**Important Note: _This document describes FlexMonkey 0.8. To find documentation for later versions, please visit the FlexMonkey [Project Home](http://flexmonkey.gorillalogic.com#resources) site._**


---




# Overview of the flexmonkey Framework #

Flexmonkey is comprised of two components:

  * **FlexMonkey.swc** - A library providing the flexmonkey user interface, the recording and playback API, and a FlexUnit test runner.

  * **FlexMonkeyLauncher.swf** - An application that launches Flex applications for use with FlexMonkey. You use the launcher both for creating new tests as well as replaying previously recorded tests.


# targetSwfs and testSwfs #

By using the launcher, you can test any application without needing to link it with testing libraries or test case code. You package your test cases into a separate swf (the _testSwf_) that is loaded by the launcher dynamically along with your application (the _targetSwf_).

# The flexmonkey user interface #

The flexmonkey user interface is used to:

  * Load testSwfs and targetSwfs
  * Record and playback user interactions
  * Generate source code for creating a testSwf

The interface is organized around the following components:

  * The **Record** button, which toggles on and off the recording of user interactions in the targetSwf.
  * The **Setup** tab, which can be used to interactively specify targetSwfs and testSwfs for loading, and which displays the currently loaded swf file names.
  * The **Command List** tab, which displays any captured user interaction commands, and provides for editing captured commands.
  * The **TestCase Code** tab, which displays actionscript source generated from captured targetSwf user interactions.
  * The **FlexUnit Runner** tab, which contains an embedded flexunit test runner.

# Loading a targetSwf into flexmonkey #

To load a swf for testing, copy FlexMonkeyLauncher.swf to the directory containing the swf you wish to test, then launch FlexMonkey.swf with the standalone flash player.

Enter the name of the swf you want to test in the **App to Test** field on the **Setup** tab and click the **Load SWF** button. The application should start and be displayed beneath the flexmonkey window.

FlexMonkeyLauncher provides the Flex automation API as well as the flexmonkey API and user interface needed for creating and running tests. Prior to FlexMonkey 0.6, it was necessary to create a special version of your application swf that was linked with the FlexMonkey and Flex Automation libraries. Now however, FlexMonkeyLauncher provides these dynamically to any application it loads, so the swf you test can be the very same swf as the one you will deploy into production.


# Recording UI Interactions #

Click the **Record** button. The **Command List** window will be displayed. Each interaction with the targetSwf will be recorded as a **command** in the list. Clicking on the flexmonkey window will stop recording. Clicking the **Record** button again will resume recording and append new commands to the end of the list.

# Playing Back Commands #

Click the **Run** button on the **Command List** tab. Recorded commands will be replayed against the targetSwf. If no commands in the list are highlighted, all commands will be replayed. If commands are selected, then only the selected commands will be replayed.

# Understanding Recorded Commands #

The !FlexAutomationAPI dispatches [AutomationRecordEvent](http://livedocs.adobe.com/flex/3/langref/index.html)s containg an event name, an array of argument objects, and a reference to the target component. Flexmonkey checks for the existence of a property value it can use to identify the component on playback. Properties are searched in the following sequence:

  1. automationName
  1. id
  1. automationID

Many (most?) Flex components generate an automationName using some logically identifying value. A Button, for example, has a default automationName set to its label. The !FlexAutomationAPI generates an [AutomationID](http://livedocs.adobe.com/flex/3/langref/index.html) for every component, so every recorded command is guaranteed to provide an identifier value. automationID's are however derived by serializing the component tree from the component back to the root, and is therefore a very long and very unreadable string. If you want your tests to be readable and (human) modifiable, you will want to assign components id's or automationNames. Alternatively, you can modify a command to use a specific property-value pair, as described below.

If when playing back a test you get an "Unable to resolve id.." error, it is likely because a previously recorded automationID is no longer valid. This is typically because the component tree has changed since the test was recorded, and so the target component now has a new automationID. You will need to re-record your test, or modify the command that's failing to use a different property-value pair as described below.

# Modifying Recorded Commands #

You can clear all commands from the lists by clicking the **Clear** button. You can delete individual commands by clicking the delete-icon to the left of each command. Toggling the **Record** button on will add newly recorded commands to the end of the list.

Clicking the **Enable editing** checkbox will allow you to modify the recorded commands. (You cannot currently edit the **Arguments** column). You can change the Value and Property columns to any property-value pair you want to use to identify the component. Flexmonkey will return the first component found containing the pair (the search order is indeterminate). You can limit the search to the children of a component identified by the **Container Value** and **Container Property** columns. If no Container values are specified, the search considers all components. (Specifically, all "raw" descendants of the [SystemManager](http://livedocs.adobe.com/flex/2/langref/mx/managers/SystemManager.html)).

As an additional aid in developing tests, FlexMonkey includes [http://code.google.com/p/fxspy/](FlexSpy.md) to allow you to inspect the !UIComponent tree comprising your app. To start FlexSpy, click on the **FlexSpy** button on the **!Command List** tab.

# Generating a flexunit Test #

Click on the FlexUnit TestCase tab to view the generated source code. Two methods are generated, the first calls FlexMonkey.runCommands passing it an array of FlexCommands generated from the Flexmonkey Command List. The second method contains a stub body where you would write actual validation code specific to what's being tested by the command sequence. You can copy and paste this code into a FlexUnit TestCase and add it to any FlexUnit TestSuite. (With minor modifications, the source can be used with other automated testing suites besides FlexUnit).

![http://flexmonkey.googlecode.com/svn/trunk/FlexMonkey/docs/images/screenShot3.png](http://flexmonkey.googlecode.com/svn/trunk/FlexMonkey/docs/images/screenShot3.png)

Click the **Show completeTestCase** checkbox and a complete FlexUnit TestCase will be generated.

![http://flexmonkey.googlecode.com/svn/trunk/FlexMonkey/docs/images/screenShot4.png](http://flexmonkey.googlecode.com/svn/trunk/FlexMonkey/docs/images/screenShot4.png)

Copy and paste the generated code into an ActionScript source file and add testing validations. For example:

```
package test
{
	import com.gorillalogic.flexmonkey.commands.CallCommand;
	import com.gorillalogic.flexmonkey.commands.CommandRunner;
	import com.gorillalogic.flexmonkey.commands.FlexCommand;
	import com.gorillalogic.flexmonkey.core.MonkeyEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.DateField;


	public class FlexUnitTests extends TestCase {

	// Test method
	public function testSomething():void {
		var cmdRunner:CommandRunner = new CommandRunner();
		cmdRunner.addEventListener(MonkeyEvent.READY_FOR_VALIDATION, addAsync(verifySomething, 10000));
		cmdRunner.runCommands([
			new FlexCommand("inName", "SelectText", ["0", "0"], "automationName"),
			new FlexCommand("inName", "Input", ["Fred"], "automationName"),
			new FlexCommand("inType", "Open", ["null"], "automationName"),
			new FlexCommand("inType", "Select", ["Work", "1", "0"], "automationName"),
			new FlexCommand("inPhone", "SelectText", ["0", "0"], "automationName"),
			new FlexCommand("inPhone", "Input", ["555 555 5555"], "automationName"),
			// The following command was inserted manually to demonstrate a workaround for DateField bug
			// See http://groups.google.com/group/flexmonkey/browse_thread/thread/bf4af5e1d8164608# for more info
			new CallCommand(function():void {DateField(MonkeyUtils.findComponentWith("inDate")).open()}),			
			new FlexCommand("inDate", "Open", ["null"], "automationName"),
			new FlexCommand("inDate", "Change", ["Fri Dec 26 2008"], "automationName"),
			new FlexCommand("Add", "Click", ["0"], "automationName")
]);
   }
	// Called after commands have been run
	private function verifySomething(event:MonkeyEvent):void {
		   var comp:DataGrid = MonkeyUtils.findComponentWith("grid","id") as DataGrid;
		   Assert.assertEquals("Fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
		   Assert.assertEquals("Work", ArrayCollection(comp.dataProvider).getItemAt(0).type);		   

	}   }
}

```

Let's examine the code. First, we need a CommandRunner to run our FlexMonkey commands.

```
		var cmdRunner:CommandRunner = new CommandRunner();
```

Next, we have to tell FlexUnit that the test is asynchronous. After Flexmonkey completes running a command list, he dispatches a **READY\_FOR\_VALIDATION** event. We use FlexUnit TestCase's addAsync method to tell FlexUnit that our **READY\_FOR\_VALIDATION** event handler's completion signals that the test has passed (unless of course one of our assertions fails). (Learn [more](http://www.adobe.com/cfusion/communityengine/index.cfm?event=showdetails&productId=2&postId=6882) about asynchrounous testing with FlexUnit).

```
		cmdRunner.addEventListener(MonkeyEvent.READY_FOR_VALIDATION, addAsync(verifySomething, 10000);
```

The second argument to addAsync tells FlexUnit to fail the test if the event is not received within 10 seconds.

The handler passed to addAsync is where you would typically write your validation code:

```
	private function verifySomething(event:MonkeyEvent):void {
	   var comp:DataGrid = MonkeyUtils.findComponentWith("grid","id") as DataGrid;
	   Assert.assertEquals("Fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
	   Assert.assertEquals("Work", ArrayCollection(comp.dataProvider).getItemAt(0).type);		   
	}
```

You can easily access UI components using the MonkeyUtils.findComponentWith() Method.

```
		/**
		 * Find the first component with the specified property/value pair. If a container is specified, then
		 * only its children and descendents are searched. The search order is (currently) indeterminate. If no container is specified,
		 * then all components will be searched. If the prop value is "automationID", then the id is resolved directly without searching.
		 */
		public static function findComponentWith(value: String, prop:String="automationName", container:UIComponent=null):UIComponent
```

You can then examine component properties to determine if the script has produced the expected state using standard FlexUnit assertions.

```
	   Assert.assertEquals("Fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
	   Assert.assertEquals("Work", ArrayCollection(comp.dataProvider).getItemAt(0).type);		
```

The testSomething method adds a row to the table and we're checking that the columns in its first row have the expected name and phone type, "Fred" and "Work".


# Packaging your tests as a SWF #

We can package the tests in their own swf so that they're run by FlexMonkey without being linked directly into your application swf. In this way, no test code gets included with your deployed application.

We package up the tests into their own swf by invoking them from the (trivial) application such as the following:

```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" creationComplete="create()">
	<mx:Script>
		<![CDATA[
			import test.YourTests;
			import com.gorillalogic.flexmonkey.ui.FlexMonkey;
			public function create():void {
			   // Run with the FlexMonkey's built-in testrunner
		     	   FlexMonkey.addTestSuite(YourTests);

			}
		]]>
	</mx:Script>
</mx:Application>
```

To create your own testSwf wrapper, simply replace **YourTests** in the above code with an actual reference to your FlexUnit test suite.

Add FlexMonkey.swc (included in the **lib** directory of the example) to your build path to compile the testSwf.

# Passing Parameters to flexMonkeyLauncher #

In order to automate running FlexMonkey tests, you can create an html wrapper that starts FlexMonkeyLauncher and passes it the testSwf and targetSwf names via [flashvars](http://livedocs.adobe.com/flex/3/html/help.html?content=passingarguments_3.html).

The FlexMonkey example provides MonkeyContactsTest.html that you can use as a template for creating a wrapper.

```
<html>
<!-- 

Customize this file to pass arguments to FlexMonkeyLauncher:

targetSwf (required) - The name of the swf to be tested. It must reside in the same directory as FlexMonkeyLauncher.
testSwf - The name of the swf continaing your tests. It also must reside in the same place as FlexMonkeyLauncher.
visible - If false, the FlexMonkey window will not be displayed
targetHeight - The height to be set for the targetSwf.
targetWidth - The width to be set for the targetSwf.

The arguments are passed to FlexMonkeyLauncher as flashvars. See http://livedocs.adobe.com/flex/3/html/help.html?content=passingarguments_3.html
to learn more about setting flashvars. flashvars are passed by IE using the "param" tag. Other browsers use the "embed" tag. 
Specify both if you'll be testing in both browsers.

 -->
<head>
<title>FlexMonkeyLauncher</title>
<style>
body { margin: 0px;
 overflow:hidden }
</style>
</head>
<body scroll='no'>


    <object id='FlexMonkeyRunner' classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab' height='100%' width='100%'>
        <param name='src' value='FlexMonkeyLauncher.swf'/>
        <param name='flashVars' value='targetSwf=MonkeyContacts&testSwf=FlexMonkeyTests&visible=true'/>
        <embed name='mySwf' src='FlexMonkeyLauncher.swf' pluginspage='http://www.adobe.com/go/getflashplayer' height='100%' width='100%' flashVars='targetSwf=MonkeyContacts&testSwf=FlexMonkeyTests&visible=true'/>
    </object>

</body>
</html>

```

The swf to launch is specified using a [flashvar](http://livedocs.adobe.com/flex/3/html/help.html?content=passingarguments_3.html) called **targetSwf**. Notice that the targetSwf parameter is specified twice. The **param** tag specifies it for IE browsers, and the **embed** tag specifies it for non-IE ones. You only need to use both if you'll be testing in multiple browser types.

When you open FlexMonkeyTest.html in a browser, the targetSwf application window opens, and the FlexMonkey window opens on top of it (unless **visible** is set to _false_). If a testSwf is specified, then it's also loaded. When [running from ant](RunningFromAnt.md), the testSwf would additionally kick off the test runner.

# Running from Ant #

See RunningFromAnt.

# Testing Server-based SWF's #

Simply deploy FlexMonkeyLauncher.swf, the test swf (FlexMonkeyTests.swf) and the html wrapper (MonkeyContactsTest.html) to the directory on the server containing the app to be tested (MonkeyContacts.swf). Then open the wrapper in a browser specifying the full url, for example, `http://localhost:8080/myapp/MonkeyContactsTest.html`.

# Understanding flexCommands #

!Flexmonkey generates FlexCommands from your recorded commands, and you can of course easily change or create them in source code, or generate command sequences programmatically.

```
		/**
		 * Generate a flex event for the component identified by the specified 
		 * property-value pair.
		 * 
		 * @param value the value to search for
		 * @param name the name of the event to generate
		 * @param args the event args
		 * @param prop the property to search for the specified value. Defaults to automationName.
		 * @param containerValue if specified, only children/descendants of the container having this property value will be searched.
		 * @param containerProp The property to search for the specified containerValue. If no containerProperty-containerValue pair is specified, all components will be searched.
		 */ 	
		public function FlexCommand(value:String, name:String, args:Array = null, prop:String = "automationName", containerValue:String = null, containerProp:String = null)
```

For example:

```
// Click the "Add" button 100 times.
for (i:int=0; i < 100; i++) {
   var cmd:FlexCmmand = new FlexCommand("Click","Add",["0"],"label"]);
   cmds[i] = cmd;
}

runCommands(cmds);
```

# Adding Pauses to your Script #

All commands are executed asynchronously, and it can sometimes be necessary to force a command to wait additional time before executing during playback. You can do this by adding PauseCommands to the Array you pass to FlexMonkey.runCommands().

```
		/**
		 * Pause for the specified delay time
		 * @param delay in milliseconds
		 */ 
		public function PauseCommand(delay:int)
```

By default, !Flexmonkey pauses 5 seconds between command invocations during playback.

Here's an example of adding a pause to a script:

```
		cmdRunner.runCommands([
			new FlexCommand("inName", "SelectText", ["0", "0"], "automationName"),
			new PauseCommand(2500),
			new FlexCommand("inName", "Input", ["Fred"], "automationName")]);
	}
```


# Calling Functions from Your Script #

Sometimes you might want to execute some actionscript code between commands, for example, to test some assertions. You can insert a function call between commands with a CallCommand:

```
		/**
		 * Call a function during playback
		 * @param func the function to call
		 */ 
		public function CallCommand(func:Function)
```

Here's an example of calling a function within a script:

```
		cmdRunner.runCommands([
			new FlexCommand("inName", "SelectText", ["0", "0"], "automationName"),
			new CallCommand(checkSomething),
			new FlexCommand("inName", "Input", ["Fred"], "automationName")]);

```

# Getting help #

Check out the discussion board at http://groups.google.com/group/flexmonkey.

# Contributing to Flexmonkey #

Why don't you?