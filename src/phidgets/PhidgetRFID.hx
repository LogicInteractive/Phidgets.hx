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

	@:isVar
	public var antennaEnabled(get,set)	: Bool						= true;

	public var hasTag					: Bool						= false;
	public var currentTag				: String;
	public var onTag					: (String)->Void;
	public var onTagLost				: (String)->Void;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new(autoInit:Bool=true)
	{
		super();
		model = "PhidgetRFID Read-Write 1024_0";

		declare();
		if (!createPhidget())
			return;

		var c:PhidgetReturnCode = PhidgetRFID.SetOnTagHandler(rfidHandle,PhidgetRFID.OnTagCallback_Internal);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagHandler failed: $c');
			return;
		}
		c = PhidgetRFID.SetOnTagLost(rfidHandle,PhidgetRFID.OnTagLostCallback_Internal);
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
		var c:PhidgetReturnCode = PhidgetRFID.Create(Native.addressOf(rfidHandle));
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget create failed: $c');
			return false;
		}

		handle = Phidget.Handle;
		return c==PhidgetReturnCode.EPHIDGET_OK;
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	override function checkStatus()
	{
		super.checkStatus();
		
		if(isDisposed)
			return;

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
		var c:PhidgetReturnCode = PhidgetRFID.Delete(Native.addressOf(rfidHandle));		
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('PhidgetRFID_delete failed: $c');
		}	
	}

	/////////////////////////////////////////////////////////////////////////////////////

	function get_antennaEnabled():Bool
	{
		var enabl:Int = 0;
		PhidgetRFID.GetAntennaEnabled(rfidHandle,Native.addressOf(enabl));
		return antennaEnabled = enabl==1?true:false;
	}

	function set_antennaEnabled(value:Bool):Bool
	{
		PhidgetRFID.SetAntennaEnabled(rfidHandle,value==true?1:0);
		return antennaEnabled=value;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	override function declare()
	{
		var hndl = PhidgetRFIDHandle.declare();
		untyped __cpp__('handle_internal = hndl');		
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:extern @:native("PhidgetRFID_create")
	static function Create(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_delete")
	static function Delete(ch:cpp.Reference<PhidgetRFIDHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_setOnTagHandler")
	static function SetOnTagHandler(ch:PhidgetRFIDHandle, handler:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_setOnTagLostHandler")
	static function SetOnTagLost(ch:PhidgetRFIDHandle, onTagLost:PhidgetRFIDOnTagCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_setAntennaEnabled")
	static function SetAntennaEnabled(ch:PhidgetRFIDHandle, antennaEnabled:Int):PhidgetReturnCode;

	@:extern @:native("PhidgetRFID_getAntennaEnabled")
	static function GetAntennaEnabled(ch:PhidgetRFIDHandle, antennaEnabled:cpp.Reference<Int>):PhidgetReturnCode;

	@:extern @:native("onTag_internal")
	static var OnTagCallback_Internal:PhidgetRFIDOnTagCallback;

	@:extern @:native("onTagLost_internal")
	static var OnTagLostCallback_Internal:PhidgetRFIDOnTagCallback;

	@:extern @:native("handle_internal")
	static var rfidHandle:PhidgetRFIDHandle;
	
	@:extern @:native("currentTag_internal")
	static var CurrentTag_internal:StdString;

	@:extern @:native("lastTag_internal")
	static var LastTag_internal:StdString;

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
		var cTagSt:StdString = CurrentTag_internal;
		return cTagSt.toString();
	}

	inline function getLastTag_internal():String
	{
		var lTagSt:StdString = LastTag_internal;
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