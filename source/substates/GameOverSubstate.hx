package substates;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import objects.Boyfriend;
import states.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var playingDeathSound:Bool = false;
	var randomGameover:Int = 1;

	public function new(x:Float, y:Float)
	{
		var daBf:String = '';
		if (PlayState.pixelStage == true)
		{
			stageSuffix = '-pixel';
			daBf = 'bf-pixel-dead';
		}
		else if (PlayState.SONG.song.toLowerCase() == 'stress')
		{
			daBf = 'bf-holding-gf-dead';
		}
		else
		{
			daBf = 'bf';
		}
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
		randomGameover = FlxG.random.int(1, 25);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			endSong();
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (PlayState.storyWeek == 7)
		{
			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
			{
				playingDeathSound = true;
				FlxG.sound.music.fadeOut(0.1, 0.2);
				FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function()
				{
					FlxG.sound.music.fadeIn(4, 1, 1);
				});
			}
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

	public function endSong() 
	{
		if (PlayState.isStoryMode)
			FlxG.switchState(new states.StoryMenuState());
		else 
			FlxG.switchState(new states.FreeplayState());

		GameStatsState.lastPlayed = PlayState.SONG.song;
		GameStatsState.icon = PlayState.gameVar.iconP2.char;
		GameStatsState.iconColour = PlayState.gameVar.dad.iconColour;

		if (!PlayState.modeUsed)
		{
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
		}
		else
		{
			GameStatsState.totalNotesHit += 0;
			GameStatsState.totalSicks += 0;
			GameStatsState.totalGoods += 0;
			GameStatsState.totalBads += 0;
			GameStatsState.totalShits += 0;
			GameStatsState.totalMisses += 0;
			GameStatsState.totalBlueballed += 0;
	
			GameStatsState.songNotesHit = 0;
			GameStatsState.songSicks = 0;
			GameStatsState.songGoods = 0;
			GameStatsState.songBads = 0;
			GameStatsState.songShits = 0;
			GameStatsState.songMisses = 0;
			GameStatsState.songBlueballed = 0;
		}
		
		GameStatsState.songBpm = PlayState.SONG.bpm;

		GameStatsState.saveGameData();

		PlayState.blueballed = 0;
		PlayState.seenCutscene = false;
		PlayState.botplay = false;
		PlayState.practiceMode = false;
		PlayState.modeUsed = false;
	}
}
