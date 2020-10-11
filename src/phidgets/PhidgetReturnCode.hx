package phidgets;

enum abstract PhidgetReturnCode(Int) from Int to Int
{
	/**[ Success ] : Call succeeded. **/
	var EPHIDGET_OK					= 0x0;

	/**[ No Such Entity ] : The specified entity does not exist. This is usually a result of Net or Log API calls.	**/
	var EPHIDGET_NOENT				= 0x2;

	/**[ Timed out ] : Call has timed out. This can happen for a number of common reasons: Check that the Phidget you are trying to open is plugged in, and that the addressing parameters have been specified correctly. Check that the Phidget is not already open in another program, such as the Phidget Control Panel, or another program you are developing. If your Phidget has a plug or terminal block for external power, ensure it is plugged in and powered. If you are using remote Phidgets, ensure that your computer can access the remote Phidgets using the Phidget Control Panel. If you are using remote Phidgets, ensure you have enabled Server Discovery or added the server corresponding to the Phidget you are trying to open. If you are using Network Server Discovery, try extending the timeout to allow more time for the server to be discovered. 	**/
	var EPHIDGET_TIMEOUT			= 0x3;

	/**[ Op Interrupted ] : The operation was interrupted; either from an error, or because the device was closed.	**/
	var EPHIDGET_INTERRUPTED		= 0x4;

	/**[ Access (Permission) Issue ] : Access to the resource (file) is denied. This can happen when enabling logging.	**/
	var EPHIDGET_ACCESS				= 0x7;

	/**[ Resource Busy ] : Specified resource is in use. This error code is not normally used.	**/
	var EPHIDGET_BUSY				= 0x9;

	/**[ Invalid ] : Invalid or malformed command. This can be caused by sending a command to a device which is not supported in it's current configuration.	**/
	var EPHIDGET_INVALID			= 0xd;

	/**[ Not enough space ] : Invalid or malformed command. This can be caused by sending a command to a device which is not supported in it's current configuration.	**/
	var EPHIDGET_NOSPC				= 0x10;

	/**[ Operation Not Supported ] : This API call is not supported. For Class APIs this means that this API is not supported by this device. This can also mean the API is not supported on this OS, or OS configuration.	**/
	var EPHIDGET_UNSUPPORTED		= 0x14;

	/**[ Invalid Argument ] : One or more of the parameters passed to the function is not accepted by the channel in its current configuration. This may also be an indication that a NULL pointer was passed where a valid pointer is required.	**/
	var EPHIDGET_INVALIDARG			= 0x15;

	/**[ Unexpected Error ] : Something unexpected has occured. Enable library logging and have a look at the log, or contact Phidgets support.	**/
	var EPHIDGET_UNEXPECTED			= 0x1c;

	/**[ Duplicate ] : Duplicated request. Can happen with some Net API calls, such as trying to add the same server twice.	**/
	var EPHIDGET_DUPLICATE			= 0x1b;

	/**[ Wrong Device ] : A Phidget channel object of the wrong channel class was passed into this API call.	**/
	var EPHIDGET_WRONGDEVICE		= 0x32;

	/**[ Unknown or Invalid Value ] : The value is unknown. This can happen right after attach, when the value has not yet been recieved from the Phidget. This can also happen if a device has not yet been configured / enabled. Some properties can only be read back after being set.	**/
	var EPHIDGET_UNKNOWNVAL			= 0x33;

	/**[ Device not Attached ] : This can happen for a number of common reasons. Be sure you are opening the channel before trying to use it. If you are opening the channel, the program may not be waiting for the channel to be attached. If possible use openWaitForAttachment. Otherwise, be sure to check the Attached property of the channel before trying to use it.	**/
	var EPHIDGET_NOTATTACHED		= 0x34;

	/**[ Closed ] : Channel was closed. This can happen if a channel is closed while openWaitForAttachment is waiting.	**/
	var EPHIDGET_CLOSED				= 0x38;

	/**[ Not Configured ] : Device is not configured enough for this API call. Have a look at the must-set properties for this device and make sure to configure them first.	**/
	var EPHIDGET_NOTCONFIGURED		= 0x39;

	@:to(String)
	@:unreflective
	inline public function toString()
		return switch( this )
		{
			case EPHIDGET_OK				: "EPHIDGET_OK";
			case EPHIDGET_NOENT				: "EPHIDGET_NOENT";
			case EPHIDGET_TIMEOUT			: "EPHIDGET_TIMEOUT";
			case EPHIDGET_INTERRUPTED		: "EPHIDGET_INTERRUPTED";
			case EPHIDGET_ACCESS			: "EPHIDGET_ACCESS";
			case EPHIDGET_BUSY				: "EPHIDGET_BUSY";
			case EPHIDGET_INVALID			: "EPHIDGET_INVALID";
			case EPHIDGET_NOSPC				: "EPHIDGET_NOSPC";
			case EPHIDGET_UNSUPPORTED		: "EPHIDGET_UNSUPPORTED";
			case EPHIDGET_INVALIDARG		: "EPHIDGET_INVALIDARG";
			case EPHIDGET_DUPLICATE			: "EPHIDGET_DUPLICATE";
			case EPHIDGET_WRONGDEVICE		: "EPHIDGET_WRONGDEVICE";
			case EPHIDGET_UNKNOWNVAL		: "EPHIDGET_UNKNOWNVAL";
			case EPHIDGET_NOTATTACHED		: "EPHIDGET_NOTATTACHED";
			case EPHIDGET_CLOSED			: "EPHIDGET_CLOSED";
			case EPHIDGET_NOTCONFIGURED		: "EPHIDGET_NOTCONFIGURED";
			default							: "";
		}
}

/////////////////////////////////////////////////////////////////////////////////////
