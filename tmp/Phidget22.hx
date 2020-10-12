package phidgets;

/**
 * ...
 * @author Tommy S
 */

@:buildXml('<include name="../../src/phidgets/PhidgetsBuild.xml" />')
@:include('phidget22.h')
extern class Phidget22
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

/////////////////////////////////////////////////////////////////////////////////////

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

@:native("PhidgetHandle")
@:include('phidget22.h')
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