/*
Copyright (c) 2013 Kael Fraga

	This file is part of Mage Escape.

    Mage Escape is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Mage Escape is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Mage Escape.  If not, see <http://www.gnu.org/licenses/>.
*/
package;

import org.flixel.FlxSave;
import flash.display.Sprite;
import org.flixel.FlxTilemap;
import flash.Lib;
import org.si.sion.*;
import org.si.sion.SiONDriver;

/**
 * ...
 * @author Kael Fraga
 */

class Main extends Sprite
{
	static public var driver:SiONDriver = new SiONDriver(); //song digital signal processor emulator
	static public var _sound1:Sfxr; //explosion
	static public var _sound2:Sfxr; //death of player
	static public var _sound3:Sfxr; //pick up a item
	static public var _sound4:Sfxr; //change level
	static public var _sound5:Sfxr; //charge mp
	
	public static function main() 
	{
		new Main();
	}
	
	public function new() 
	{
		super();
		
		Reg.save = new FlxSave(); 
		Reg.save.bind("Mago");
		Reg.loadData(); //uploads the saved informations (level and score)
		
		createSounds(); //creates the sound effects
		
		Lib.current.addChild(new MageEscape());
		
	}
	
	private function createSounds():Void
	{
	
	/*
		* Sound Categories
	
		PICKUP_COIN = 1;
		LASER_SHOOT = 2;
		EXPLOSION   = 3;
		POWER_UP    = 4;
		HIT_HURT    = 5;
		JUMP        = 6;
		BLIP_SELECT = 7;
	*/
		
	/*
	 * New sound receives as parameter:
		 volume(Float), frequence(Int), bits(Int), pan(Int), random seed 1(Int), random seed 2 (Int)
	*/
		_sound1 = new Sfxr(0.5, 44100, 16, 0, 3, 8);
		_sound1.create (3); //receives as parameter the sound category
		_sound1.generate (); //creates the wave file in memory
		
		_sound2 = new Sfxr(0.5, 44100, 16, 0, 7, 1);
		_sound2.create (5);
		_sound2.generate ();
		
		_sound3 = new Sfxr(0.5, 44100, 16, 0, 1, 9);
		_sound3.create (1);
		_sound3.generate ();
		
		_sound4 = new Sfxr(0.5, 44100, 16, 0, 7, 4);
		_sound4.create (2);
		_sound4.generate ();
		
		_sound5 = new Sfxr(0.5, 44100, 16, 0, 9, 5);
		_sound5.create (4);
		_sound5.generate ();
		
	}
	
	static public function playSound(sound:String):Void
	{	
		switch(sound)
		{
			case "boom": 
				{
					//explosion sound					
					_sound1.mutate(); //creates variables in the sound
					_sound1.play (); //plays the sound
					
				}
			case "death":
				{ 
					//player death sound					
					_sound2.mutate();
					_sound2.play ();
					
				}
			case "pick": 
				{
					//getting an item sound					
					_sound3.mutate();
					_sound3.play ();
				
				}
			case "change": 
				{
					//do a trasition
					_sound4.mutate();
					_sound4.play ();
				
				}	
			case "mp": 
				{
					//mp recharge sound
					_sound5.mutate();
					_sound5.play ();
				
				}					
		}	
	}
}