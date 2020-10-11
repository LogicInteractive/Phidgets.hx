package;

import no.logic.fox.Fox;
import no.logic.fox.core.system.Tick;
import phidgets.PhidgetRFID;

class Main
{
	/////////////////////////////////////////////////////////////////////////////////////

	static function main()
	{
		var rfid:PhidgetRFID = new PhidgetRFID();
		rfid.onTag = (tag:String)->trace('Tag: $tag');
		rfid.onTagLost = (tag:String)->trace('Tag lost: $tag');

		Tick.idle();
	}

	/////////////////////////////////////////////////////////////////////////////////////

}
