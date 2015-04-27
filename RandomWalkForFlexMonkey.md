Note:  This is copied from the Adobe document Instrumenting the RandomWalk custom component for QTP.  It has been modified for FlexMonkey.

The RandomWalk component is an example of a complex custom component. It has custom events and custom item renderers. Showing how it is instrumented can be helpful in instrumenting your custom components. For example, you can instrument the RandomWalk custom component so that interaction with it can be recorded and played back by using the FlexMonkey automation tool.

You can find the source code used in this section at the following location http://flexmonkey.googlecode.com/files/FlexMonkeyRandomWalk.zip

# Instrumenting RandomWalk custom component #
The first task when instrumenting a custom component is to create a delegate and add the new component to the class definitions XML file.

  1. Create a RandomWalkDelegate class that extends UIComponentAutomationImpl, similar to RandomWalk extending the UIComponent class. The UIComponentAutomationImpl class implements the IAutomationObject interface.
  1. Mark the delegate class as a mixin with the [Mixin](Mixin.md) metadata tag; for example:
```
      package { 
          
          ...

      [Mixin]
      public class RandomWalkDelegate extends UIComponentAutomationImpl {
      }
      }
```

> This results in a call to the static init() method in the class when the SWF file loads.
  1. Add a public static init() method to the delegate class, and add the following code to it:
```
      public static init(root:DisplayObject):void {
          Automation.registerDelegateClass(RandomWalk, RandomWalkDelegate);
      }
```

  1. Add a constructor that takes a RandomWalk object as parameter. Add a call to the super constructor and pass the object as the argument:
```
      private var walker:RandomWalk
      public function RandomWalkDelegate(randomWalk:RandomWalk) {
          super(randomWalk);
          walker = randomWalk;
      }
```

  1. Update the FlexMonkeyEnv.xml file so that FlexMonkey recognizes the RandomWalk component. To do this, add the text between the `<TypeInformation>` root tags. The FlexMonkeyEnv.xml file is located in the “com/gorillalogic/aqadaptor” under the src directory of FlexMonkey. For more information about the FlexMonkeyEnv.xml file, see Using the class definitions file.
```
      	<ClassInfo Name="FlexRandomWalk" GenericTypeID="randomwalk" Extends="FlexObject" SupportsTabularData="false">
		<Implementation Class="RandomWalk"/>
       	<Methods>
            <Method Name="Select" >
                <Implementation Type="Select"/>
            </Method>
        </Methods>
		<Events>
			<Event Name="Select">
				<Implementation Class="randomWalkClasses::RandomWalkEvent" Type="itemClick"/>
				<Property Name="itemRenderer">
					<PropertyType Type="String" Codec="automationObject"/>
				</Property>
			</Event>
		</Events>
		<Properties>
			<Property Name="automationClassName" ForDescription="true">
				<PropertyType Type="String"/>
			</Property>
			<Property Name="automationName" ForDescription="true">
				<PropertyType Type="String"/>
			</Property>
			<Property Name="className" ForDescription="true">
				<PropertyType Type="String"/>
			</Property>
			<Property Name="id" ForDescription="true" ForVerification="true">
				<PropertyType Type="String"/>
			</Property>
			<Property Name="automationIndex" ForDescription="true">
				<PropertyType Type="String"/>
			</Property>
			<Property Name="openChildrenCount" ForVerification="true" ForDefaultVerification="true">
				<PropertyType Type="Integer"/>
			</Property>
		</Properties>
	</ClassInfo>
```
This defines the name of the FlexRandomWalk component and its implementing class. It specifies the automationClassName, automationName, className, id and automationIndex properties as available for identifying an instance of the RandomWalk class in the Flex application. This is possible because the RandomWalk class is derived from the UIComponent class, and these properties are defined on that parent class.

If your component has a property that you can use to differentiate between component instances, you can also add that property. For example, the label property of a Button control, though not unique when the whole application is considered, can be assumed to be unique within a container; therefore, you can use it as an identification property.

# Instrumenting RandomWalk Events #
The next step in instrumenting a custom component is to identify the important events that must be recorded by FlexMonkey. The RandomWalk component dispatches a RandomWalkEvent.ITEM\_CLICK event. Because this event indicates user navigation, it is important and must be recorded.
## Instrument the ITEM\_CLICK event ##
  1. Add an event listener for the event in the RandomWalkDelegate constructor:
```
      randomWalk.addEventListener(RandomWalkEvent.ITEM_CLICK, itemClickHandler)
```

  1. Identify the event in the FlexMonkeyEnv.xml file so that FlexMonkey recognizes the event. Add the following text in the `<Events>` tag in the FlexMonkeyEnv.xml file:
```
      <Event Name="Select" PropertyType="Method" >
          <Implementation Class="randomWalkClasses::RandomWalkEvent"
              Type="itemClick"/>
      </Event>
```
> > Adding this block to the FlexMonkeyEnv.xml file names the event as Select and indicates that it is tied to the RandomWalkEvent class, which is available in the randomWalkClasses namespace. It also defines the event of type itemClick.

When using the RandomWalk component, users click on items to expand them. The component records the item label so you can easily recognize their action in the FlexMonkey.

The RandomWalkEvent class has only a single property, item, that stores the XML node information. In the RandomWalk component's implementation, the RandomWalkRenderer item renderer is used to display the data on the screen. This class is derived from the Label control, which is already instrumented. The Label control returns the label text as its automationName, which is what you want to record.

Record the label text

  1. Add a new property, itemRenderer, to the RandomWalkEvent class.
  1. Add the code to initialize this property for the event before dispatching the event; for example:
```
      var rEvent:RandomWalkEvent = new RandomWalkEvent(RandomWalkEvent.ITEM_CLICK,node);
      rEvent.itemRenderer = child as Label;
      dispatchEvent(rEvent);
```

  1. Add the new itemRenderer property as an argument to the Select operation in the FlexMonkeyEnv.xml file:
```
      <Event Name="Select" >
          <Implementation Class="randomWalkClasses::RandomWalkEvent"
              Type="itemClick"/>
          <Property Name="itemRenderer" IsMandatory="true" >
              <PropertyType Type="String" Codec="automationObject"/>
		  </Property>
      </Event>
```
> > This code block specifies the type of argument as String and the codec as automationObject. The Codec property is an optional attribute of the `<PropertyType>` tag in the `<Event>` and `<Property>` tags. It defines a class that converts ActionScript types to agent-specific types.
  1. In the event handler, call the recordAutomatableEvent() method with event as the parameter, as the following example shows:
```
      private function itemClickHandler(event:RandomWalkEvent):void {
          recordAutomatableEvent(event);
      }
```

In some cases, the component does not dispatch any events or the event that was dispatched does not have the information that is required during the recording or playing back of the test script. In these circumstances, you must create an event class with the required properties. In the component, you create an instance of the event and pass it as a parameter to the recordAutomatableEvent() method.

For example, the ListItemSelect event has been added in automation code and is used by the List automation delegate to record and play back select operations for list items.

To locate the item renderer object, the automation classes require some help. Copy the standard implementation for the following methods.  Be sure to replace component in both helper calls with the reference to the component:
```
override public function createAutomationIDPart(child:IAutomationObject):Object {
    var help:IAutomationObjectHelper = Automation.automationObjectHelper;
    return help.helpCreateIDPart(component, child); 
}

override public function resolveAutomationIDPart(part:Object):Array {
    var help:IAutomationObjectHelper = Automation.automationObjectHelper; 
    return help.helpResolveIDPart(component, part as AutomationIDPart);
} 
```

# Preparing RandomWalk For Playback #
Flex components display the data in a data provider after processing and formatting the data. Playback code requires a way to trace back the visual data to the data provider and the component displaying that data. For example, from the visual label of an item in the List, playback code should be able to find the item renderer that shows the element so that the item's click can be played back.

When playing back a RandomWalkEvent event, you must identify the item renderer with the automationName given. Because the RandomWalk component has many item renderers that are children that are derived from UIComponent subclasses, you must identify them by using the automationName property.

The IAutomationObject interface already has APIs to support this. The UIComponentAutomationImpl interface provides default implementations for some methods, but you must override some methods to return information that is specific to the RandomWalk component.

  1. Instruct FlexMonkey as to how many renderers are being used by the instance of the RandomWalk component. RandomWalk uses an array of arrays for all the renderers. Add the following code in RandomWalkDelegate class to find the total number of instances:
```
      override public function get numAutomationChildren():int {
          var numChildren:int = 0;
          var renderers:Array = walker.getItemRenderers();
          for (var i:int = 0;i< renderers.length;i++) {
              numChildren += renderers[i].length;
          }
          return numChildren;
      }
```

  1. Access the itemRenderers property in the delegate class; this property, however, is private. As a result, you must add the following accessor method to the RandomWalk component:
```
      public function getItemRenderers():Array {
          return _renderers;
      }
```

> Alternatively, you can make the property public or change its namespace.

  1. FlexMonkey requests each child renderer. Add the following code to determine the exact renderer and return it:
```
      override public function getAutomationChildAt(index:int):IAutomationObject {
          var numChildren:int = 0;
          var renderers:Array = walker.getItemRenderers();
          for(var i:int = 0; i < renderers.length; i++) {
              if(index >= numChildren) {
                  if(i+1 < renderers.length && (numChildren + renderers[i].length)
                      <= index) {
                      numChildren += renderers[i].length;
                      continue;
                  }
                  var subIndex:int = index - numChildren;
                  var instances:Array = renderers[i];
                  return (instances[subIndex] as IAutomationObject);
              }
          }
          return null;
      }
```