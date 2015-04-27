

In order for FlexMonkey to record the activities of a component, the component and its associated events must be defined in FlexMonkey class definition file FlexMonkeyEnv.xml.   For instructions on adding events, see Instrumenting Events.  Not all components and/or events for components are defined in this file as the file was created by Adobe for the AutoQuick sample.

If you extend Flex components that are already defined in FlexMonkeyEnv.xml, then you do not have to change anything to ensure FlexMonkey records the component and events.  If the extended component is not defined in FlexMonkeyEnv.xml, then you will need to follow the instructions in Instrumenting Components.

You can also create your own custom components, but you will need to add them to FlexMonkeyEnv.xml and create a delegate class to handle the automation.  Instructions for custom components can be found in Instrumenting Custom Components.

# Instrumenting Events #

Before you add an event to a component, make sure the event is not already defined in the component hierarchy within the class definition.  See FlexMonkey Class Definition

Events have different levels of relevance. For example, you are probably interested in recording and playing back a click event on a Button control, but not interested in recording all the events that occur when a user clicks the Button, such as the mouseOver, mouseDown, mouseUp, and mouseOut events. For this reason, when you click on a Button, FlexMonkey only records and plays back the click event for the Button and not the other events.

There are some circumstances where you would want to record events that are normally ignored by FlexMonkey. The FlexMonkey object model only records events that represent the end-user's gesture (such as a click or a drag and drop). This makes a script more readable and it also makes the script robust enough so that it does not fail if you change the application slightly. So, you should carefully consider whether you add a new event to be tested or you can rely on events in the existing object model.

You can see a list of events that FlexMonkey can record for each Flex component in the FlexMonkeyEnv.xml file. The Button, for example, supports the following operations:

  * ChangeFocus
  * Click
  * MouseMove
  * SetFocus
  * Type

All of these events are defined in the FlexMonkey class definition, but MouseMove is not automatically recorded by FlexMonkey by default. This is because the Button delegate does not  record the MouseMove events.

However, you can alter the behavior of your application so the MouseMove event is recorded by FlexMonkey. To add a new event to be tested, you override the replayAutomatableEvent() method of the IAutomationObject interface. Because UIComponent implements this interface, all subclasses of UIComponent (which include all visible Flex controls) can override this method. To override the replayAutomatableEvent() method, you create a custom class, and override the method in that class.

The replayAutomatableEvent() method has the following signature:

public function replayAutomatableEvent(event:Event):Boolean


The event argument is the Event object that is being dispatched. In general, you pass the Event object that triggered the event. Where possible, you pass the specific event, such as a MouseEvent, rather than the generic Event object.

The following example shows a custom Button control that overrides the replayAutomatableEvent() method. This method checks for the MouseMove event and calls the replayMouseEvent() method if it finds that event. Otherwise, it calls its superclass' replayAutomatableEvent() method.

```
<?xml version="1.0" encoding="utf-8"?>
<!-- at/CustomButton.mxml -->
<mx:Button xmlns:mx="http://www.adobe.com/2006/mxml">
        <mx:Script>
        <![CDATA[
            import flash.events.Event;
            import flash.events.MouseEvent;
            import mx.automation.Automation;
            import mx.automation.IAutomationObjectHelper;

            override public function 
                replayAutomatableEvent(event:Event):Boolean {

                trace('in replayAutomatableEvent()');

                var help:IAutomationObjectHelper = 
                    Automation.automationObjectHelper;
        
                if (event is MouseEvent && 
                    event.type == MouseEvent.MOUSE_MOVE) {
                    return help.replayMouseEvent(this, MouseEvent(event));
                } else {
                    return super.replayAutomatableEvent(event);                
                }
            }
        ]]>
    </mx:Script>
</mx:Button>
```
In the application, you call the AutomationManager's recordAutomatableEvent() method when the user moves the mouse over the button. The following application uses this custom class:
```
<?xml version="1.0" encoding="utf-8"?>
<!-- at/ButtonApp.mxml -->
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" xmlns:ns1="*" initialize="doInit()">
    <mx:Script>
    <![CDATA[
        import mx.automation.*;

        public function doInit():void {             
            b1.addEventListener(MouseEvent.MOUSE_MOVE, 
                dispatchLowLevelEvent);
        }

        public function dispatchLowLevelEvent(e:MouseEvent):void {
            var help:IAutomationManager = Automation.automationManager;
            help.recordAutomatableEvent(b1,e,false);
        }
    ]]>
    </mx:Script>

    <ns1:CustomButton id="b1" 
        toolTip="Mouse moved over" 
        label="CustomButton"
    />
    
</mx:Application>
```
If the event is not one that is currently recordable, you also must define the new event for the agent. The class definitions are in the FlexMonkeyEnv.xml file. FlexMonkey uses this file to define the events, properties, and arguments for each class of test object. For more information, see Instrumenting Events.  For example, if you wanted to add support for the mouseOver event, you would add the following to the FlexButton's entry in the FlexMonkeyEnv.xml file:
```
<Event Name="MouseOver" PropertyType="Method" >
    <Implementation Class="flash.events::MouseEvent" Type="mouseOver"/>
        <Property Name="keyModifier" IsMandatory="false" DefaultValue="0">
            <PropertyType Type="Enumeration"
                ListOfValuesName="FlexKeyModifierValues" 
                Codec="keyModifier"
            />
        </Property>
</Event>
```
In our example on MouseMove, the MouseMove events are already defined in FlexMonkeyEnv.xml, so all you have to do is compile this application. FlexMonkey will record the mouseMove event for all of the CustomButton objects.

For more information on using a class definitions file, see FlexMonkey Class Definition.

# Instrumenting Components #
The current FlexMonkeyEnv.xml file does not cover every component. It was originally created by Adobe for the AutoQuick sample.  If you find a component that is not recording, such as AdvancedDataGrid, then you will need to first check to make sure the component has an automation delegate.  The standard Adobe delegate is named class name plus AutomationImpl, so the delegate for AdvancedDataGrid is AdvancedDataGridAutomationImpl.  Once you verify the delegate, you will need to add the component to the FlexMonkeyEnv.xml file.  See FlexMonkey Class Definition for the layout of the file.

If your component does not have a delegate, then you will need to create a delegate as well as adding it to the FlexMonkeyEnv.xml.  See CreateDelegate for instructions on writing the delegate for the component.

If you add a component to the FlexMonkeyEnv.xml, please share the work with the rest of the FlexMonkey community.

## Custom Components ##
The delegate class is a separate class that is not embedded in the component code. This helps to reduce the component class size and also keeps automated testing code out of the final production SWF file. All Flex controls have their own delegate classes. These classes are in the mx.automation.delegates.`*` package. The class names follow a pattern of ClassnameAutomationImpl. For example, the delegate class for a Button control is mx.automation.delegates.controls.ButtonAutomationImpl.
  1. Create a delegate class.
  1. Mark the delegate class as a mixin by using the [Mixin](Mixin.md) metadata keyword.
  1. Register the delegate with the AutomationManager by calling the Automation.registerDelegateClass() method in the init() method. The following code is a simple example:
```
      [Mixin]
      public class MyCompDelegate {
      	public static init(root:DisplayObject):void {
      		// Pass the component and delegate class information.
      		Automation.registerDelegateClass(MyComp, MyCompDelegate);
      	}
      }
```

> You pass the custom class and the delegate class to the registerDelegateClass() method.
  1. Add the following code to your delegate class:
    1. Override the getter for the automationName property and define its value. This is the name of the object as it usually appears in the Property column of the FlexMonkey command list. If you are defining an item renderer, use the automationValue property instead.
    1. Override the getter for the automationValue property and define its value. This is the value of the object in the Value column of the FlexMonkey command tab.
    1. In the constructor, add event listeners for events that the automation tool records.
    1. Override the replayAutomatableEvent() method. The AutomationManager calls this method for replaying events. In this method, return whether the replay was successful. You can use methods of the helper classes to replay common events.

> For examples of delegates, see the source code for the Flex controls in the mx.automation.delegates.`*` packages.

  1. Link the delegate class with the application SWF file.


For an example that shows how to create a custom component, see RandomWalk custom component for FlexMonkey.

# FlexMonkey Class Definition #
The structure for the FlexMonkeyEnv file is defined below.  You will need to have a good understanding of this file before you modify it for events and/or components.
```
<ClassInfo Name=”” Extends=””>
	<Implementation Class=””/>
	<Events>
		<Event Name=””>
			<Implementation Class=””/>
			<Property>
				<PropertyType Type=”” />
			</Property>
		</Event>
	</Events>
	<Properties>
	</Properties>
</ClassInfo>
```

|**Tag** | **Description**|
|:-------|:|
| ClassInfo | Defines the name of the component that is to be recorded, for example FlexButton.  Attributes for this tag include Name and Extends. |
| Implementation | Defines the class name as it is known by the compiler, for example mx.controls;;Button.  Attributes for this tag include Class, Type.  This tag is used for defining both component classes as well as event classes.|
| Event | Defines the event that will be recorded.  Attributes for this tag include Name, which is the event name. |
| Property | Defines a property of either an event or component. The Property tag identifies properties of the class that can be used to uniquely identify the component.|

Button sample definition.
```
<ClassInfo Name="FlexButton" Extends="FlexObject">
        <Implementation Class="mx.controls::Button"/>
        <Events>
            <Event Name="Type" >
                <Implementation Class="flash.events::KeyboardEvent" Type="keyPress"/>
                <Property Name="keyCode" >
<PropertyType Type="String" Codec="keyCode" DefaultValue="SPACE"/>                         </Property>
                <Property Name="keyModifier"  DefaultValue="0">
                    <PropertyType Type="Enumeration" ListOfValuesName="FlexKeyModifierValues" Codec="keyModifier"/>
                </Property>
            </Event>
        </Events>

        <Properties>
            <Property Name="enabled" ForDefaultVerification="true" ForVerification="true">
<PropertyType Type="Boolean"/>
</Property>
            <Property Name="label" ForDefaultVerification="true" ForDescription="true" ForVerification="true">
<PropertyType Type="String"/>
</Property>
 Some Property removed for breviety.    
        </Properties>
</ClassInfo>
```