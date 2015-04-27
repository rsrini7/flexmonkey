# FlexMonkey 0.5 is Here! #

  * Enhanced support for running FlexMonkey from build systems such as Ant.
  * Easier to use FlexMonkey with FlexUnit as well as non-FlexUnit test runners.

It's available for download [here](http://code.google.com/p/flexmonkey/downloads/list).

# Why do you care? #

Many folks have requested that we separate the UI from the playback functionality so that tests can be launched from build systems like ant. With 0.5, we've pulled FlexMonkey apart into two pieces. FlexMonkey.swc, which contains the core recording and playback functionality, and FlexMonkeyUI.swc which provides the FlexMonkey window and integrated FlexUnit runner.

The core FlexMonkey.swc has no FlexUnit dependencies and should be straightforward to use for playing back FlexMonkey tests with any Flex testing framework, including those launched from Ant. The sample app includes an example for running FlexMonkey from the FlexUnit JUnitTestRunner which launches from an ant task and communicates results back to the build via a socket.

With FlexMonkey.0.5 you can easily include FlexMonkey tests with full integration testing suites.

## _Things you should know before running older FlexMonkey tests with 0.5_: ##

FlexMonkey is now broken out into two separate projects under the trunk.

  * **FlexMonkey** provides core record/playback functionality
  * **FlexMonkeyUI** provides the UI

Each of these projects produces its own swc (**FlexMonkey.swc** and **FlexMonkeyUI.swc**). Essentially, you use FlexMonkeyUI.swc when you are interactively developing and running tests using the FlexMonkey Window. Use FlexMonkey.swc to run your tests from Ant or when using a different test runner than the FlexUnit runner that's built into FlexMonkeyUI.

The API has changed slightly and is mostly compatible with pre-0.5 FlexMonkey tests. A few classes have moved out of **com.gorillalogic.flexmonkey** and into some **new packages** so you will need to change your imports for the following classes:

_FlexCommand, CallCommand, and PauseCommand_ have moved to **com.gorillalogic.flexmonkey.commands**.

_MonkeyEvent and MonkeyUtils_ have moved to **com.gorillalogic.flexmonkey.core**.

_FlexMonkey_ has moved to **com.gorillalogic.flexmonkey.ui**.

Sorry for any inconvenience. The project of course in its very early days and so we're still getting things organized! We anticipate the API being quite stable moving forward from here.

# Running FlexMonkey from Ant! #

Check out the [tutorial](RunningFromAnt.md).