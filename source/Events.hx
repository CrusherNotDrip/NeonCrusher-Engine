package;

import lime.app.Application;
import flixel.FlxCamera;
import flixel.FlxG;

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
}