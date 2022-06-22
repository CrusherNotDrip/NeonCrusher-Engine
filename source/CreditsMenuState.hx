package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import Controls;

class CreditsMenuState extends MusicBeatState
{
    var bg:FlxSprite;
    var notFinishedTxt:FlxText;
    var control:Controls;

    override public function create()
    {
        #if DISCORD_RPC
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits Menu", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

        notFinishedTxt = new FlxText(0, 0, FlxG.width, "THIS MENU ISN'T DONE YET! PRESS ESC TO GO BACK TO THE MAIN MENU", 48);
		notFinishedTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		notFinishedTxt.scrollFactor.set();
		notFinishedTxt.borderSize = 2;
		add(notFinishedTxt);
		notFinishedTxt.screenCenter();

        super.create();
    }

    var notFinishedSine:Float = 0;

    override public function update(elapsed:Float)
    {
        notFinishedSine += 180 * elapsed;
		notFinishedTxt.alpha = 1 - Math.sin((Math.PI * notFinishedSine) / 180);

        if(control.BACK) {
            FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}