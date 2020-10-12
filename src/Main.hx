package;

import no.logic.fox.Fox;
import no.logic.fox.core.system.Tick;
import phidgets.Phidget;
import phidgets.PhidgetRFID;

class Main
{
	/////////////////////////////////////////////////////////////////////////////////////

	static function main()
	{
		var rfid:PhidgetRFID = new PhidgetRFID();
		rfid.onAttach = ()->trace('RFID attached!');
		rfid.onDetach = ()->trace('RFID detached!');
		rfid.onTag = (tag:String)->trace('Tag: $tag');
		rfid.onTagLost = (tag:String)->trace('Tag lost: $tag');

		Tick.idle();
	}

	/////////////////////////////////////////////////////////////////////////////////////

}
