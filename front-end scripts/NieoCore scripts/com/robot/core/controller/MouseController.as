package com.robot.core.controller
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.mode.MapModel;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import org.taomee.utils.MovieClipUtil;
   
   public class MouseController
   {
      
      private static var _mouseTxt:TextField;
      
      public static var CanMove:Boolean = true;
      
      private static var lastPos:Point = new Point(0,0);
      
      public function MouseController()
      {
         super();
      }
      
      public static function addMouseEvent() : void
      {
         MapManager.currentMap.spaceLevel.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
      }
      
      public static function removeMouseEvent() : void
      {
         MapManager.currentMap.spaceLevel.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
      }
      
      private static function showMouseXY() : void
      {
         if(_mouseTxt == null)
         {
            _mouseTxt = new TextField();
            _mouseTxt.autoSize = TextFieldAutoSize.LEFT;
            _mouseTxt.mouseEnabled = false;
            LevelManager.stage.addChild(_mouseTxt);
         }
      }
      
      private static function upDateTxt() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = LevelManager.stage.mouseX;
         _loc2_ = LevelManager.stage.mouseY;
         _mouseTxt.x = _loc1_ + 15;
         _mouseTxt.y = _loc2_ + 5;
         _mouseTxt.text = MainManager.actorInfo.mapID.toString() + " / " + _loc1_.toString() + "," + _loc2_.toString();
      }
      
      private static function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Point = null;
         _loc2_ = null;
         _loc3_ = new Point(param1.currentTarget.mouseX,param1.currentTarget.mouseY);
         _loc2_ = UIManager.getMovieClip("Effect_MouseDown");
         _loc2_.mouseEnabled = false;
         _loc2_.mouseChildren = false;
         MovieClipUtil.playEndAndRemove(_loc2_);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         var _loc4_:MapModel = MapManager.currentMap;
         var _loc5_:DisplayObjectContainer = _loc4_.root;
         if(Boolean(_loc5_))
         {
            if(Boolean(_loc5_.scrollRect))
            {
               _loc2_.x -= _loc5_.scrollRect.x;
               _loc2_.y -= _loc5_.scrollRect.y;
            }
         }
         LevelManager.mapLevel.addChild(_loc2_);
         if(Math.abs(_loc3_.x - lastPos.x) <= 5 && Math.abs(_loc3_.y - lastPos.y) <= 5)
         {
            return;
         }
         lastPos.x = _loc3_.x;
         lastPos.y = _loc3_.y;
         MapConfig.delEnterFrame();
         MainManager.actorModel.walkAction(_loc3_);
         LevelManager.stage.focus = LevelManager.stage;
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_MOUSE_DOWN,MapManager.currentMap));
      }
      
      private static function onMouseMove(param1:MouseEvent) : void
      {
         param1.updateAfterEvent();
      }
   }
}

