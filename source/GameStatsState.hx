package;

import flixel.tweens.FlxEase;
import ui.PreferencesMenu;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class GameStatsState extends MusicBeatState
{
    public static var lastPlayed:String = "None";
    public static var icon:String = "face";
    public static var iconColour:Int = 0xFFA1A1A1;

    public static var totalNotesHit:Float = 0;
    public static var totalSicks:Float = 0;
    public static var totalGoods:Float = 0;
    public static var totalBads:Float = 0;
    public static var totalShits:Float = 0;
    public static var totalMisses:Float = 0;
    public static var totalBlueballed:Float = 0;

    public static var songNotesHit:Float = 0;
    public static var songSicks:Float = 0;
    public static var songGoods:Float = 0;
    public static var songBads:Float = 0;
    public static var songShits:Float = 0;
    public static var songMisses:Float = 0;
    public static var songBlueballed:Float = 0;

    public static var songBpm:Int = 102;

    var bg:FlxSprite;
    var bgLane:FlxSprite;
    var lastPlayedIcon:HealthIcon;

    var daStats:FlxText;
    var daStatsAlt:FlxText;

    override function create()
    {
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = iconColour;
        bg.scrollFactor.set();  
        bg.screenCenter();
        add(bg);

        bgLane = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgLane.scale.x = 0.8;
        bgLane.alpha = 0.5;
        bgLane.scrollFactor.set();
        bgLane.screenCenter(X);
        add(bgLane);

        var lastPlayedText:Alphabet = new Alphabet(0, 30, "Last Played: " + lastPlayed, true, false);
        lastPlayedText.scrollFactor.set();
        lastPlayedText.screenCenter(X);
        add(lastPlayedText);

        daStats = new FlxText(0, 0, FlxG.width, 
        "Total Notes Hit (Global): " + totalNotesHit +
        "\nTotal Sicks Hit (Global): " + totalSicks +
        "\nTotal Goods Hit (Global): " + totalGoods +
        "\nTotal Bads Hit (Global): " + totalBads +
        "\nTotal Shits Hit (Global): " + totalShits +
        "\nTotal Misses (Global): " + totalMisses +
        "\nTotal Blueballs (Global): " + totalBlueballed,
        50);
        daStats.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        daStats.borderSize = 2;
        daStats.borderQuality = 2;
        daStats.scrollFactor.set();
        daStats.screenCenter(Y);
        add(daStats);

        daStatsAlt = new FlxText(900, 0, FlxG.width, 
        "Total Notes Hit (Song): " + songNotesHit +
        "\nTotal Sicks Hit (Song): " + songSicks +
        "\nTotal Goods Hit (Song): " + songGoods +
        "\nTotal Bads Hit (Song): " + songBads +
        "\nTotal Shits Hit (Song): " + songShits +
        "\nTotal Misses (Song): " + songMisses +
        "\nTotal Blueballs (Song): " + songBlueballed,
        50);
        daStatsAlt.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        daStatsAlt.borderSize = 2;
        daStatsAlt.borderQuality = 2;
        daStatsAlt.scrollFactor.set();
        daStatsAlt.screenCenter(Y);
        daStatsAlt.alpha = 0.5;
        add(daStatsAlt);

        lastPlayedIcon = new HealthIcon(icon, false);
        lastPlayedIcon.animation.play("lose", true);
        lastPlayedIcon.scrollFactor.set();
        lastPlayedIcon.y = 550;
        lastPlayedIcon.screenCenter(X);
        add(lastPlayedIcon);

        if (lastPlayed != 'None')
        {
            FlxG.sound.playMusic(Paths.inst(lastPlayed), 1);
            Conductor.changeBPM(songBpm);
        }

        super.create();
    }

    var statsGlobalTween:FlxTween;
    var statsSongTween:FlxTween;

    override function update(elapsed:Float) 
    {
        if (PreferencesMenu.getPref('camera-zoom'))
            FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.7);
        
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if(controls.UI_LEFT && daStats.x == -900 && daStatsAlt.x == 0)
        {
            daStats.alpha = 1;
            daStatsAlt.alpha = 0.5;

            statsGlobalTween = FlxTween.tween(daStats, {x: 0}, 0.1);
            statsSongTween = FlxTween.tween(daStatsAlt, {x: 900}, 0.1);
        }

        if(controls.UI_RIGHT && daStats.x == 0 && daStatsAlt.x == 900)
        {
            daStatsAlt.alpha = 1;
            daStats.alpha = 0.5;

            statsGlobalTween = FlxTween.tween(daStats, {x: -900}, 0.1);
            statsSongTween = FlxTween.tween(daStatsAlt, {x: 0}, 0.1);
        }

        if(controls.BACK)
        {
            if (lastPlayed != 'None')
            {
                FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
                Conductor.changeBPM(102);
            }
            FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    override function beatHit() 
    {
        if (lastPlayedIcon.scale.x == 1.2 || lastPlayedIcon.scale.y == 1.2) {
            lastPlayedIcon.scale.x = 1;
            lastPlayedIcon.scale.y = 1;
        }

        FlxTween.tween(lastPlayedIcon, {"scale.x": 1.2, "scale.y": 1.2}, 0.3, {ease: FlxEase.circInOut, type: FlxTweenType.BACKWARD});

        if (PreferencesMenu.getPref('camera-zoom'))
        {
		    if (lastPlayed.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && FlxG.camera.zoom < 1.35)
			    FlxG.camera.zoom += 0.03;

		    if (curBeat % 4 == 0 && FlxG.camera.zoom < 1.35)
			    FlxG.camera.zoom += 0.03;
        }
    }

    public static function saveGameData() 
    {
        FlxG.save.data.lastPlayed = lastPlayed;
        FlxG.save.data.icon = icon;
        FlxG.save.data.iconColour = iconColour;
        FlxG.save.data.totalNotesHit = totalNotesHit;
        FlxG.save.data.totalSicks = totalSicks;
        FlxG.save.data.totalGoods = totalGoods;
        FlxG.save.data.totalBads = totalBads;
        FlxG.save.data.totalShits = totalShits;
        FlxG.save.data.totalMisses = totalMisses;
        FlxG.save.data.totalBlueballed = totalBlueballed;
        FlxG.save.data.songNotesHit = songNotesHit;
        FlxG.save.data.songSicks = songSicks;
        FlxG.save.data.songGoods = songGoods;
        FlxG.save.data.songBads = songBads;
        FlxG.save.data.songShits = songShits;
        FlxG.save.data.songMisses = songMisses;
        FlxG.save.data.songBlueballed = songBlueballed;
        FlxG.save.data.songBpm = songBpm;

		FlxG.save.flush();
    }

    public static function loadGameData() 
    {
        if(FlxG.save.data.lastPlayed != null) 
            lastPlayed = FlxG.save.data.lastPlayed;
        if(FlxG.save.data.icon != null) 
			icon = FlxG.save.data.icon;
        if(FlxG.save.data.iconColour != null) 
			iconColour = FlxG.save.data.iconColour;
        if(FlxG.save.data.totalNotesHit != null)
			totalNotesHit = FlxG.save.data.totalNotesHit;
        if(FlxG.save.data.totalSicks != null)
			totalSicks = FlxG.save.data.totalSicks;
        if(FlxG.save.data.totalGoods != null)
			totalGoods = FlxG.save.data.totalGoods;
        if(FlxG.save.data.totalBads != null)
			totalBads = FlxG.save.data.totalBads;
        if(FlxG.save.data.totalShits != null)
			totalShits = FlxG.save.data.totalShits;
        if(FlxG.save.data.totalMisses != null)
			totalMisses = FlxG.save.data.totalMisses;
        if(FlxG.save.data.totalBlueballed != null)
			totalBlueballed = FlxG.save.data.totalBlueballed;
        if(FlxG.save.data.songNotesHit != null)
			songNotesHit = FlxG.save.data.songNotesHit;
        if(FlxG.save.data.songSicks != null)
			songSicks = FlxG.save.data.songSicks;
        if(FlxG.save.data.songGoods != null)
			songGoods = FlxG.save.data.songGoods;
        if(FlxG.save.data.songBads != null)
			songBads = FlxG.save.data.songBads;
        if(FlxG.save.data.songShits != null)
			songShits = FlxG.save.data.songShits;
        if(FlxG.save.data.songMisses != null)
			songMisses = FlxG.save.data.songMisses;
        if(FlxG.save.data.songBlueballed != null)
			songBlueballed = FlxG.save.data.songBlueballed;
        if(FlxG.save.data.songBpm != null)
            songBpm = FlxG.save.data.songBpm;
    } 
}