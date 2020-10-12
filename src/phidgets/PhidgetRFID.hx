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
import phidgets.Phidget.PhidgetHandle;
import phidgets.Phidget.PhidgetOnAttachCallback;
import phidgets.Phidget.PhidgetOnDetachCallback;
import phidgets.Phidget.PhidgetOnErrorCallback;
import phidgets.Phidget.VoidStar;
import phidgets.utils.PhidgetReturnCode;

/**
 * ...
 * @author Tommy S
 */

@:cppFileCode('
	#include <iostream>
	#include <string>	
')
@:cppNamespaceCode('	
	/////////////////////////////////////////////////////////////////////////////////////

	PhidgetRFIDHandle handle_internal;
	bool isAttached_internal = false;

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

	/////////////////////////////////////////////////////////////////////////////////////

	std::string lastTag_internal;
	std::string currentTag_internal;

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

	/////////////////////////////////////////////////////////////////////////////////////
')
class PhidgetRFID extends Phidget
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var hasTag				: Bool						= false;
	public var currentTag			: String;
	public var onTag				: (String)->Void;
	public var onTagLost			: (String)->Void;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new(autoInit:Bool=true)
	{
		super();
		model = "PhidgetRFID Read-Write 1024_0";

		var hndl = PhidgetRFIDHandle.declare();
		untyped __cpp__('handle_internal = hndl');

		if (!createPhidget())
			return;

		var c:PhidgetReturnCode = SetOnTagHandler(rfidHandle,OnTagCallback_Internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagHandler failed: $c');
			return;
		}
		c = SetOnTagLost(rfidHandle,OnTagLostCallback_Internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagLost failed: $c');
			return;
		}

		if (autoInit)
			attach();
	}
	
 	/////////////////////////////////////////////////////////////////////////////////////

	function createPhidget():Bool
	{
		var c:PhidgetReturnCode = Create(Native.addressOf(rfidHandle));
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget create failed: $c');
			return false;
		}

		handle = Phidget.Handle;
		return c==PhidgetReturnCode.EPHIDGET_OK;
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	public function attach()
	{
		if (isInitialized)
			return;

		onAttachCallback_internal = Phidget.OnAttachCallback_internal;
		onDetachCallback_internal = Phidget.OnDetachCallback_internal;
		onErrorCallback_internal = Phidget.OnErrorCallback_internal;

		addHandlers();
		waitForAttachment();

		chTimer = new Timer(checkIntervalMS);
		chTimer.run = checkStatus;
		isInitialized = true;
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	override function checkStatus()
	{
		super.checkStatus();
		
		if(isDisposed)
			return;

		triggerAttachstate(isAttached_internal);

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

	override public function close()
	{
		super.close();
		var c:PhidgetReturnCode = Delete(Native.addressOf(rfidHandle));		
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('PhidgetRFID_delete failed: $c');
		}	
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:extern @:native("PhidgetRFID_create")
	public static function Create(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_delete")
	public static function Delete(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_setOnTagHandler")
	public static function SetOnTagHandler(ch:PhidgetRFIDHandle, handler:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_setOnTagLostHandler")
	public static function SetOnTagLost(ch:PhidgetRFIDHandle, onTagLost:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:extern @:native("onTag_internal")
	public static var OnTagCallback_Internal:PhidgetRFIDOnTagCallback;

	@:extern @:native("onTagLost_internal")
	public static var OnTagLostCallback_Internal:PhidgetRFIDOnTagCallback;

	@:extern @:native("handle_internal")
	public static var rfidHandle:PhidgetRFIDHandle;
	
	@:extern @:native("isAttached_internal")
	public static var isAttached_internal:Bool;

	/////////////////////////////////////////////////////////////////////////////////////

	override public function dispose()
	{
		rfidHandle = null;
		currentTag = null;
		onTag = null;
		onTagLost;
		super.dispose();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////

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

	/////////////////////////////////////////////////////////////////////////////////////
}

@:native("PhidgetRFIDHandle")
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