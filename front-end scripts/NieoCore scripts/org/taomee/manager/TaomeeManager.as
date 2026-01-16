package org.taomee.manager
{
   import com.robot.core.manager.*;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.net.SharedObject;
   
   public class TaomeeManager
   {
      
      private static var _root:DisplayObjectContainer;
      
      public static var stageHeight:int;
      
      public static var stageWidth:int;
      
      private static var _stage:Stage;
      
      public static var fightSpeed:Number = 1;
      
      public function TaomeeManager()
      {
         super();
      }
      
      public static function set root(param1:DisplayObjectContainer) : void
      {
         _root = param1;
      }
      
      public static function get root() : DisplayObjectContainer
      {
         return _root;
      }
      
      public static function get stage() : Stage
      {
         return _stage;
      }
      
      public static function set stage(param1:Stage) : void
      {
         _stage = param1;
      }
      
      public static function setup(param1:DisplayObjectContainer, param2:Stage) : void
      {
         _root = param1;
         _stage = param2;
      }
      
      public static function initFightSpeed() : void
      {
         var _loc1_:SharedObject = SOManager.getUserSO(SOManager.LOCAL_CONFIG);
         if(!_loc1_.data["speed"])
         {
            _loc1_.data["speed"] = 3;
            SOManager.flush(_loc1_);
         }
         else
         {
            fightSpeed = _loc1_.data["speed"];
         }
      }
   }
}

