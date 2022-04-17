package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

class ControlsSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

    override function update(elapsed:Float) 
    {
        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
    }
}
