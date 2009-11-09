package com.gorillalogic.flexmonkey.application.utilities
{
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.BindingUtils;

/*


1) when the comm mode is LINK, the browser calls the pingTXTimerStart
		-- which would mean start all the connections TXTImers
2) needInit -- ???
2A) initAgent sets the 
3) when the manifold is set up, the browserConnectionManager sets the ChannelNames
4) the BrowsersConnections' "connected" is driven-boundwise from the manifold
5) the BrowserConnectionManager's constructor call's the manifold 'startConnection'
5A) the bC tells the manifold to disconnect, and calls sendDisconnect() 
			-- which means ???
6) the browserConnection tells the manifold to StartRecording, stopRecording
		-- which means tell all the connectors
7) the bC tells teh manifold to take a snapshot,
		-- which means tell all the connectors that a snapshot is comming
		
MonkeyLink should insert the id when recording...		

When the manifold sets up an individual connection, it needs to set the tx and 
rx ChannelNames before it calls that connection's startConnection


*/	
	public class MonkeyConnectionManifold
	{
		[Bindable] public var mateDispatcher : IEventDispatcher;	
		[Bindable] public var callBackArray:Array;
		[Bindable] public var currentRunnerEngine:MonkeyRunnerEngine;	
				
		private var _connected:Boolean = true;
		[Bindable] 
		public function get connected():Boolean{
			return _connected;
		}
		public function set connected(c:Boolean):void{
			_connected = c;
		}
		
		private var _writeConsole:Function;
		[Bindable]
		public function get writeConsole():Function{
			return _writeConsole;
		}
		public function set writeConsole(f:Function):void{
			_writeConsole = f;
		}
		
		public function MonkeyConnectionManifold()
		{
		}
		
		public function setConnected(s:Boolean):void{
			for each(var connection:MonkeyConnection in _connections){
				connection.setConnected(s);
			}			
		}

		public function pingTXTimerStart():void{
			for each(var connection:MonkeyConnection in _connections){
				connection.pingTXTimer.start();
			}			
		}
		
		public function pingTXTimerStop():void{
			for each(var connection:MonkeyConnection in _connections){
				connection.pingTXTimer.stop();
			}			
		}

		public function sendAck(txCount:uint):void{
//TODO this must be wrong
			for each(var connection:MonkeyConnection in _connections){
				connection.sendAck(txCount);
			}			
		}	
		
		public function disconnect():void{	
			for each(var connection:MonkeyConnection in _connections){
				connection.disconnect();
			}			
		}
		
		public function sendDisconnect():void{
			for each(var connection:MonkeyConnection in _connections){
				connection.sendDisconnect();
			}			
		}
		
		private var _connections:Array = [];
		private var _channelNames:Array = [];
		public function setChannelNames(names:Array):void{
			_channelNames = names;
			_connections = [];
			for each(var channel:Object in names){
				var connection:ConsoleMonkeyConnection = new ConsoleMonkeyConnection();
				connection.txChannelName = channel.linkChannelName;
				connection.rxChannelName = channel.consoleChannelName;	
				connection.writeConsole = this.writeConsole;
				BindingUtils.bindProperty(connection,"mateDispatcher", this, "mateDispatcher");
				BindingUtils.bindProperty(connection,"currentRunnerEngine", this, "currentRunnerEngine");
				BindingUtils.bindProperty(connection,"callBackArray", this, "callBackArray");				
				_connections.push(connection);
			}
			
		}
	
		public function startConnection():void{
			for each(var connection:MonkeyConnection in _connections){
				connection.startConnection();
			}
		}
		
		public function send(txVO:TXVO):void{
			var connection:ConsoleMonkeyConnection;
			if(txVO.channel != "_agent"){
				for each(connection in _connections){
					if(connection.txChannelName == txVO.channel){
						connection.send(txVO);
						break;
					}
				}	
			}else{
				for each(connection in _connections){
					txVO.channel = connection.txChannelName;
					connection.send(txVO);
				}					
			}
		}
		
		
		
	}
}