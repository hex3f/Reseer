package com.robot.app.fightLevel
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class FightListPanel
   {
      
      private static var app:ApplicationDomain;
      
      private static var panel:Sprite;
      
      private static var infoA:Array;
      
      private static var addEventA:Array;
      
      private static var b1:Boolean = false;
      
      private static const defaultLength:uint = 5;
      
      private static const dedaultPoint:Point = new Point(84.5,24.6);
      
      private static const rec:Rectangle = new Rectangle(dedaultPoint.x,dedaultPoint.y,0,107);
      
      private static const move:uint = 3;
      
      public function FightListPanel()
      {
         super();
      }
      
      public static function show(param1:DisplayObjectContainer, param2:Point, param3:ApplicationDomain, param4:Array) : void
      {
         if(!panel)
         {
            panel = new (param3.getDefinition("UI_ListPanel") as Class)() as Sprite;
         }
         infoA = param4;
         panel["dragMc"].y = dedaultPoint.y;
         panel["dragMc"].x = dedaultPoint.x;
         addEventA = new Array();
         addItem(param3);
         var _loc5_:int = 0;
         while(_loc5_ < defaultLength)
         {
            panel.getChildByName("item" + _loc5_)["txt"].text = String(infoA[_loc5_].itemId);
            if(infoA[_loc5_].isOpen == true)
            {
               panel.getChildByName("item" + _loc5_)["maskMc"].visible = false;
               (panel.getChildByName("item" + _loc5_) as MovieClip).buttonMode = true;
               panel.getChildByName("item" + _loc5_).addEventListener(MouseEvent.CLICK,onClickHandler);
               addEventA.push(_loc5_);
            }
            _loc5_++;
         }
         if(infoA.length > defaultLength)
         {
            configScrollBar();
         }
         panel.alpha = 0;
         param1.addChild(panel);
         panel.x = param2.x;
         panel.y = param2.y;
         panel.addEventListener(Event.ENTER_FRAME,onEnterHandler);
         b1 = true;
      }
      
      private static function addItem(param1:ApplicationDomain) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:int = 0;
         while(_loc3_ < defaultLength)
         {
            _loc2_ = new (param1.getDefinition("UI_Item") as Class)() as Sprite;
            _loc2_.x = 20;
            _loc2_.y = 17 + (_loc2_.height + 13) * _loc3_;
            _loc2_.name = "item" + _loc3_;
            panel.addChild(_loc2_);
            _loc3_++;
         }
      }
      
      private static function addDataToItem(param1:Array) : void
      {
      }
      
      private static function configScrollBar() : void
      {
         panel["topBtn"].addEventListener(MouseEvent.MOUSE_DOWN,onTopDownHandler);
         panel["bottomBtn"].addEventListener(MouseEvent.MOUSE_DOWN,onBottomDownHandler);
         panel["dragMc"].addEventListener(MouseEvent.MOUSE_DOWN,onDragDownHandler);
      }
      
      private static function onTopDownHandler(param1:MouseEvent) : void
      {
         panel["topBtn"].addEventListener(Event.ENTER_FRAME,onEnter2Handler);
         panel["topBtn"].addEventListener(MouseEvent.MOUSE_UP,onTopUpHandler);
      }
      
      private static function onEnter2Handler(param1:Event) : void
      {
         if(panel["dragMc"].y - move >= dedaultPoint.y)
         {
            panel["dragMc"].y -= move;
         }
         else
         {
            panel["dragMc"].y = dedaultPoint.y;
         }
         onMoveHandler(null);
      }
      
      private static function onTopUpHandler(param1:Event) : void
      {
         panel["topBtn"].removeEventListener(Event.ENTER_FRAME,onEnter2Handler);
         panel["topBtn"].removeEventListener(MouseEvent.MOUSE_UP,onTopUpHandler);
      }
      
      private static function onBottomDownHandler(param1:MouseEvent) : void
      {
         panel["bottomBtn"].addEventListener(Event.ENTER_FRAME,onEnter1Handler);
         panel["bottomBtn"].addEventListener(MouseEvent.MOUSE_UP,onTop1UpHandler);
      }
      
      private static function onEnter1Handler(param1:Event) : void
      {
         if(panel["dragMc"].y + move <= dedaultPoint.y + rec.height)
         {
            panel["dragMc"].y += move;
         }
         else
         {
            panel["dragMc"].y = dedaultPoint.y + rec.height;
         }
         onMoveHandler(null);
      }
      
      private static function onTop1UpHandler(param1:MouseEvent) : void
      {
         panel["bottomBtn"].removeEventListener(Event.ENTER_FRAME,onEnter1Handler);
         panel["bottomBtn"].removeEventListener(MouseEvent.MOUSE_UP,onTop1UpHandler);
      }
      
      private static function onDragDownHandler(param1:MouseEvent) : void
      {
         panel["dragMc"].startDrag(false,rec);
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_UP,onUpHandler);
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMoveHandler);
      }
      
      private static function onMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = panel["dragMc"].y - dedaultPoint.y;
         if(_loc2_ < 0)
         {
            _loc2_ = 1;
         }
         var _loc3_:uint = uint(_loc2_ / rec.height * infoA.length);
         if(_loc3_ > infoA.length - defaultLength)
         {
            _loc3_ = uint(infoA.length - defaultLength);
         }
         var _loc4_:int = 0;
         while(_loc4_ < defaultLength)
         {
            panel.getChildByName("item" + _loc4_)["txt"].text = String(infoA[_loc4_ + _loc3_].itemId);
            if(infoA[_loc4_ + _loc3_].isOpen == true)
            {
               panel.getChildByName("item" + _loc4_)["maskMc"].visible = false;
               (panel.getChildByName("item" + _loc4_) as MovieClip).buttonMode = true;
               panel.getChildByName("item" + _loc4_).addEventListener(MouseEvent.CLICK,onClickHandler);
               if(addEventA.indexOf(_loc4_) == -1)
               {
                  addEventA.push(_loc4_);
               }
            }
            else
            {
               panel.getChildByName("item" + _loc4_)["maskMc"].visible = true;
               if((panel.getChildByName("item" + _loc4_) as MovieClip).buttonMode == true)
               {
                  (panel.getChildByName("item" + _loc4_) as MovieClip).buttonMode = false;
                  panel.getChildByName("item" + _loc4_).removeEventListener(MouseEvent.CLICK,onClickHandler);
               }
            }
            _loc4_++;
         }
      }
      
      private static function onUpHandler(param1:MouseEvent) : void
      {
         panel["dragMc"].stopDrag();
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMoveHandler);
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_UP,onUpHandler);
      }
      
      private static function onEnterHandler(param1:Event) : void
      {
         if(panel.alpha < 1)
         {
            panel.alpha += 0.2;
         }
         else
         {
            panel.removeEventListener(Event.ENTER_FRAME,onEnterHandler);
            b1 = false;
         }
      }
      
      private static function onClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = (param1.currentTarget as MovieClip)["txt"].text;
         var _loc3_:uint = uint(_loc2_.slice(0,1));
         if(_loc2_.length == 1)
         {
            _loc3_ = uint(_loc2_);
         }
         else
         {
            _loc3_ = uint(uint(_loc2_.slice(0,1)) + 1);
         }
         choice(_loc3_);
      }
      
      private static function choice(param1:uint) : void
      {
         SocketConnection.addCmdListener(CommandID.CHOICE_FIGHT_LEVEL,onChoiceSuccessHandler);
         SocketConnection.send(CommandID.CHOICE_FIGHT_LEVEL,param1);
      }
      
      private static function onChoiceSuccessHandler(param1:*) : void
      {
         SocketConnection.removeCmdListener(CommandID.CHOICE_FIGHT_LEVEL,onChoiceSuccessHandler);
         var _loc2_:ChoiceLevelRequestInfo = param1.data as ChoiceLevelRequestInfo;
         FightLevelModel.setBossId = _loc2_.getBossId;
         FightLevelModel.setCurLevel = _loc2_.getLevel;
         MainManager.actorInfo.curStage = _loc2_.getLevel;
         FightChoiceController.hide();
         MapManager.changeMap(500);
      }
      
      public static function destroy() : void
      {
         var _loc1_:int = 0;
         if(Boolean(addEventA))
         {
            if(addEventA.length > 0)
            {
               _loc1_ = 0;
               while(_loc1_ < addEventA.length)
               {
                  panel.getChildByName("item" + addEventA[_loc1_]).removeEventListener(MouseEvent.CLICK,onClickHandler);
                  _loc1_++;
               }
            }
         }
         if(b1)
         {
            panel.removeEventListener(Event.ENTER_FRAME,onEnterHandler);
         }
         if(infoA.length > defaultLength)
         {
            panel["topBtn"].removeEventListener(MouseEvent.MOUSE_DOWN,onTopDownHandler);
            panel["bottomBtn"].removeEventListener(MouseEvent.MOUSE_DOWN,onBottomDownHandler);
            panel["dragMc"].removeEventListener(MouseEvent.MOUSE_DOWN,onDragDownHandler);
         }
         DisplayUtil.removeForParent(panel);
         panel = null;
         infoA = null;
         app = null;
         addEventA = null;
      }
   }
}

