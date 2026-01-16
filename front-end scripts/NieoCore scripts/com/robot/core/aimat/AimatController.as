package com.robot.core.aimat
{
   import com.robot.core.config.xml.AimatXMLInfo;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.AimatUIManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.utils.setTimeout;
   import org.taomee.ds.HashSet;
   import org.taomee.manager.CursorManager;
   
   public class AimatController
   {
      
      public static var type:uint;
      
      private static var itemID:uint;
      
      private static var _instance:EventDispatcher;
      
      private static var _isAllow:Boolean = true;
      
      private static var _list:HashSet = new HashSet();
      
      public function AimatController()
      {
         super();
      }
      
      public static function addAimat(param1:IAimat) : void
      {
         _list.add(param1);
      }
      
      public static function removeAimat(param1:IAimat) : void
      {
         _list.remove(param1);
      }
      
      public static function destroy() : void
      {
         _list.each2(function(param1:IAimat):void
         {
            param1.destroy();
            param1 = null;
         });
         _list.clear();
      }
      
      public static function start(param1:uint) : void
      {
         var _itemID:uint = param1;
         if(!_isAllow)
         {
            return;
         }
         _isAllow = false;
         itemID = _itemID;
         setTimeout(function():void
         {
            _isAllow = true;
         },1000);
         dispatchEvent(AimatEvent.OPEN,new AimatInfo(type,MainManager.actorID));
         CursorManager.setCursor(UIManager.getSprite("Cursor_AimatSkin"));
         LevelManager.mapLevel.mouseChildren = false;
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMove);
         LevelManager.mapLevel.addEventListener(MouseEvent.CLICK,onClick);
      }
      
      public static function close() : void
      {
         CursorManager.removeCursor();
         LevelManager.mapLevel.mouseChildren = true;
         LevelManager.mapLevel.removeEventListener(MouseEvent.CLICK,onClick);
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMove);
         dispatchEvent(AimatEvent.CLOSE,new AimatInfo(type,MainManager.actorID));
      }
      
      public static function setClothType(param1:Array) : void
      {
         type = AimatXMLInfo.getType(param1);
      }
      
      public static function getResEffect(param1:uint, param2:String = "") : MovieClip
      {
         return AimatUIManager.getMovieClip("Aimat_Effect_" + param1.toString() + param2);
      }
      
      public static function getResSound(param1:uint, param2:String = "") : Sound
      {
         return AimatUIManager.getSound("Aimat_Sound_" + param1.toString() + param2);
      }
      
      public static function getResState(param1:uint, param2:String = "") : MovieClip
      {
         return AimatUIManager.getMovieClip("Aimat_State_" + param1.toString() + param2);
      }
      
      private static function onMove(param1:MouseEvent) : void
      {
         MainManager.actorModel.direction = Direction.getStr(MainManager.actorModel.pos,new Point(LevelManager.stage.mouseX,LevelManager.stage.mouseY));
      }
      
      private static function onClick(param1:MouseEvent) : void
      {
         close();
         MainManager.actorModel.aimatAction(itemID,type,new Point(LevelManager.mapLevel.mouseX,LevelManager.mapLevel.mouseY));
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:String, param2:AimatInfo) : void
      {
         getInstance().dispatchEvent(new AimatEvent(param1,param2));
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

