package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		if (PlayState.isStoryMode)
			FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Story Mode) - PAUSED");
		else
			FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Freeplay) - PAUSED");

		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedText:FlxText = new FlxText(20, 15 + 64, 0, "Blueballed: ", 32);
		blueballedText.text += PlayState.blueballed; 
		blueballedText.scrollFactor.set();
		blueballedText.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedText.updateHitbox();
		add(blueballedText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		blueballedText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedText.x = FlxG.width - (blueballedText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedText, {alpha: 1, y: blueballedText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
					if (PlayState.isStoryMode)
						FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Story Mode)");
					else
						FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Freeplay)");
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					endSong();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function endSong() 
	{
		if (PlayState.isStoryMode)
			FlxG.switchState(new StoryMenuState());
		else 
			FlxG.switchState(new FreeplayState());

		GameStatsState.lastPlayed = PlayState.SONG.song;
		GameStatsState.icon = PlayState.gameVar.iconP2.char;
		GameStatsState.iconColour = PlayState.gameVar.dad.iconColour;

		GameStatsState.totalNotesHit += PlayState.gameVar.songHits;
		GameStatsState.totalSicks += PlayState.gameVar.sicks;
		GameStatsState.totalGoods += PlayState.gameVar.goods;
		GameStatsState.totalBads += PlayState.gameVar.bads;
		GameStatsState.totalShits += PlayState.gameVar.shits;
		GameStatsState.totalMisses += PlayState.gameVar.songMisses;
		GameStatsState.totalBlueballed += PlayState.blueballed;

		GameStatsState.songNotesHit = PlayState.gameVar.songHits;
		GameStatsState.songSicks = PlayState.gameVar.sicks;
		GameStatsState.songGoods = PlayState.gameVar.goods;
		GameStatsState.songBads = PlayState.gameVar.bads;
		GameStatsState.songShits = PlayState.gameVar.shits;
		GameStatsState.songMisses = PlayState.gameVar.songMisses;
		GameStatsState.songBlueballed = PlayState.blueballed;		

		GameStatsState.songBpm = PlayState.SONG.bpm;

		GameStatsState.saveGameData();

		PlayState.blueballed = 0;
		PlayState.seenCutscene = false;
	}
}
