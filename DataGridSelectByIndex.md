# Introduction #

The default selection mode for the DataGrid in FlexMonkey records the data for each field in the selected row and uses this data to playback the selection.  With two changes to the FlexMonkeyEnv.xml file, you can have the monkey record the index of the selected row instead.


# Details #

When recording, the ListBaseAutomationImpl.as delegate class looks in the AutomationManager.automationEnvironment to see if its propertyNameMap defines the property "enableIndexBasedSelection".  If the delegate finds the property to be defined, it sets its selectionType to ListItemSelectEvent.SELECT\_INDEX instead of the default ListItemSelectEvent.SELECT.

So, to have the monkey record DataGrid selections by index, follow these steps for editing FlexMonkeyEnv.xml:

1) Locate the
```
   <ClassInfo Name="FlexListBase" Extends="FlexScrollBase">
                <Implementation Class="mx.controls.listClasses::ListBase"/>`
```
entry in the env file.

2) In the `<Events>` section of this entry, add a new `<Event>` definition for the "SelectIndex" event:
```
<Event  Name="SelectIndex" >
    <Implementation Class="mx.automation.events::ListItemSelectEvent" Type="selectIndex"/>
    <Property Name="itemIndex" >
      <PropertyType Type="int" />                   
    </Property>    
    <Property Name="triggerEvent"  DefaultValue="1">
      <PropertyType Type="Enumeration" ListOfValuesName="FlexTriggerEventValues" Codec="event"/>                   
    </Property>
    <Property Name="keyModifier"  DefaultValue="0">
        <PropertyType Type="Enumeration" ListOfValuesName="FlexKeyModifierValues" Codec="keyModifier"/>
    </Property>
</Event>     
```

3) In the `<Properties>` section, add a new `<Property>` definition for "enableIndexBasedSelection""
```
<Property Name="enableIndexBasedSelection" ForVerification="true"><PropertyType Type="Boolean"/></Property>  
```

4) recompile the library with the modified env file.