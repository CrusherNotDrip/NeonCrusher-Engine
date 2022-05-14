package;

import lime.app.Application;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Events { //These are easy as fuck to code but whatever LOL
    var gameZoom:Float = 0;
    var hudZoom:Float = 0;
    public static var appName = "Friday Night Funkin': NeonCrusher Engine";

    public static function addCamZoom(gameZoom:Float, hudZoom:Float) {
        FlxG.camera.zoom += gameZoom;
        PlayState.camHUD.zoom += hudZoom;
    }

    public static function changeAppName(newAppName:String) {
        Application.current.window.title = newAppName;
    }

    public static function visibleHud(hudAlpha:Float, time:Float) {
        FlxTween.tween(PlayState.camHUD, {alpha: hudAlpha}, time, {ease: FlxEase.quadInOut});
    }
}