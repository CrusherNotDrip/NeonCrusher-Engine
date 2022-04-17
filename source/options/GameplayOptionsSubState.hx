package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class GameplayOptionsSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

    override function update(elapsed:Float) 
    {
		super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
    }
}
