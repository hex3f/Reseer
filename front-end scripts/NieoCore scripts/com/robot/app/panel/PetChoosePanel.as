package com.robot.app.panel
{
   import com.robot.app.petbag.ui.PetBagListItem;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.effect.ColorFilter;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetChoosePanel
   {
      
      private static var _ui:MovieClip;
      
      private static var _listCon:Sprite;
      
      private static var _handler:Function;
      
      private static var _cancel:Function;
      
      private static var _filter:Function;
      
      private static var _currentItem:PetBagListItem;
      
      private static const LENGTH:int = 6;
      
      public function PetChoosePanel()
      {
         super();
      }
      
      public static function show(param1:Function, param2:Function = null, param3:Function = null, param4:uint = 1, param5:Point = null) : void
      {
         var _loc6_:int = 0;
         var _loc7_:PetBagListItem = null;
         _loc6_ = 0;
         _loc7_ = null;
         if(_ui == null)
         {
            LevelManager.closeMouseEvent();
            _handler = param1;
            _cancel = param2;
            _filter = param3;
            _ui = UIManager.getMovieClip("PetChoosePanel_UI");
            LevelManager.appLevel.addChild(_ui);
            _ui["title"].gotoAndStop(param4);
            if(param5 == null)
            {
               DisplayUtil.align(_ui,null,AlignType.MIDDLE_CENTER);
            }
            else
            {
               _ui.x = param5.x;
               _ui.y = param5.y;
            }
            _listCon = new Sprite();
            _listCon.x = 30;
            _listCon.y = 64;
            _ui.addChild(_listCon);
            _loc6_ = 0;
            while(_loc6_ < LENGTH)
            {
               _loc7_ = new PetBagListItem();
               _loc7_.x = (_loc7_.width + 6) * (_loc6_ % 2);
               _loc7_.y = (_loc7_.height + 6) * int(_loc6_ / 2);
               _listCon.addChild(_loc7_);
               _loc6_++;
            }
            _ui["drag"].addEventListener(MouseEvent.MOUSE_DOWN,onDragDown);
            _ui["drag"].addEventListener(MouseEvent.MOUSE_UP,onDragUp);
            _ui["close"].addEventListener(MouseEvent.CLICK,onClose);
            _ui["choose"].addEventListener(MouseEvent.CLICK,onChoose);
            PetManager.addEventListener(PetEvent.UPDATE_INFO,onUpDate);
            PetManager.upDate();
         }
      }
      
      private static function onItemClick(param1:MouseEvent) : void
      {
         if(_currentItem != null)
         {
            _currentItem.isSelect = false;
         }
         _currentItem = param1.currentTarget as PetBagListItem;
         _currentItem.isSelect = true;
      }
      
      private static function onDragDown(param1:MouseEvent) : void
      {
         _ui.startDrag();
      }
      
      private static function onDragUp(param1:MouseEvent) : void
      {
         _ui.stopDrag();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(_cancel != null)
         {
            _cancel();
         }
         if(_ui["title"].currentFrame == 7)
         {
            Alert.show("关闭后将放弃这次增加学习力的机会，确认要关闭吗？",function():void
            {
               hide();
            });
         }
         else
         {
            hide();
         }
      }
      
      private static function onUpDate(param1:PetEvent) : void
      {
         var _loc2_:PetBagListItem = null;
         var _loc3_:PetInfo = null;
         var _loc4_:PetBagListItem = null;
         var _loc5_:int = 0;
         while(_loc5_ < LENGTH)
         {
            _loc2_ = _listCon.getChildAt(_loc5_) as PetBagListItem;
            _loc2_.hide();
            _loc2_.mouseEnabled = false;
            _loc2_.filters = [];
            _loc2_.removeEventListener(MouseEvent.CLICK,onItemClick);
            _loc5_++;
         }
         var _loc6_:Array = PetManager.infos;
         var _loc7_:int = Math.min(LENGTH,_loc6_.length);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = _loc6_[_loc8_] as PetInfo;
            _loc4_ = _listCon.getChildAt(_loc8_) as PetBagListItem;
            _loc4_.show(_loc3_);
            if(_filter != null)
            {
               if(_filter(_loc3_))
               {
                  _loc4_.mouseEnabled = true;
                  _loc4_.filters = [];
                  _loc4_.addEventListener(MouseEvent.CLICK,onItemClick);
               }
               else
               {
                  _loc4_.mouseEnabled = false;
                  _loc4_.filters = [ColorFilter.setGrayscale()];
                  _loc4_.removeEventListener(MouseEvent.CLICK,onItemClick);
               }
            }
            else
            {
               _loc4_.mouseEnabled = true;
               _loc4_.filters = [];
               _loc4_.addEventListener(MouseEvent.CLICK,onItemClick);
            }
            _loc8_++;
         }
      }
      
      private static function onChoose(param1:MouseEvent) : void
      {
         if(_currentItem == null)
         {
            Alarm.show("你还没有选择精灵！");
         }
         else
         {
            _handler(_currentItem.info);
            hide();
         }
      }
      
      private static function hide() : void
      {
         var _loc1_:int = 0;
         var _loc2_:PetBagListItem = null;
         if(_ui != null)
         {
            LevelManager.openMouseEvent();
            _loc1_ = 0;
            while(_loc1_ < LENGTH)
            {
               _loc2_ = _listCon.getChildAt(_loc1_) as PetBagListItem;
               _loc2_.hide();
               _loc2_.removeEventListener(MouseEvent.CLICK,onItemClick);
               _loc1_++;
            }
            _ui["drag"].removeEventListener(MouseEvent.MOUSE_DOWN,onDragDown);
            _ui["drag"].removeEventListener(MouseEvent.MOUSE_UP,onDragUp);
            _ui["close"].removeEventListener(MouseEvent.CLICK,onClose);
            _ui["choose"].removeEventListener(MouseEvent.CLICK,onChoose);
            PetManager.removeEventListener(PetEvent.UPDATE_INFO,onUpDate);
            DisplayUtil.removeForParent(_ui);
            _ui = null;
            _listCon = null;
            _handler = null;
            _cancel = null;
            _filter = null;
            _currentItem = null;
         }
      }
   }
}

