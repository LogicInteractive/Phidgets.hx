package phidgets;

enum abstract PhidgetRFIDProtocol(Int) from Int to Int
{
	/** EM4100 **/
	var PROTOCOL_EM4100				= 0x1;

	/** Unsupported	**/
	var PROTOCOL_ISO11785_FDX_B		= 0x2;

	/** Unsupported **/
	var PROTOCOL_PHIDGETS			= 0x3;

	@:to(String)
	@:unreflective
	inline public function toString()
		return switch( this )
		{
			case PROTOCOL_EM4100			: "PROTOCOL_EM4100";
			case PROTOCOL_ISO11785_FDX_B	: "PROTOCOL_ISO11785_FDX_B";
			case PROTOCOL_PHIDGETS			: "PROTOCOL_PHIDGETS";
			default							: "";
		}
}

/////////////////////////////////////////////////////////////////////////////////////