/*
Copyright (c) 2013 Kael Fraga

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package procedural;

import org.flixel.util.FlxRect;
import org.flixel.plugin.pxText.PxBitmapFont.HelperSymbol;
import org.flixel.util.FlxRandom;
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRect;

/**
 * ...
 * @author Kael Fraga
 */
class DungeonGenerator
{
	private var MapWidth:Int;
	private var MapHeight:Int;
	private var NumRooms:Int;
	private var _Map:Array<Array<Int>>; //the map matrix
	private var _MidPoints:Array<FlxPoint>; //center of all rooms
	private var column:Int;
	private	var row:Int;
	private	var AddExit:Bool; 
	private var _Rooms:Array<FlxRect>; //array of dungeon rooms
		
	/**
	 * 
	 * @param	nCols	Number of columns in the cave tilemap
	 * @param	nRows	Number of rows in the cave tilemap
	 * @param	nRooms  Number of rooms in the each dungeon
	 * @param	exit	If there is or is not a exit on extreme right
	 */	
	public function new(nCols:Int = 10, nRows:Int = 10, nRooms:Int=5, exit:Bool = false) 
	{
		MapWidth = nCols;
		MapHeight = nRows;
		NumRooms = nRooms;
		AddExit = exit;
	}
	
	/**
	 * @param 	mat		A matrix of data
	 * 
	 * @return 	A string that is usuable for FlxTileMap.loadMap(...)
	 */
	static public function convertMatrixToStr(mat:Array<Array<Int>>):String
	{
		var mapString:String = "";
		
		for (y in 0...(mat.length))
		{
			for (x in 0...(mat[y].length))
			{
				mapString += Std.string(mat[y][x]);
				if (x < mat[y].length - 1) {
					mapString += ",";
				}
			}
			
			mapString += "\n";
		}
		
		return mapString;
	}	
	
	/*
		Initializes the map matrix full of walls, after creates the rooms, 
		connect each other and for last if must exist a exit, creates the exit
	*/	
	private function InitMap():Void
	{				
		_Map = new Array<Array<Int>>();
		_MidPoints = new Array<FlxPoint>();
		_Rooms = new Array<FlxRect>();
		
		for (row in 0...(MapHeight))
		{
			_Map[row] = new Array<Int>();
			for (column in 0...(MapWidth)) 
			{
				_Map[row][column] = 1;
			}
		}
		
		for (i in 0 ... (NumRooms)) 
			MakeRoom(i);
			
		FindRoomNear();
		
		if (AddExit) FindExit();
	}
	
	/**
	 * @param 	r	 Room number 
	*/
	private function MakeRoom(r:Int):Void
	{
			var initX:Int; //the initial position of room in X axis
			var initY:Int; //the initial position of room in Y axis
			var finX:Int; //the final position of room in X axis
			var finY:Int; //the final position of room in Y axis
			var w:Int; //the room width
			var h:Int; //the room height
			var rep:Bool = true; //loop control variable
			var c:Int = 0; //counter to limit the number of attempts to create a room 
						
			do
			{
				//The position and the size of the rooms are  random
				initX = Math.round(FlxRandom.float()*(MapWidth - 6));
				initY = Math.round(FlxRandom.float() * (MapHeight - 6));
				w = Math.round((FlxRandom.float() * (MapWidth - initX - 6)) + 5);
				h = Math.round((FlxRandom.float() * (MapHeight - initY - 6)) + 5);
				finX = w + initX;
				finY = h + initY;
				
				_Rooms[r] = new FlxRect(initX, initY, w, h); //stores the rooms properties
				
				rep = false;
				if (r > 0)
				{
					var i:Int;
					for (i in 0...(r))
					{
						if (_Rooms[r].overlaps(_Rooms[i])){
							rep = true; //if a new room overlaps an old room its properties are randomly chosen again
							break;
						}
					}
				}
				
				c++;
			}
			while (rep && c<10000); //the max of attempts is 10000
			
			var j:Int;
			for ( i in initY+1...(finY))
			{
				for (j in initX+1...(finX)) 
				{
					_Map[i][j] = 0; //"carves" the new room
				}
			}
			
			//Calculates the center of the room
			var mx:Float = (initX+finX)/2;
			var my:Float = (initY+finY)/2;
			_MidPoints.push(new FlxPoint(mx, my)); 
	}
	
	/*
	 * Connects the nearest rooms 
	*/
	private function FindRoomNear():Void
	{
		var d:Float; //the distance between two rooms
		var small:Float = 999; //stores the smaller distance between two rooms
		var target:FlxPoint = new FlxPoint (99,99); //the nearest room
		
		var i:Int = 0;
		var j:Int;
		for (i in 0 ... (NumRooms-1))
		{
			for (j in (i+1) ... (NumRooms))
			{	
				d = Math.sqrt(Math.pow((_MidPoints[i].y - _MidPoints[j].y),2)+ Math.pow((_MidPoints[i].x - _MidPoints[j].x),2));
				if (j == (i + 1))
				{ 
					small = d; //initializes the small variable
					target.x = Math.ceil(_MidPoints[j].x); 
					target.y = Math.ceil(_MidPoints[j].y);
				}
				else if (small > d)
				{
					small = d; 
					target.x = Math.ceil(_MidPoints[j].x); 
					target.y = Math.ceil(_MidPoints[j].y);
				}
			}
			
			MakeHall(i,target);
		}				
	}
	
	/**
	 * Creates the halls between rooms
	 * @param 	i			center of the chosen room
	 * @param 	target		the nearest room from the chosen room 
	*/
	private function MakeHall(i:Int,target:FlxPoint):Void
	{
		var x:Int = Math.ceil(_MidPoints[i].x);
		var y:Int = Math.ceil( _MidPoints[i].y);
		var dig:Bool = true; //removes the tiles making a hall until the center of the target room		
		
		do 
		{ 	
			if (target.x > x)
				x++;
			else if (target.x < x)
				x--;
			else if (target.y > y)
				y++;
			else
				y--;
			
			if (target.x == x && target.y == y)
				dig = false;
				
			_Map[y][x] = 0;
		} 
		while (dig);			
	}
	
	/**
	 * Finds the extreme right room
	 * same logic of FindRoomNear
	*/
	private function FindExit():Void
	{
		var d:Float;
		var small:Float = 999;
		var target:FlxPoint = new FlxPoint (99,99);
		
		var i:Int =0;
			
		for (i in 0 ... (NumRooms))
		{
			d = (MapWidth-1) - _MidPoints[i].x;
			if (i == 0)
			{ 
				small = d;
				target.x = Math.ceil(_MidPoints[i].x); 
				target.y = Math.ceil(_MidPoints[i].y);
			}
			else if (small > d)
			{
				small = d;
				target.x = Math.ceil(_MidPoints[i].x); 
				target.y = Math.ceil(_MidPoints[i].y);
			}
		}	
				
			MakeExit(target);
	}
	
	/**
	 * Creates the exit hall
	 * @param 	target	    the extreme right room
	*/
	private function MakeExit(target:FlxPoint):Void
	{
		var y:Int = Math.ceil(target.y);
		var x:Int = MapWidth;
		var dig:Bool = true;		
		
		//Removes the tiles making a hall until the extreme right of map	
		do 
		{ 	
			if (target.x > x)
				x++;
			else
				x--;
			
			if (target.x == x)
				dig = false;
				
			_Map[y][x] = 0;
		} 
		while (dig);			
	}
		
	/**
	 * @return 	The finished map to the level
	*/
	public function SendDG():Array<Array<Int>>
	{
		InitMap();
		return _Map;
	}
	
}