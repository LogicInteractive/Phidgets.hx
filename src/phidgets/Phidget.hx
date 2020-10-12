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
import phidgets.utils.PhidgetReturnCode;

/**
 * ...
 * @author Tommy S
 */

@:buildXml('<include name="../../src/phidgets/build/PhidgetsBuild.xml" />')
@:headerInclude('phidget22.h')
class Phidget
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var isAttached			: Bool						= false;
	public var attachTimeoutMS		: Int						= 5000;
	public var checkIntervalMS		: Int						= 16;
	public var onAttach				: ()->Void;
	public var onDetach				: ()->Void;
	public var onError				: (Int,String)->Void;
	public var model				: String;

	var isDisposed					: Bool;
	var isInitialized				: Bool;

	var chTimer						: Timer;
	
	@:unreflective
	var handle						: PhidgetHandle;
	@:unreflective
	var onAttachCallback_internal	: PhidgetOnAttachCallback;
	@:unreflective
	var onDetachCallback_internal	: PhidgetOnDetachCallback;
	@:unreflective
	var onErrorCallback_internal	: PhidgetOnErrorCallback;

	/////////////////////////////////////////////////////////////////////////////////////
	
	function new()
	{
		//Well nothing happens here.. Only subclass 
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	@:unreflective
	function waitForAttachment():PhidgetReturnCode
	{
		var c:PhidgetReturnCode = OpenWaitForAttachment(handle,attachTimeoutMS);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
			trace('Phidget wait for attchment failed: $c');
		return c;
	}	

	@:unreflective
	function addHandlers()
	{
		var c:PhidgetReturnCode = SetOnAttachHandler(handle,onAttachCallback_internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onAttach failed: $c');
		}	
		c = SetOnDetachHandler(handle,onDetachCallback_internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onDetach failed: $c');
		}	
		c = SetOnErrorHandler(handle,onErrorCallback_internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget add onError failed: $c');
		}	
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	function checkStatus()
	{
		if(isDisposed)
			return;
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	function triggerAttachstate(nAttachState:Bool)
	{
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
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	public function close()
	{
		var c:PhidgetReturnCode = Close(handle);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget close failed: $c');
		}	
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:extern @:native("Phidget_setOnAttachHandler")
	public static function SetOnAttachHandler(ch:PhidgetHandle, onTagLost:PhidgetOnAttachCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:extern @:native("Phidget_setOnDetachHandler")
	public static function SetOnDetachHandler(ch:PhidgetHandle, onTagLost:PhidgetOnDetachCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:extern @:native("Phidget_setOnErrorHandler")
	public static function SetOnErrorHandler(ch:PhidgetHandle, onTagLost:PhidgetOnErrorCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:extern @:native("Phidget_openWaitForAttachment")
	public static function OpenWaitForAttachment(ch:PhidgetHandle, timeout:Int):PhidgetReturnCode;
		
	@:extern @:native("Phidget_open")
	public static function Open(ch:PhidgetHandle):PhidgetReturnCode;

	@:extern @:native("Phidget_close")
	public static function Close(ch:PhidgetHandle):PhidgetReturnCode;

	@:extern @:native("onAttach_internal")
	public static var OnAttachCallback_internal:PhidgetOnAttachCallback;

	@:extern @:native("onDetach_internal")
	public static var OnDetachCallback_internal:PhidgetOnDetachCallback;

	@:extern @:native("onError_internal")
	public static var OnErrorCallback_internal:PhidgetOnErrorCallback;

	@:extern @:native("(PhidgetHandle)handle_internal")
	public static var Handle:PhidgetHandle;

	/////////////////////////////////////////////////////////////////////////////////////

	public function dispose()
	{
		isDisposed = true;
		if (chTimer!=null)
		{
			chTimer.stop();
			chTimer=null;
		}
		handle = null;
		onAttachCallback_internal = null;
		onDetachCallback_internal = null;
		onErrorCallback_internal = null;
		onAttach = null;
		onDetach = null;
		onError = null;
		close();
	}

	/////////////////////////////////////////////////////////////////////////////////////

}

@:native("PhidgetHandle")
extern class PhidgetHandle
{
	@:native("PhidgetHandle")
	public static function declare():PhidgetHandle;	
} 

@:native("PhidgetCallback")
extern class PhidgetCallback
{
}

@:native("Phidget_OnAttachCallback")
extern class PhidgetOnAttachCallback
{
}

@:native("Phidget_OnDetachCallback")
extern class PhidgetOnDetachCallback
{
}

@:native("Phidget_OnErrorCallback")
extern class PhidgetOnErrorCallback
{
}

@:native("*void")
extern class StarVoid
{
}
 
@:native("void *")
extern class VoidStar
{
}
 
@:native("const char *")
extern class ConstCharStar
{
}
