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

/**
 * ...
 * @author Tommy S
 */

class Phidget
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var isAttached			: Bool						= false;
	public var attachTimeoutMS		: Int						= 5000;
	public var checkIntervalMS		: Int						= 16;
	public var onAttach				: ()->Void;
	public var onDetach				: ()->Void;
	public var onError				: (Int,String)->Void;

	var isDisposed					: Bool;
	var isInitialized				: Bool;

	var chTimer						: Timer;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new(autoInit:Bool=true)
	{
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
		close();
	}

	/////////////////////////////////////////////////////////////////////////////////////

}

/////////////////////////////////////////////////////////////////////////////////////

@:buildXml('<include name="../../src/phidgets/PhidgetsBuild.xml" />')
@:include('phidget22.h')
extern class PhidgetExt
{
	/////////////////////////////////////////////////////////////////////////////////////

	@:native("Phidget_setOnAttachHandler")
	public static function setOnAttachHandler(ch:PhidgetHandle, onTagLost:PhidgetOnAttachCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:native("Phidget_setOnDetachHandler")
	public static function setOnDetachHandler(ch:PhidgetHandle, onTagLost:PhidgetOnDetachCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:native("Phidget_setOnErrorHandler")
	public static function setOnErrorHandler(ch:PhidgetHandle, onTagLost:PhidgetOnErrorCallback, ?ctx:VoidStar):PhidgetReturnCode;
		
	@:native("Phidget_openWaitForAttachment")
	public static function openWaitForAttachment(ch:PhidgetHandle, timeout:Int):PhidgetReturnCode;
		
	@:native("Phidget_open")
	public static function open(ch:PhidgetHandle):PhidgetReturnCode;

	@:native("Phidget_close")
	public static function close(ch:PhidgetHandle):PhidgetReturnCode;
		
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
