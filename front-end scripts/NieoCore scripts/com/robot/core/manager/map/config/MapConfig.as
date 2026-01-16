package com.robot.core.manager.map.config
{
   import com.robot.core.SoundManager;
   import com.robot.core.event.MapConfigEvent;
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.MapType;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.ToolTipManager;
   
   public class MapConfig
   {
      
      private static var currentComp:MovieClip;
      
      private static var clickPoint:Point;
      
      private static var clickFroWalkPoint:Point;
      
      private static var xmlCls:Class = MapConfig_xmlCls;
      
      public static var XML_DATA:XML = XML(new xmlCls());
      
      private static const ENTRIES:String = "Entries";
      
      private static const AUTO_COMP:String = "autoComp";
      
      private static var compArray:Array = [];
      
      public function MapConfig()
      {
         super();
      }
      
      public static function setup() : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onMapChange);
      }
      
      public static function clear() : void
      {
         onMapChange(null);
      }
      
      private static function onMapChange(param1:MapEvent) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in compArray)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,autoEnterFrame);
            _loc2_.removeEventListener(MouseEvent.CLICK,clickHandler);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,overHandler);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,outHandler);
            ToolTipManager.remove(_loc2_);
         }
         compArray = [];
      }
      
      public static function configMap(param1:int) : void
      {
         var name:String = null;
         var hit:String = null;
         var mc:MovieClip = null;
         var count:int = 0;
         var xml:XML = null;
         var xmllist:XMLList = null;
         var i:XML = null;
         var dir:int = 0;
         var targetID:int = 0;
         var fun:String = null;
         var hitMC:MovieClip = null;
         var targetXML:XML = null;
         var str:String = null;
         var mapID:int = param1;
         name = null;
         hit = null;
         mc = null;
         SoundManager.playSound();
         compArray = [];
         mapID = int(MapManager.getResMapID(mapID));
         xml = XML_DATA.map.(@id == mapID)[0];
         xmllist = xml.descendants("component");
         count = 0;
         var _loc3_:int = 0;
         var _loc4_:* = xmllist;
         for(; §§hasnext(_loc4_,_loc3_); compArray.push(mc))
         {
            i = §§nextvalue(_loc3_,_loc4_);
            name = i.@name;
            hit = i.@hit;
            dir = int(i.@dir);
            targetID = int(i.@targetID);
            fun = i.@fun;
            mc = MapManager.currentMap.controlLevel.getChildByName(name) as MovieClip;
            hitMC = MapManager.currentMap.controlLevel.getChildByName(hit) as MovieClip;
            try
            {
               if(mc != hitMC)
               {
                  hitMC.mouseEnabled = false;
                  hitMC.mouseChildren = false;
               }
               hitMC["compMC"] = mc;
               mc.buttonMode = true;
               mc.mouseChildren = false;
               mc.gotoAndStop(1);
            }
            catch(e:Error)
            {
               throw new Error(mapID + "号地图配置有误,comp name:" + name + " hit name:" + hit);
            }
            mc["hitMC"] = hitMC;
            mc["des"] = i.@des.toString();
            mc["isStop"] = uint(i.@isStop);
            mc["isOnce"] = uint(i.@isOnce);
            hitMC.dir = dir;
            hitMC.targetID = targetID;
            hitMC.fun = fun;
            if(XML(i.parent()).name() == AUTO_COMP)
            {
               mc.mouseEnabled = false;
               initAutoEvent(mc);
            }
            else
            {
               mc.addEventListener(MouseEvent.CLICK,clickHandler);
               mc.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
               mc.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
               targetXML = XML_DATA.map.(@id == targetID)[0];
               if(Boolean(targetXML))
               {
                  ToolTipManager.add(mc,targetXML.@name);
               }
               else if(mc["des"] != "" && mc["des"] != null && mc["des"].length > 0)
               {
                  try
                  {
                     str = mc["des"].replace(/\$/g,"\r");
                     ToolTipManager.add(mc,str);
                  }
                  catch(e:Error)
                  {
                  }
                  continue;
               }
            }
         }
         DepthManager.swapDepthAll(MapManager.currentMap.depthLevel);
      }
      
      private static function initAutoEvent(param1:MovieClip) : void
      {
         param1.addEventListener(Event.ENTER_FRAME,autoEnterFrame);
      }
      
      private static function autoEnterFrame(param1:Event) : void
      {
         var mc:MovieClip = null;
         var hitMC:MovieClip = null;
         var event:Event = param1;
         mc = null;
         hitMC = null;
         mc = event.currentTarget as MovieClip;
         hitMC = mc["hitMC"];
         var pp:Point = MainManager.actorModel.sprite.localToGlobal(new Point());
         if(hitMC.hitTestPoint(pp.x,pp.y,true))
         {
            if(!mc.isHit)
            {
               mc.isHit = true;
               if(mc["isOnce"] == 1)
               {
                  mc.removeEventListener(Event.ENTER_FRAME,autoEnterFrame);
               }
               try
               {
                  MapProcessConfig.currentProcessInstance[hitMC["fun"]]();
               }
               catch(e:Error)
               {
                  MapProcessConfig.currentProcessInstance[hitMC["fun"]](mc);
               }
            }
         }
         else
         {
            mc.isHit = false;
         }
      }
      
      private static function overHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_["isStop"] == 0)
         {
            _loc2_.gotoAndStop(2);
         }
      }
      
      private static function outHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_["isStop"] == 0)
         {
            _loc2_.gotoAndStop(1);
         }
      }
      
      public static function getMapPeopleXY(param1:uint, param2:uint) : Point
      {
         var mapID:uint = param1;
         var newMapID:uint = param2;
         var xml:XML = null;
         var PX:Number = NaN;
         var PY:Number = NaN;
         mapID = MapManager.getResMapID(mapID);
         newMapID = MapManager.getResMapID(newMapID);
         xml = XML_DATA.map.(@id == newMapID)[0];
         xml = xml[ENTRIES]["Entry"].(@FromMap == mapID)[0];
         if(Boolean(xml))
         {
            PX = Number(xml.@PosX);
            PY = Number(xml.@PosY);
            return new Point(PX,PY);
         }
         xml = XML_DATA.map.(@id == newMapID)[0];
         return new Point(int(xml.@x),int(xml.@y));
      }
      
      public static function getName(param1:uint) : String
      {
         var mapID:uint = param1;
         var xml:XML = null;
         mapID = MapManager.getResMapID(mapID);
         xml = XML_DATA.elements("map").(@id == mapID)[0];
         return xml.@name.toString();
      }
      
      public static function getDes(param1:uint) : String
      {
         var mapID:uint = param1;
         var xml:XML = null;
         var str:String = null;
         mapID = MapManager.getResMapID(mapID);
         xml = XML_DATA.elements("map").(@id == mapID)[0];
         str = xml.@des.toString().replace(/\$/g,"\r");
         return str;
      }
      
      public static function getIsFB(param1:uint) : Boolean
      {
         var mapID:uint = param1;
         var xml:XML = null;
         xml = XML_DATA.elements("map").(@id == mapID)[0];
         return Boolean(xml.@isFB.toString());
      }
      
      public static function getSuperMapID(param1:uint) : uint
      {
         var mapID:uint = param1;
         var xml:XML = null;
         var id:uint = 0;
         mapID = MapManager.getResMapID(mapID);
         xml = XML_DATA.elements("map").(@id == mapID)[0];
         id = uint(xml.attribute("super"));
         if(id == 0)
         {
            id = mapID;
         }
         return id;
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         if(Boolean(currentComp))
         {
            delEnterFrame();
         }
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:MovieClip = _loc2_["hitMC"];
         _loc3_["compMC"] = _loc2_;
         clickPoint = _loc3_.localToGlobal(new Point());
         clickFroWalkPoint = new Point(_loc3_.x,_loc3_.y);
         currentComp = _loc3_;
         if(Boolean(currentComp))
         {
            addEnterFrame();
         }
      }
      
      public static function delEnterFrame() : void
      {
         if(Boolean(currentComp))
         {
            currentComp.removeEventListener(Event.ENTER_FRAME,checkHit);
         }
         currentComp = null;
      }
      
      private static function addEnterFrame() : void
      {
         MainManager.actorModel.walkAction(clickFroWalkPoint);
         currentComp.addEventListener(Event.ENTER_FRAME,checkHit);
      }
      
      private static function checkHit(param1:Event) : void
      {
         var event:Event = param1;
         var current:MovieClip = event.currentTarget as MovieClip;
         var compMC:MovieClip = current["compMC"];
         var pp:Point = MainManager.actorModel.sprite.localToGlobal(new Point());
         if(Point.distance(pp,clickPoint) < 15)
         {
            if(currentComp["fun"] == "")
            {
               if(getIsFB(currentComp["targetID"]))
               {
                  if(MainManager.actorInfo.teamInfo.id < 50000)
                  {
                     Alarm.show("海盗训练场里机关重重异常危险，你需要组织战队前去侦查。");
                  }
                  else
                  {
                     MapManager.styleID = currentComp["targetID"];
                     MapManager.changeMap(MainManager.actorInfo.teamInfo.id,currentComp["dir"],MapType.getFbTypeID(currentComp["targetID"]));
                  }
               }
               else
               {
                  MapManager.dispatchEvent(new MapConfigEvent(MapConfigEvent.HIT_MAP_COMPONENT,currentComp));
                  MapManager.changeMap(currentComp["targetID"],currentComp["dir"]);
               }
            }
            else
            {
               try
               {
                  MapProcessConfig.currentProcessInstance[currentComp["fun"]](compMC);
               }
               catch(e:Error)
               {
                  MapProcessConfig.currentProcessInstance[currentComp["fun"]]();
               }
            }
            MainManager.actorModel.skeleton.stop();
            delEnterFrame();
         }
      }
   }
}

