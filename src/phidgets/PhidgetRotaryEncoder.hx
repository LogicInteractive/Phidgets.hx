package phidgets;

import cpp.Callable;
import cpp.Function;
import cpp.Native;
import cpp.Pointer;
import cpp.Reference;
import cpp.Star;
import cpp.StdString;
import cpp.UInt32;
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
	
	PhidgetEncoderHandle handle_internal;

	bool encoderTrigger_internal = false;
	int lastPositionChange_internal;
	int lastTimeChange_internal;
	int lastIndexTriggered_internal;

	void CCONV onEncoder_PositionChange(PhidgetEncoderHandle ch, void * ctx, int positionChange, double timeChange, int indexTriggered)
	{
		lastPositionChange_internal = positionChange;
		lastTimeChange_internal = timeChange;
		lastIndexTriggered_internal = indexTriggered;
		encoderTrigger_internal = true;
	}

	/////////////////////////////////////////////////////////////////////////////////////
')
@:unreflective
class PhidgetRotaryEncoder extends Phidget
{
	/////////////////////////////////////////////////////////////////////////////////////

	public var lastPositionChange			: Int				= 0;
	public var lastTimeChange				: Int				= 0;
	public var lastIndexTriggered			: Int				= 0;
	public var position						: cpp.Int64			= 0;
	public var enabled(get, default)		: Bool				= false;

	@:isVar
	public var minDataInterval(get, never)	: cpp.UInt32		= 0;
	
	@:isVar
	public var maxDataInterval(get, never)	: cpp.UInt32		= 0;

	@:isVar
	public var dataInterval(get, set)		: cpp.UInt32		= 0;


	public var onEncoderPositionChanged		: (PhidgetEncoderEventData)->Void;

	/////////////////////////////////////////////////////////////////////////////////////
	
	public function new(autoInit:Bool=true)
	{
		super();
		model = "PhidgetEncoder HighSpeed 1057_2";

		declare();
		if (!createPhidget())
			return;

		var c:PhidgetReturnCode = PhidgetRotaryEncoder.SetOnPositionChangeHandler(encoderHandle,PhidgetRotaryEncoder.OnEncoderPositionChange);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget set onTagHandler failed: $c');
			return;
		}
		
		if (autoInit)
			attach();

		dataInterval = 16;
	}
	
 	/////////////////////////////////////////////////////////////////////////////////////

	function createPhidget():Bool
	{
		var c:PhidgetReturnCode = PhidgetRotaryEncoder.Create(encoderHandle);
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('Phidget create failed: $c');
			return false;
		}

		handle = cast Phidget.Handle;
		return c==PhidgetReturnCode.EPHIDGET_OK;
	}

 	/////////////////////////////////////////////////////////////////////////////////////

	override function checkStatus()
	{
		super.checkStatus();
		PhidgetRotaryEncoder.GetPosition(encoderHandle, Native.addressOf(position));

		if (encoderTrigger_internal)
		{
			lastPositionChange=lastPositionChange_internal;
			lastTimeChange=lastTimeChange_internal;
			lastIndexTriggered=lastIndexTriggered_internal;

			if (onEncoderPositionChanged!=null)
				onEncoderPositionChanged(
				{
					lastPositionChange: lastPositionChange,
					lastTimeChange: lastTimeChange,
					lastIndexTriggered: lastIndexTriggered,
					encoderPosition:position
				});
			encoderTrigger_internal = false;
		}		

		if(isDisposed)
			return;

	}

	override public function close()
	{
		super.close();
		var c:PhidgetReturnCode = PhidgetRotaryEncoder.Delete(encoderHandle);		
		if (c!=PhidgetReturnCode.EPHIDGET_OK)
		{
			trace('PhidgetRotaryEncoder_delete failed: $c');
		}	
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:keep
	function get_minDataInterval():cpp.UInt32
	{
		var minInt:cpp.UInt32 = 0;
		PhidgetRotaryEncoder.GetMinDataInterval(encoderHandle,Native.addressOf(minInt));
		return minInt;
	}

	@:keep
	function get_maxDataInterval():cpp.UInt32
	{
		var maxInt:cpp.UInt32 = 0;
		PhidgetRotaryEncoder.GetMaxDataInterval(encoderHandle,Native.addressOf(maxInt));
		return maxInt;
	}

	@:keep
	function get_dataInterval():cpp.UInt32
	{
		var dInt:cpp.UInt32 = 0;
		PhidgetRotaryEncoder.GetDataInterval(encoderHandle,Native.addressOf(dInt));
		return dInt;
	}

	@:keep
	function set_dataInterval(value:cpp.UInt32):cpp.UInt32
	{
		if (value<minDataInterval)
			value = minDataInterval;
		else if (value>maxDataInterval)
			value = maxDataInterval;

		PhidgetRotaryEncoder.SetDataInterval(encoderHandle,value);
		return dataInterval=value;
	}

	@:keep
	function get_enabled():Bool
	{
		var isEnabled:Int = 0;
		PhidgetRotaryEncoder.GetEnabled(encoderHandle,Native.addressOf(isEnabled));
		return isEnabled==1;
	}

	override function declare()
	{
		var hndl = PhidgetEncoderHandle.declare();
		untyped __cpp__('handle_internal = hndl');		
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:extern @:native("PhidgetEncoder_create")
	static function Create(ch:cpp.Star<PhidgetEncoderHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_delete")
	static function Delete(ch:cpp.Star<PhidgetEncoderHandle>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_getPosition")
	static function GetPosition(ch:PhidgetEncoderHandle, position:cpp.Star<cpp.Int64>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_setPosition")
	static function SetPosition(ch:PhidgetEncoderHandle, position:cpp.Int64):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_setOnPositionChangeHandler")
	static function SetOnPositionChangeHandler(ch:PhidgetEncoderHandle, handler:PhidgetEncoderOnPositionChangeCallback, ?ctx:VoidStar):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_getMinDataInterval")
	static function GetMinDataInterval(ch:PhidgetEncoderHandle, minDataInterval:cpp.Star<cpp.UInt32>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_getMaxDataInterval")
	static function GetMaxDataInterval(ch:PhidgetEncoderHandle, maxDataInterval:cpp.Star<cpp.UInt32>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_getEnabled")
	static function GetEnabled(ch:PhidgetEncoderHandle, enabled:cpp.Star<cpp.UInt32>):PhidgetReturnCode;

	@:extern @:native("PhidgetEncoder_getDataInterval")
	static function GetDataInterval(ch:PhidgetEncoderHandle, dataInterval:cpp.Star<Int>):PhidgetReturnCode;
	
	@:extern @:native("PhidgetEncoder_setDataInterval")
	static function SetDataInterval(ch:PhidgetEncoderHandle, dataInterval:Int):PhidgetReturnCode;

	@:extern @:native("onEncoder_PositionChange")
	static var OnEncoderPositionChange:PhidgetEncoderOnPositionChangeCallback;

	@:extern @:native("handle_internal")
	static var encoderHandle:PhidgetEncoderHandle;

	@:extern @:native("lastPositionChange_internal")
	static var lastPositionChange_internal:Int;
	
	@:extern @:native("lastTimeChange_internal")
	static var lastTimeChange_internal:Int;
	
	@:extern @:native("lastIndexTriggered_internal")
	static var lastIndexTriggered_internal:Int;

	@:extern @:native("encoderTrigger_internal")
	static var encoderTrigger_internal:Bool;
	
	/////////////////////////////////////////////////////////////////////////////////////

	override public function dispose()
	{
		encoderHandle = null;
		onEncoderPositionChanged = null;
		super.dispose();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
}

typedef PhidgetEncoderEventData =
{
	var lastPositionChange		: Int;
	var lastTimeChange			: Int;
	var lastIndexTriggered		: Int;	
	var encoderPosition			: Int;	
}

@:native("PhidgetEncoderHandle")
extern class PhidgetEncoderHandle
{
	@:native("PhidgetEncoderHandle")
	public static function declare():PhidgetEncoderHandle;	
}

@:native("PhidgetEncoder_OnPositionChangeCallback")
extern class PhidgetEncoderOnPositionChangeCallback
{
}

/////////////////////////////////////////////////////////////////////////////////////