package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class GameplayOptionsSubState extends OptionsSubState
{
	public function new()
	{
		super();
	}

    override function update(elapsed:Float) 
    {
		super.update(elapsed);

        if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
    }
}
