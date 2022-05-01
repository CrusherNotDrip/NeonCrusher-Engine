package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> = ['Controls', 'Gameplay'];

	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

	var arrowLeft:Alphabet;
	var arrowRight:Alphabet;

	public function new()
	{
		super();

		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

		for (i in 0...textMenuItems.length)
		{
			var optionText:Alphabet = new Alphabet(0, 20 + (i * 100), textMenuItems[i], true, false);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
			optionText.screenCenter(X);
		}

		arrowLeft = new Alphabet(0, 0, '>', true, false);
		add(arrowLeft);
		arrowRight = new Alphabet(0, 0, '<', true, false);
		add(arrowRight);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
		
		if (controls.UP_P)
			curSelected -= 1;

		if (controls.DOWN_P)
			curSelected += 1;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;

		if (controls.ACCEPT)
		{
			switch (textMenuItems[curSelected])
			{
				case "Controls":
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new ControlsSubState());
				case "Gameplay":
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new GameplayOptionsSubState());
			}
		}
	}
}
