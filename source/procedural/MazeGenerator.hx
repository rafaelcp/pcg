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


import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRandom;

class MazeGenerator
{
	private var MapWidth:Int;
	private var MapHeight:Int;
	private var _Map:Array<Array<Int>>;
	private var column:Int;
	private	var row:Int;
	
	public function new(nCols:Int = 10, nRows:Int = 10) 
	{
		MapWidth = nCols;
		MapHeight = nRows;
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
		
	private function InitMatrix(rows:Int, cols:Int):Void
	{
		// Build array of 1s
		_Map = new Array<Array<Int>>();
		for (y in 0...(rows))
		{
			_Map.push(new Array<Int>());
			for (x in 0...(cols)) 
			{
				_Map[y].push(1);
			}
		}
	}	
	
	private function mySort(x:Int, y:Int):Int {	
		var r:Float = FlxRandom.float();
		if (r < 1 / 3) return -1;
		else if (r < 2 / 3) return 0;
		else return 1;
	}
	
	private function runDFS(x:Int,y:Int,w:Int):Void
	{
		//trace("I RUN");
		if (!IsWall(x, y,w))
		{
			_Map[y][x] = 0;
			
			switch (w) {
				case 1: _Map[y+1][x] = 0;
				case 2:	_Map[y-1][x] = 0;
				case 3:	_Map[y][x-1] = 0;
				case 4:	_Map[y][x+1] = 0;
			}
			
			
			var options:Array<Int> = [1, 2, 3, 4];
			options.sort(mySort);
			for (i in 0 ... 4) {
				if (options[i] == 1) runDFS(x, y - 2, 1);
				if (options[i] == 2) runDFS(x, y + 2, 2);
				if (options[i] == 3) runDFS(x + 2, y, 3);
				if (options[i] == 4) runDFS(x - 2, y, 4);
			}
		}		
	}

	private function IsWall(x:Int,y:Int,w:Int):Bool
	{
		
		if( IsOutOfBounds(x,y) )
		{
			//trace("out");
			return true;
		}
		//else if( _Map[y][x]==0 )
		//{
			//trace("zero 0");
			//return true;
		//}
		else if( (_Map[y+1][x]==0) && ( w !=1 ))
		{
			//trace("zero 1");
			return true;
		}
		else if( (_Map[y][x+1]==0) && ( w !=4 ))
		{
			//trace("zero 2");
			return true;
		}
		else if( (_Map[y-1][x]==0) && ( w !=2 ))
		{
			//trace("zero 3");
			return true;
		}
		else if( (_Map[y][x-1]==0) && ( w !=3 ) )
		{
			//trace("zero 4");
			return true;
		}
		else if( _Map[y][x]==1 )
		{
			return false;
		}
	 	
		return false;
	}
 
	private function IsOutOfBounds(x:Int,y:Int):Bool
	{
		if( x<1 || y<1 )
		{
			//trace("less");
			return true;
		}
		else if( x>MapWidth-2 || y>MapHeight-2 )
		{
			//trace("high");
			return true;
		}
		return false;
	}
		
	private function MakeExit():Void
	{
		//The exit hall is a tile in the extreme right of map connected to a maze hall

		var y:Int = 1;
		var x:Int = 1;
		var targ:FlxPoint = new FlxPoint(x,y);
		
		for (x in (Math.round(MapWidth/2))...(MapWidth-1))
		{
			for (y in 2...(MapHeight-1))
			{			
				if (_Map[y][x] == 0)
				{
					targ.x = x;
					targ.y = y;
				}
			}
		}
		
		x = MapWidth;
		var dig:Bool = true;
		do 
		{ 	
			x--;
				
			if ( x == Math.round(targ.x))
				dig = false;
			
			_Map[Math.round(targ.y)][x] = 0;
		} 
		while (dig);
 		
	}
	
	public function SendMaze():Array<Array<Int>>
	{
		InitMatrix(MapHeight, MapWidth);
		
		var x:Int = 2;
		var y:Int = Math.ceil(FlxRandom.float() * (MapHeight - 4)+1);
		var w:Int = 0;
		
		//w is the direction of the WAY
		/*
		 0 = start
		 1 = up
		 2 = down
		 3 = right
		 4 = left
		 */
		 
		runDFS(x, y, w);
		
		MakeExit();
		
		return _Map;
	}
}