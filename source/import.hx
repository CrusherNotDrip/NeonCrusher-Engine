import Paths;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import addons.*;
#if DISCORD_RPC
import addons.Discord.DiscordClient;
#end

import conductor.*;
import conductor.Conductor.BPMChangeEvent;
import controls.*;

import shaders.*;

import objects.Alphabet;
import objects.BGSprite;

import options.PreferencesMenu;

import states.GameStatsState;
import states.LoadingState;
import states.PlayState;

using StringTools;