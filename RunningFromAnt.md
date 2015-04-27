
---


**Important Note: _This document describes FlexMonkey 0.8a. To find documentation for later versions, please visit the FlexMonkey [Project Home](http://flexmonkey.gorillalogic.com#resources) site and see the FlexMonkey Code Generation Guide._**


---


# Running FlexMonkey tests from Ant #

Before getting started, please review the QuickTutorial.

In this tutorial, we'll walk through setting up and running FlexMonkey tests to run from [Ant](http://ant.apache.org/). In this tutorial, we'll be running FlexMonkey using FlexUnit ant tasks to run FlexUnit TestCases, but the process should be analogous for non-FlexUnit based test runners, and non-Ant-based build systems.

This tutorial assumes you already know Ant. The sample application included with the FlexMonkey [http://code.google.com/p/flexmonkey/downloads/list](download.md) includes this tutorial's example code.

## Overview ##

To run our FlexMonkey tests from Ant, we'll use the **flexunit ant task**, which launches a Flex application and listens on a socket for for test results reported back from the launched application. (Learn [more](http://weblogs.macromedia.com/pmartin/archives/2007/01/flexunit_for_an_1.html)).

We'll use the !JUnitTestRunner to run our FlexUnit tests. Although it sounds like a Java thing, !JUnitTestRunner is actionscript-based and provides an altnerative to FlexUnit's gui-based runner. Rather than display results in a window, !JUnitTestRunner sends them over a socket connection back to the initiating flexunit ant task, which writes them to a directory. The results are formatted using !JUnit's standard XML reporting format which means you can use the [junitreport task](http://ant.apache.org/manual/OptionalTasks/junitreport.html) to merge your FlexUnit test results with your !JUnit results in a single hyperlinked report.

## Install the flexunit ant task ##

Download [FlexAntTasks-bin.zip](http://weblogs.macromedia.com/pmartin/archives/2007/01/flexunit_for_an_1.html), extract FlexAntTasks.jar, and copy it somewhere in Ant's classpath (Learn [more](http://ant.apache.org/manual/running.html#libs)).

## Install JUnitTestRunner ##

Download [FlexUnitOptional-bin.zip](http://weblogs.macromedia.com/pmartin/archives/2007/01/flexunit_for_an_1.html), extract FlexUnitOptional.swc and include it in the build path of the swf containing your tests, which in our example is **FlexMonkeyTests.swf** located in the build directory.

## Create your Test SWF ##

The only difference between running your tests using FlexMonkey's built-in FlexUnit runner, and running with !JUnitTestRunner instead, is the way in which you add your test suite to the runner and how you kick off the tests. Our wrapper, FlexMonkeyTests.mxml would look like this in order to run tests from ant instead of from the built-in runner:

```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" creationComplete="create()">
        <mx:Script>
                <![CDATA[
                        import test.FlexUnitTests;
                        import com.gorillalogic.flexmonkey.ui.FlexMonkey;
                        public function create():void {
		           var	antRunner:JUnitTestRunner = new JUnitTestRunner();
		           antRunner.run(new TestSuite(FlexUnitTests)); 
                        }
                ]]>
        </mx:Script>
</mx:Application>
```



To communicate with the flexunit ant task, we must create a !JUnitTestRunner instance, and invoke its run method, passing it our **FlexUnitTests** test suite.

```
		           var	antRunner:JUnitTestRunner = new JUnitTestRunner();
		           antRunner.run(new TestSuite(FlexUnitTests), function():void {
                  	     fscommand("quit");
         		   }); 
```



## Create the ant script ##

We launch our tests with the following ant target. Note that you need to include a taskdef for flexunit.

```

 <!-- Load the flexunit task definitions. -->
 <taskdef resource="com/adobe/ac/ant/tasks/tasks.properties" />

 <target name="test" depends="compile">						
	<flexunit
		
		timeout="0"
		verbose="true"
		swf="MonkeyContactsTest.html"
		toDir="${report.dir}"
		haltonfailure="false" />	
	
	<junitreport todir="${report.dir}">
	  <fileset dir="${report.dir}">
	     <include name="TEST-*.xml"/>
	  </fileset>
			
	  <report format="frames" todir="${report.dir}/flex"/>
		
	</junitreport>	
 </target>
	
```


The **swf** parameter actually references our html wrapper, MonkeyContactsTest.html, rather than the swf itself.

If you get an error finding com/adobe/ac/ant/tasks/tasks.properties, you can specify its location explicitly instead:

```
 <taskdef resource="com/adobe/ac/ant/tasks/tasks.properties" classpath="/path/to/FlexAntTasks.jar">
```

## View the results ##

The [junitreport](http://ant.apache.org/manual/OptionalTasks/junitreport.html) task formats our test results in exactly the same way it formats junit results.

## Testing apps residing on a server ##

If our test app resides on a server, we simply specify the full url, for example, http://localhost:8080/myapp/MonkeyContactsTest.html.

```

 <!-- Load the flexunit task definitions. -->
 <taskdef resource="com/adobe/ac/ant/tasks/tasks.properties" />

 <target name="test" depends="compile">						
	<flexunit
		
		timeout="0"
		verbose="true"
		swf="http://localhost:8080/myapp/MonkeyContactsTest.html"
		toDir="${report.dir}"
		haltonfailure="false" />	
	
	<junitreport todir="${report.dir}">
	  <fileset dir="${report.dir}">
	     <include name="TEST-*.xml"/>
	  </fileset>
			
	  <report format="frames" todir="${report.dir}/flex"/>
		
	</junitreport>	
 </target>
	
```

And again, remember that FlexMonkeyLauncher.swf and our test swf (FlexMonkeyTests.swf) need to be located on the server in the same directory as the app we're testing (MonkeyContacts.swf).

# Running Build.xml in the Example #

Copy build.properties.template to a new file called build.properties and update **flex.home** and **flex.ant.loc** to point to your local installation locations. Edit **FlexMonkeyTests.mxml** and uncomment the following lines:
```
		           var	antRunner:JUnitTestRunner = new JUnitTestRunner();
		           antRunner.run(new TestSuite(FlexUnitTests), function():void {
                  	     fscommand("quit");
         		   }); 
```

The default ant target will build MonkeyContacts.swf and FlexMonkeyTests.swf, run the tests, and write the results to the **reports** directory.