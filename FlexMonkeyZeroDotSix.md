# FlexMonkey 0.6 is Here! #

FlexMonkey 0.6 lets you test application swfs without first recompiling them with the flexmonkey and flex automation libraries. In fact, you can package your flexunit tests in their own separate swf, so all test code can be physically isolated from your actual application.

# Why do you care? #

The swf you test and the one you deploy can now be the same swf. There is no longer a need to compile your application for testing, run your tests, and then recompile your application without the test code and framework libraries prior to deployment. You can even run tests against deployed applications. (You might do this for example to confirm the integrity of a live system.)

# Differences from 0.5 #

  * You now use **FlexMonkeyLauncher.swf** to launch your application for testing as well as to launch separate swfs containing your tests. The FlexMonkeyLauncher opens the FlexMonkey window, which now contains a **Setup** tab where you can tell it the name of the swf you want to launch for testing, and optionally, the swf to launch that contains previously recorded test scripts.

  * When running from ant, you create a wrapper html file that starts the launcher and uses flashvars to pass it the name of the application swf, and the name of the swf containing your tests. You supply this html file to the flexunit ant task.

  * In order to package your tests within their own swf, you create a wrapper application that registers your tests with either flexmonkey's built-in flexunit instance or, if you're running from ant, with JunitTestRunner.

  * Static initialization via the Mixin metatag is no longer necessary.

  * FlexMonkeyUI.swc has been eliminated.

# How do you get started? #

See GettingStarted and the new UserGuide.