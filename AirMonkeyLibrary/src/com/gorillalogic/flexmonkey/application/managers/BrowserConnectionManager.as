package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.VOs.FlashVarVO;
	import com.gorillalogic.flexmonkey.application.VOs.ProjectPropertiesVO;
	import com.gorillalogic.flexmonkey.application.utilities.MonkeyConnectionManifold;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;	
	
	public class BrowserConnectionManager //extends monkeyConnectionManifold
	{
		private var monkeyConnectionManifold:MonkeyConnectionManifold;

		[Bindable] public var mateDispatcher : IEventDispatcher;					
		[Bindable] public var connected:Boolean;

		static private var _browserConnection:BrowserConnectionManager;
		static public function get browserConnection():BrowserConnectionManager{
			return _browserConnection;
		}
		static public function setClassReference(b:BrowserConnectionManager):void{
			_browserConnection = b;		
		}	
		public function setSingleton():void{
			BrowserConnectionManager.setClassReference(this);
		}

		private var _commMode:String;
		public function get commMode():String{
			return _commMode;
		}
		public function set commMode(m:String):void{
			_commMode = m;
			switch(m){	
				case ProjectPropertiesVO.TARGET_SWF_WINDOW:
					setUseBrowser(false);
					break;
				case ProjectPropertiesVO.MONKEYAGENT:
					setUseBrowser(true);
					if(targetSWFURL != "" && targetSWFURL != null){
						monkeyConnectionManifold.pingTXTimerStart();
					}else{
						monkeyConnectionManifold.setConnected(false);
						monkeyConnectionManifold.pingTXTimerStop();				
					}					
					break;
				case ProjectPropertiesVO.MONKEYLINK:
					setUseBrowser(true);
					monkeyConnectionManifold.pingTXTimerStart();
					break;
			}
		}

/*
		private var _useTargetSWFWindow:Boolean = false;
		public function get useTargetSWFWindow():Boolean{
			return _useTargetSWFWindow;
		}
		public function set useTargetSWFWindow(u:Boolean):void{
			_useTargetSWFWindow = u;
			setUseBrowser(!u);
			if((!u) && targetSWFURL != "" && targetSWFURL != null){
				pingTXTimer.start();
			}else{
				setConnected(false);
				pingTXTimer.stop();				
			}	
		}
*/
		
		private var _useBrowser:Boolean=false;
		public function get useBrowser():Boolean{
			return _useBrowser;
		}
		private function setUseBrowser(u:Boolean):void{
			_useBrowser = u;
		}
		
		public function needInit(txCount:uint):void{
			monkeyConnectionManifold.sendAck(txCount);
			initAgent();
		}
		
		public function disconnect():void{
			agentInitialized = false;
			monkeyConnectionManifold.disconnect();
		}		
		
		public function sendDisconnect():void{
			monkeyConnectionManifold.sendDisconnect();
			agentInitialized = false;
		}
		
		public function BrowserConnectionManager()
		{
			monkeyConnectionManifold = new MonkeyConnectionManifold()
			monkeyConnectionManifold.writeConsole = function(message:String):void{
				trace(message);
			}
			
//			monkeyConnectionManifold.txChannelName = "_agent";
//			monkeyConnectionManifold.rxChannelName = "_flexMonkey";
			monkeyConnectionManifold.setChannelNames([
				{consoleChannelName:"_console1", linkChannelName:"_swf1"},
				{consoleChannelName:"_console2", linkChannelName:"_swf2"}			
			]);
		
			BindingUtils.bindProperty(this, "connected", monkeyConnectionManifold, "connected");
			BindingUtils.bindProperty(monkeyConnectionManifold,"mateDispatcher", this, "mateDispatcher");
			BindingUtils.bindProperty(monkeyConnectionManifold,"currentRunnerEngine", this, "currentRunnerEngine");
			BindingUtils.bindProperty(monkeyConnectionManifold,"callBackArray", this, "callBackArray");
			agentInitialized = false;
			monkeyConnectionManifold.startConnection();
		}


			
		// send methods ---------------------------------------------------------------------------	

		private var recordingActive:Boolean = false;			

		private var _targetSWFURL:String;
		public function get targetSWFURL():String{
			return _targetSWFURL;
		}
		public function set targetSWFURL(url:String):void{
			_targetSWFURL = url;
			if(useBrowser && targetSWFURL != "" && targetSWFURL != null){
				monkeyConnectionManifold.pingTXTimerStart();				
			}
		}

		private var _targetSWFWidth:uint;
		public function get targetSWFWidth():uint{
			return _targetSWFWidth;
		}
		public function set targetSWFWidth(w:uint):void{
			_targetSWFWidth = w;
			if(agentInitialized){
				monkeyConnectionManifold.send(new TXVO("_agent", "setTargetSWFWidth", [w]));	
			}
		}

		private var _targetSWFHeight:uint;
		public function get targetSWFHeight():uint{
			return _targetSWFHeight;
		}
		public function set targetSWFHeight(h:uint):void{
			_targetSWFHeight = h;
			if(agentInitialized){
				monkeyConnectionManifold.send(new TXVO("_agent", "setTargetSWFHeight", [h]));
			}
		}

		private var _flashVars:ArrayCollection;
		public function get flashVars():ArrayCollection{
			return _flashVars;
		}
		public function set flashVars(fv:ArrayCollection):void{
			_flashVars = fv;
		}

		private var agentInitialized:Boolean = false;
		private function initAgent():void{
			for each(var flashVar:FlashVarVO in flashVars){
				monkeyConnectionManifold.send(new TXVO("_agent", "setFlashVar", [flashVar.name, flashVar.value]));	
			}				
			monkeyConnectionManifold.send(new TXVO("_agent", "setTargetSWFWidth", [targetSWFWidth]));
			monkeyConnectionManifold.send(new TXVO("_agent", "setTargetSWFHeight", [targetSWFHeight]));
			monkeyConnectionManifold.send(new TXVO("_agent", "setTargetSWFURL", [targetSWFURL]));
			agentInitialized = true;				
		}
	
		public function startRecording():void{
			monkeyConnectionManifold.send(new TXVO("_agent", "startRecording"));
			recordingActive = true;		
		}
		public function stopRecording():void{
			monkeyConnectionManifold.send(new TXVO("_agent", "stopRecording"));
			recordingActive = false;		
		}	
		public function takeSnapshot():void{
			monkeyConnectionManifold.send(new TXVO("_agent", "takeSnapshot"));
		}
		public function clearSnapshot():void{
			monkeyConnectionManifold.send(new TXVO("_agent", "clearSnapshot"));
		}
		
		
// ========================		
		
	
		
		[Bindable] public var currentRunnerEngine:MonkeyRunnerEngine;
		public function runCommand(c:UIEventMonkeyCommand,e:MonkeyRunnerEngine):void{
			currentRunnerEngine = e;
			var clone:UIEventMonkeyCommand = c.clone();
			clone.parent = null;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(clone);
			monkeyConnectionManifold.writeConsole("BrowserConnection: runCommand length: " + ba.length);			
			monkeyConnectionManifold.send(new TXVO(clone.channelName, "runCommand", [ba]));
		}
				
		[Bindable] public var callBackArray:Array = [];
		public function getTarget(verifyMonkeyCommand:VerifyMonkeyCommand,callBack:Function):void{
			callBackArray.push(callBack);
			var ba:ByteArray = new ByteArray();
			var clone:VerifyMonkeyCommand = verifyMonkeyCommand.clone();
			clone.parent = null;
			ba.writeObject(clone);

			ba.position = 0;
			var bufferSize:uint = 40000;
			
			if(ba.bytesAvailable < bufferSize){
				monkeyConnectionManifold.send(new TXVO(clone.channelName, "getTarget", [ba, "single"]));
				monkeyConnectionManifold.writeConsole("BrowserConnection: sent single");				
			}else{				
				var buffer:ByteArray = new ByteArray();
				ba.readBytes(buffer,0,bufferSize);
				monkeyConnectionManifold.send(new TXVO(clone.channelName, "getTarget", [buffer, "start"]));
				monkeyConnectionManifold.writeConsole("BrowserConnection: sent start");								
				while(ba.bytesAvailable >= bufferSize){
					buffer = new ByteArray();
					ba.readBytes(buffer,0,bufferSize);
					monkeyConnectionManifold.send(new TXVO(clone.channelName, "getTarget", [buffer, "body"]));
					monkeyConnectionManifold.writeConsole("BrowserConnection: sent body");													
				}
				if(ba.bytesAvailable > 0){
					buffer = new ByteArray();
					ba.readBytes(buffer);
					monkeyConnectionManifold.send(new TXVO(clone.channelName, "getTarget", [buffer, "end"]));
					monkeyConnectionManifold.writeConsole("BrowserConnection: sent end");																		
				}
			}			
		}	
		
		
// ========================		
		
					
	}
}