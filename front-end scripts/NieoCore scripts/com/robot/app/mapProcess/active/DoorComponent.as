package com.robot.app.mapProcess.active
{
   import com.robot.core.event.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import org.taomee.manager.*;
   
   public class DoorComponent
   {
      
      private var _door:MovieClip;
      
      private var _comp:MovieClip;
      
      private var _mapID:uint;
      
      private var _clickFroWalkPoint:Point;
      
      private var _clickPoint:Point;
      
      private var _currentComp:MovieClip;
      
      private var _dir:uint;
      
      public function DoorComponent(param1:Point, param2:uint, param3:uint, param4:DisplayObjectContainer, param5:uint, param6:uint = 0)
      {
         var targetXML:XML = null;
         var str:String = null;
         var position:Point = param1;
         var width:uint = param2;
         var height:uint = param3;
         var parent:DisplayObjectContainer = param4;
         var targetMapID:uint = param5;
         var dir:uint = param6;
         super();
         this._door = AssetsManager.getMovieClip("txtMC");
         this._door.mouseChildren = false;
         this._door.width = width;
         this._door.height = height;
         this._door.x = position.x;
         this._door.y = position.y;
         this._door.buttonMode = true;
         this._door.mouseEnabled = true;
         parent.addChild(this._door);
         this._comp = AssetsManager.getMovieClip("txtMC");
         this._comp.mouseChildren = false;
         this._comp.width = this._comp.height = 34;
         this._comp.x = 0;
         this._comp.y = 0;
         this._door.addChild(this._comp);
         this._mapID = targetMapID;
         this._dir = dir;
         this._door.addEventListener(MouseEvent.CLICK,this.clickHandler);
         targetXML = MapConfig.XML_DATA.map.(@id == _mapID)[0];
         if(Boolean(targetXML))
         {
            ToolTipManager.add(this._door,targetXML.@name);
         }
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,this.onMapChange);
      }
      
      private function onMapChange(param1:MapEvent) : void
      {
         this.destroy();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         if(Boolean(this._currentComp))
         {
            this.delEnterFrame();
         }
         this._clickPoint = this._door.localToGlobal(new Point());
         this._clickFroWalkPoint = new Point(this._door.x,this._door.y);
         this._currentComp = this._door;
         if(Boolean(this._currentComp))
         {
            this.addEnterFrame();
         }
      }
      
      public function delEnterFrame() : void
      {
         if(Boolean(this._currentComp))
         {
            this._currentComp.removeEventListener(Event.ENTER_FRAME,this.checkHit);
         }
         this._currentComp = null;
      }
      
      private function addEnterFrame() : void
      {
         MainManager.actorModel.walkAction(this._clickFroWalkPoint);
         this._door.addEventListener(Event.ENTER_FRAME,this.checkHit);
      }
      
      private function checkHit(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:MovieClip = this._comp;
         var _loc4_:Point = MainManager.actorModel.sprite.localToGlobal(new Point());
         if(Point.distance(_loc4_,this._clickPoint) < 15)
         {
            if(this.getIsFB(this._mapID))
            {
               MapManager.styleID = this._mapID;
               MapManager.changeMap(50000,this._dir,MapType.getFbTypeID(this._mapID));
            }
            else
            {
               MapManager.changeMap(this._mapID,this._dir);
            }
            MainManager.actorModel.skeleton.stop();
            this.delEnterFrame();
         }
      }
      
      public function getIsFB(param1:uint) : Boolean
      {
         var xml:XML = null;
         var mapID:uint = param1;
         try
         {
            xml = null;
            xml = MapConfig.XML_DATA.elements("map").(@id == mapID)[0];
            return Boolean(xml.@isFB.toString());
         }
         catch(error:Error)
         {
            return false;
         }
      }
      
      public function destroy() : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,this.onMapChange);
         this._door.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         ToolTipManager.remove(this._door);
      }
   }
}

