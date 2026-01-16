package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.controller.MapController;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.mode.MapModel;
   import com.robot.core.net.ConnectionType;
   import com.robot.core.net.SocketConnection;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import org.taomee.manager.EventManager;
   
   [Event(name="mapMouseDown",type="com.robot.core.event.MapEvent")]
   [Event(name="mapSwitchOpen",type="com.robot.core.event.MapEvent")]
   [Event(name="mapSwitchComplete",type="com.robot.core.event.MapEvent")]
   [Event(name="mapLoaderOpen",type="com.robot.core.event.MapEvent")]
   [Event(name="mapLoaderClose",type="com.robot.core.event.MapEvent")]
   [Event(name="mapLoaderComplete",type="com.robot.core.event.MapEvent")]
   [Event(name="mapInit",type="com.robot.core.event.MapEvent")]
   [Event(name="error",type="flash.events.ErrorEvent")]
   public class MapManager
   {
      
      public static var currentMap:MapModel;
      
      public static var styleID:uint;
      
      public static var initPos:Point;
      
      public static var prevMapID:uint;
      
      public static var isInMap:Boolean;
      
      private static var _mapType:uint;
      
      private static var _mapController:MapController;
      
      private static var instance:EventDispatcher;
      
      public static const FRESH_TRIALS:uint = 600;
      
      public static const TOWER_MAP:uint = 500;
      
      public static const ID_MAX:uint = 10000;
      
      public static const TYPE_MAX:uint = 200;
      
      public static const defaultID:uint = 1;
      
      public static const defaultRoomStyleID:uint = 500001;
      
      public static const defaultArmStyleID:uint = 800001;
      
      public static var type:int = ConnectionType.MAIN;
      
      public static var DESTROY_SWITCH:Boolean = true;
      
      setup();
      
      public function MapManager()
      {
         super();
      }
      
      public static function setup() : void
      {
         getMapController();
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightClose);
      }
      
      private static function onFightClose(param1:PetFightEvent) : void
      {
         if(!DESTROY_SWITCH)
         {
            SocketConnection.send(CommandID.LIST_MAP_PLAYER);
         }
      }
      
      public static function getMapController() : MapController
      {
         if(_mapController == null)
         {
            _mapController = new MapController();
         }
         return _mapController;
      }
      
      public static function getResMapID(param1:uint) : uint
      {
         if(param1 > MapManager.ID_MAX)
         {
            return styleID;
         }
         return param1;
      }
      
      public static function changeMap(param1:int, param2:int = 0, param3:uint = 0) : void
      {
         var _loc4_:* = getDefinitionByName("com.robot.app.task.noviceGuide.CheckGuideTaskStatus");
         if(Boolean(_loc4_.check(param1)))
         {
            _mapType = param3;
            getMapController().changeMap(param1,param2,param3);
         }
      }
      
      public static function changeLocalMap(param1:uint) : void
      {
         getMapController().changeLocalMap(param1);
      }
      
      public static function refMap(param1:Boolean = true) : void
      {
         if(DESTROY_SWITCH)
         {
            getMapController().refMap(param1);
         }
      }
      
      public static function destroy() : void
      {
         if(DESTROY_SWITCH)
         {
            getMapController().destroy();
         }
      }
      
      public static function getObjectsPointRect(param1:Point, param2:Number = 10, param3:Array = null) : Array
      {
         var _loc4_:Array = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:Class = null;
         if(!isInMap)
         {
            return _loc4_;
         }
         var _loc7_:DisplayObjectContainer = currentMap.depthLevel;
         var _loc8_:int = _loc7_.numChildren;
         _loc4_ = [];
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc5_ = _loc7_.getChildAt(_loc9_);
            if(param3 == null)
            {
               if(Point.distance(new Point(_loc5_.x,_loc5_.y),param1) < param2)
               {
                  _loc4_.push(_loc5_);
               }
            }
            else
            {
               for each(_loc6_ in param3)
               {
                  if(_loc5_ is _loc6_)
                  {
                     if(Point.distance(new Point(_loc5_.x,_loc5_.y),param1) < param2)
                     {
                        _loc4_.push(_loc5_);
                     }
                     break;
                  }
               }
            }
            _loc9_++;
         }
         return _loc4_;
      }
      
      public static function getObjectPoint(param1:Point, param2:Array = null) : DisplayObject
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:Class = null;
         if(!isInMap)
         {
            return null;
         }
         var _loc5_:DisplayObjectContainer = currentMap.depthLevel;
         var _loc6_:int = _loc5_.numChildren - 1;
         var _loc7_:int = _loc6_;
         while(_loc7_ >= 0)
         {
            _loc3_ = _loc5_.getChildAt(_loc7_);
            if(param2 == null)
            {
               if(_loc3_.hitTestPoint(param1.x,param1.y))
               {
                  return _loc3_;
               }
            }
            else
            {
               for each(_loc4_ in param2)
               {
                  if(_loc3_ is _loc4_)
                  {
                     if(_loc3_.hitTestPoint(param1.x,param1.y))
                     {
                        return _loc3_;
                     }
                     break;
                  }
               }
            }
            _loc7_--;
         }
         return null;
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(instance == null)
         {
            instance = new EventDispatcher();
         }
         return instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            getInstance().dispatchEvent(param1);
         }
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
   }
}

