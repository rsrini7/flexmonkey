
---


**Important Note: _This document describes FlexMonkey 0.8a. To find documentation for later versions, please visit the FlexMonkey [Project Home](http://flexmonkey.gorillalogic.com#resources) site._**


---

# Getting FlexMonkey #

[Download](http://code.google.com/p/flexmonkey/downloads/list) and expand the FlexMonkey zip.

# Starting a FlexMonkey Session #

You use FlexMonkeyLauncher to record and playback FlexMonkey tests for a swf.

Copy **FlexMonkeyLauncher.swf** from the **build** directory to the directory containing the swf you want to test. _Note: FlexMonkeyLauncher.swf **must** be located in the same directory as the swf you want to test._

Open FlexMonkeyLauncher.swf in the standalone flash player.

Enter the name of the SWF you want to test in the **App to Test** field and hit the **Load SWF** button. The swf should load and be displayed beneath the flexmonkey window.

# Recording #

Click the **Record** button and play with the application. UI interactions will be recorded as commands in the **Command List**.

# Playback #

You can playback interactions by hitting the **Play** button on the **Command List** tab. You can replay selected commands by highlighting them and then hitting **Play**.

# Generating Test Code #

The **TestCase Code** tab will contain actionscript code for replaying the recorded commands from a test suite.

# Learning More About FlexMonkey #

To learn more, including creating replayable test scripts, and running from Ant, see the QuickTutorial.

# Getting More Information on the Flex Automation API #

http://www.adobe.com/devnet/flex/samples/custom_automated/