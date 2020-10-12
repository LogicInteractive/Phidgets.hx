package phidgets;

import cpp.Callable;
import cpp.Function;
import cpp.Native;
import cpp.Pointer;
import cpp.Reference;
import cpp.Star;
import cpp.StdString;
import haxe.Timer;
import haxe.macro.Expr.Function;
import phidgets.Phidget22;
import sys.thread.Thread;

/**
 * ...
 * @author Tommy S
 */

@:cppFileCode('
	#include <iostream>
	#include <string>	
')
@:cppNamespaceCode('	
	PhidgetRFIDHandle handle_internal;
	std::string lastTag_internal;
	std::string currentTag_internal;
	bool isAttached_internal = false;
	
	// ::cpp::Function<void (String)> onTagHx;

	void CCONV onTag_internal(PhidgetRFIDHandle ch, void * ctx, const char * tag, PhidgetRFID_Protocol protocol)
	{
		// std::cout << "Tag: " << tag << std::endl;
		// onTagHx(tag);
		currentTag_internal = tag;
		lastTag_internal = tag;
	}	

	void CCONV onTagLost_internal(PhidgetRFIDHandle ch, void * ctx, const char * tag, PhidgetRFID_Protocol protocol)
	{
		// std::cout << "Tag Lost: " << tag << std::endl;
		currentTag_internal = "";
	}

	void CCONV onAttach_internal(PhidgetHandle ch, void * ctx)
	{
		// std::cout << "Attach!" << std::endl;
		isAttached_internal = true;
	}

	void CCONV onDetach_internal(PhidgetHandle ch, void * ctx)
	{
		// std::cout << "Detach!" << std::endl;
		isAttached_internal = false;
	}

	void CCONV onError_internal(PhidgetHandle ch, void * ctx, Phidget_ErrorEventCode code, const char * description)
	{
		std::cout << "ERROR: Description: " << description << std::endl;
	}

')
class PhidgetRFID
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var hasTag				: Bool						= false;
	public var isAttached			: Bool						= false;
	public var attachTimeoutMS		: Int						= 5000;
	public var checkIntervalMS		: Int						= 16;
	public var currentTag			: String;
	public var onTag				: (String)->Void;
	public var onTagLost			: (String)->Void;
	public var onAttach				: ()->Void;
	public var onDetach				: ()->Void;
	public var onError				: (Int,String)->Void;

	var isDisposed					: Bool;
	var isInitialized				: Bool;

	var chTimer						: Timer;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new(autoInit:Bool=true)
	{
		var hndl = PhidgetRFIDHandle.declare();
		untyped __cpp__('handle_internal = hndl');
		
		var c:PhidgetReturnCode = P22RFID.create(Native.addressOf(getHandle()));
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget create failed: $c');
			return;
		}
		c = P22RFID.setOnTagHandler(getHandle(),getOnTagHandler_internal());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagHandler failed: $c');
			return;
		}
		c = P22RFID.setOnTagLost(getHandle(),getOnTagLost_internal());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagLost failed: $c');
			return;
		}

		if (autoInit)
			init();
	}
	
	public function init()
	{
		if (isInitialized)
			return;

		addHandlers();
		waitForAttachment();

		chTimer = new Timer(checkIntervalMS);
		chTimer.run = checkStatus;
		isInitialized = true;
	}

	function waitForAttachment():PhidgetReturnCode
	{
		var c:PhidgetReturnCode = Phidget22.openWaitForAttachment(getPhidgetHandle(),attachTimeoutMS);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
			trace('Phidget wait for attchment failed: $c');
		return c;
	}

	function addHandlers()
	{
		var handle:PhidgetHandle = getPhidgetHandle();
		var c:PhidgetReturnCode = Phidget22.setOnAttachHandler(getPhidgetHandle(),getOnAttach_internal());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onAttach failed: $c');
		}	
		c = Phidget22.setOnDetachHandler(getPhidgetHandle(),getOnDetach_internal());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onDetach failed: $c');
		}	
		c = Phidget22.setOnErrorHandler(getPhidgetHandle(),getOnError_internal());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onError failed: $c');
		}	
	}
	
	function closePhidget()
	{
		var c:PhidgetReturnCode = Phidget22.close(getPhidgetHandle());
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget close failed: $c');
		}	
		c =	P22RFID.delete(Native.addressOf(getHandle()));		
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('PhidgetRFID_delete failed: $c');
		}	
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	function checkStatus()
	{
		if(isDisposed)
			return;

		var nAttachState:Bool = getAttachedState_internal();
		if (nAttachState!=isAttached)
		{
			isAttached = nAttachState;
			if (nAttachState==true)
			{
				if(onAttach!=null)
					onAttach();
			}
			else
				if(onDetach!=null)
					onDetach();
		}

		var cTag:String = getCurrentTag_internal();
		var lastTag:String = getLastTag_internal();

		if (cTag==null || cTag=="")
		{
			if (hasTag)
				if (onTagLost!=null)
					onTagLost(lastTag);

			hasTag = false;
			currentTag = "";
		}
		else 
		{
			if (currentTag!=lastTag)
				if (onTag!=null)
					onTag(lastTag);

			hasTag = true;
			currentTag = lastTag;
		}
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	public function dispose()
	{
		isDisposed = true;
		if (chTimer!=null)
		{
			chTimer.stop();
			chTimer=null;
		}
		closePhidget();
	}

	/////////////////////////////////////////////////////////////////////////////////////

	inline function getAttachedState_internal():Bool
	{
		return untyped __cpp__('isAttached_internal');
	}

	inline function getPhidgetHandle():PhidgetHandle
	{
		return untyped __cpp__('(PhidgetHandle)handle_internal');
	}

	inline function getOnAttach_internal():PhidgetOnAttachCallback
	{
		return untyped __cpp__('onAttach_internal');
	}
	
	inline function getOnDetach_internal():PhidgetOnDetachCallback
	{
		return untyped __cpp__('onDetach_internal');
	}
	
	inline function getOnError_internal():PhidgetOnErrorCallback
	{
		return untyped __cpp__('onError_internal');
	}
	
	/////////////////////////////////////////////////////////////////////////////////////

	inline function getOnTagHandler_internal():PhidgetRFIDOnTagCallback
	{
		return untyped __cpp__('onTag_internal');
	}

	inline function getOnTagLost_internal():PhidgetRFIDOnTagCallback
	{
		return untyped __cpp__('onTagLost_internal');
	}

	inline function getHandle():PhidgetRFIDHandle
	{
		return untyped __cpp__('handle_internal');
	}

	inline function getCurrentTag_internal():String
	{
		var cTagSt:StdString = untyped __cpp__('currentTag_internal');
		return cTagSt.toString();
	}

	inline function getLastTag_internal():String
	{
		var lTagSt:StdString = untyped __cpp__('lastTag_internal');
		return lTagSt.toString();
	}

	
}

@:include('phidget22.h')
extern class P22RFID
{
	/////////////////////////////////////////////////////////////////////////////////////

	@:native("PhidgetRFID_create")
	public static function create(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:native("PhidgetRFID_setOnTagHandler")
	public static function setOnTagHandler(ch:PhidgetRFIDHandle, handler:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:native("PhidgetRFID_setOnTagLostHandler")
	public static function setOnTagLost(ch:PhidgetRFIDHandle, onTagLost:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:native("PhidgetRFID_delete")
	public static function delete(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;
		
	/////////////////////////////////////////////////////////////////////////////////////
}

@:native("PhidgetRFIDHandle")
@:include('phidget22.h')
extern class PhidgetRFIDHandle
{
	@:native("PhidgetRFIDHandle")
	public static function declare():PhidgetRFIDHandle;	
}

@:native("PhidgetRFID_OnTagCallback")
extern class PhidgetRFIDOnTagCallback
{
}

/////////////////////////////////////////////////////////////////////////////////////