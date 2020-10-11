package phidgets;

import cpp.Callable;
import cpp.Function;
import cpp.Native;
import cpp.Pointer;
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
	PhidgetRFIDHandle h;
	std::string lastTag_internal;
	std::string currentTag_internal;
	
	::cpp::Function<void (String)> onTagHx;

	static void CCONV onTagHnl_internal(PhidgetRFIDHandle ch, void * ctx, const char * tag, PhidgetRFID_Protocol protocol)
	{
		// std::cout << "Tag: " << tag << std::endl;
		// onTagHx(tag);
		currentTag_internal = tag;
		lastTag_internal = tag;
	}	

	static void CCONV onTagLost_internal(PhidgetRFIDHandle ch, void * ctx, const char * tag, PhidgetRFID_Protocol protocol)
	{
		// std::cout << "Tag Lost: " << tag << std::endl;
		currentTag_internal = "";
	}

	static void CCONV onAttach_internal(PhidgetHandle ch, void * ctx)
	{
		std::cout << "Attach!" << std::endl;
	}

	static void CCONV onDetach_internal(PhidgetHandle ch, void * ctx)
	{
		std::cout << "Detach!" << std::endl;
	}

	static void CCONV onError_internal(PhidgetHandle ch, void * ctx, Phidget_ErrorEventCode code, const char * description)
	{
		std::cout << "ERROR: Description: " << description << std::endl;
	}

')
class PhidgetRFID
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var hasTag				: Bool;
	public var currentTag			: String;
	public var onTag				: (String)->Void;
	public var onTagLost			: (String)->Void;

	var isDisposed					: Bool;

	var chTimer						: Timer;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new()
	{
		var hndl = PhidgetRFIDHandle.declare();
		untyped __cpp__('h = hndl');
		
		// if (init()!=PhidgetReturnCode.EPHIDGET_OK)
		// {
		// 	trace("RFID Phidget Error.");
		// 	return;
		// }

		init();
	}
 
	function init()
	{
		var handle:PhidgetRFIDHandle = getHandle();
		// var c:PhidgetReturnCode = P22RFID.create(handle);
		var c:PhidgetReturnCode = untyped __cpp__('PhidgetRFID_create(&h);');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget create failed: $c');
			return;
		}
		// c = P22RFID.setOnTagHandler(handle,untyped __cpp__('onTagHnl'),null);
		c = untyped __cpp__('PhidgetRFID_setOnTagHandler(h, onTagHnl_internal, NULL)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagHandler failed: $c');
			return;
		}
		c = untyped __cpp__('PhidgetRFID_setOnTagLostHandler(h, onTagLost_internal, NULL)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagLost failed: $c');
			return;
		}
		addHandlers();
		waitForAttachment();

		chTimer = new Timer(16);
		chTimer.run = checkStatus;
	}

/* 	public function open():PhidgetReturnCode
	{
		var c:PhidgetReturnCode = P22RFID.open(getPhidgetHandle());	
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget open failed: $c');
			return c;
		}
		else 
			trace (c);
		return c;
	}
 */	
 
	function waitForAttachment():PhidgetReturnCode
	{
		var handle:PhidgetHandle = getPhidgetHandle();
		var c:PhidgetReturnCode = Phidget22.openWaitForAttachment(handle,5000);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
			trace('Phidget wait for attchment failed: $c');
		return c;
	}

	function addHandlers()
	{
		var handle:PhidgetHandle = getPhidgetHandle();
		// var c:PhidgetReturnCode = Phidget22.setOnAttachHandler(untyped __cpp__('(PhidgetHandle)h'),untyped __cpp__('onAttach'),null);
		var c:PhidgetReturnCode = untyped __cpp__('Phidget_setOnAttachHandler((PhidgetHandle)h, onAttach_internal, NULL)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onAttach failed: $c');
		}	
		// c = Phidget22.setOnDetachHandler(untyped __cpp__('(PhidgetHandle)h'),untyped __cpp__('onDetach'),null);
		c = untyped __cpp__('Phidget_setOnDetachHandler((PhidgetHandle)h, onDetach_internal, NULL)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onDetach failed: $c');
		}	
		// c = Phidget22.setOnErrorHandler(untyped __cpp__('(PhidgetHandle)h'),untyped __cpp__('onError'),null);
		c = untyped __cpp__('Phidget_setOnErrorHandler((PhidgetHandle)h, onError_internal, NULL)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onError failed: $c');
		}	
	}
	
	function closePhidget()
	{
		var c:PhidgetReturnCode = untyped __cpp__('Phidget_close((PhidgetHandle)h)');
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget close failed: $c');
		}	
		c =	untyped __cpp__('PhidgetRFID_delete(&h)');		
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

		var cTagSt:StdString = untyped __cpp__('currentTag_internal');
		var lastTagSt:StdString = untyped __cpp__('lastTag_internal');
		var cTag:String = cTagSt.toString();
		var lastTag:String = lastTagSt.toString();

		if (cTag==null || cTag=="")
		{
			// if (currentTag!="" && lastTag!=null && lastTag!="")
			// {
			if (hasTag)
				if (onTagLost!=null)
					onTagLost(lastTag);

				// trace('TAG lost: $lastTag');
			// }
			hasTag = false;
			currentTag = "";
		}
		else 
		{
			// if (currentTag=="")
			// {
			if (currentTag!=lastTag)
				if (onTag!=null)
					onTag(lastTag);

				// trace('TAG: $cTag');
			// }
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

	inline function getHandle():PhidgetRFIDHandle
	{
		return untyped __cpp__('h');
	}
	
	inline function getPhidgetHandle():PhidgetHandle
	{
		return untyped __cpp__('(PhidgetHandle)h');
	}
}

@:include('phidget22.h')
extern class P22RFID
{
	/////////////////////////////////////////////////////////////////////////////////////

	@:native("PhidgetRFID_create")
	public static function create(ch:Star<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:native("PhidgetRFID_setOnTagHandler")
	public static function setOnTagHandler(ch:PhidgetRFIDHandle, handler:PhidgetRFIDOnTagCallback, ctx:VoidStar):PhidgetReturnCode;

	@:native("PhidgetRFID_setOnTagLostHandler")
	public static function setOnTagLost(ch:PhidgetRFIDHandle, onTagLost:PhidgetRFIDOnTagCallback, ctx:VoidStar):PhidgetReturnCode;

	@:native("PhidgetRFID_delete")
	public static function delete(ch:Star<PhidgetHandle>):PhidgetReturnCode;
		
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