package com.gorillalogic.flexmonkey.application.utilities
{
	import com.gorillalogic.flexmonkey.application.events.RecorderEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public class ConsoleMonkeyConnection extends MonkeyConnection
	{
		public var currentRunnerEngine:MonkeyRunnerEngine;
		public var callBackArray:Array;
		
		public function ConsoleMonkeyConnection(target:IEventDispatcher=null)
		{
			super(target);
		}
		public var mateDispatcher:IEventDispatcher;
		
		//  receive methods ---------------------------------------------------------------------------	

		public function targetSWFReady(txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);
			writeConsole("BrowserConnection: Target SWF ready in Browser");
		}
		
		
		private var newUIEventTXCount:uint=0;
		
		public function newUIEvent(ba:ByteArray, txCount:uint):void{						
			sendAck(txCount);
			rxAlive = true;	
			if(newUIEventTXCount == txCount){
				return;
			}
			newUIEventTXCount=txCount;
			sendAck(txCount);
			var uiEventMonkeyCommand:UIEventMonkeyCommand = ba.readObject();
			writeConsole("BrowserConnection: New UI Event");
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_UI_EVENT,uiEventMonkeyCommand));		
		}

		public function newSnapshot(ba:ByteArray, txCount:uint):void{
			rxAlive = true;	
			sendAck(txCount);	
			var uiEventMonkeyCommand:UIEventMonkeyCommand = ba.readObject();
			writeConsole("BrowserConnection: New Snapshot");			
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_SNAPSHOT,uiEventMonkeyCommand));
		}		
		
		private var targetVOByteArray:ByteArray;
		public function newTarget(ba:ByteArray,status:String, txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);
			var o:Object;
			var f:Function;
			switch(status){
				case "single":
					writeConsole("BrowserConnection: got single");				
					o = ba.readObject();
					f = callBackArray.shift();
					f(o);
					break;
				case "start":
					writeConsole("BrowserConnection: got start");
					targetVOByteArray = new ByteArray();
					ba.readBytes(targetVOByteArray);					
					break;
				case "body":
					writeConsole("BrowserConnection: got body");
					ba.readBytes(targetVOByteArray,targetVOByteArray.length);				
					break;
				case "end":
					writeConsole("BrowserConnection: got end");
					ba.readBytes(targetVOByteArray,targetVOByteArray.length);
					o = targetVOByteArray.readObject();
					f = callBackArray.shift();
					f(o); 			
					break;
			}
		}
		 
		public function agentRunDone(ba:ByteArray, txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);			
			writeConsole("BrowserConnection: Agent Done");			
			var monkeyRunnable:MonkeyRunnable = ba.readObject();
			currentRunnerEngine.agentRunDone(monkeyRunnable);
		}				
		
	}
}