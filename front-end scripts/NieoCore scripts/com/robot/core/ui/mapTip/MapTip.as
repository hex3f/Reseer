package com.robot.core.ui.mapTip
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.taomee.utils.DisplayUtil;
   
   public class MapTip
   {
      
      private static var bgMC:MovieClip;
      
      private static var _info:MapTipInfo;
      
      private static var tipMC:Sprite;
      
      private static var itemContainer:Sprite;
      
      private static var leftGap:Number = 5;
      
      private static var rightGap:Number = 5;
      
      public function MapTip()
      {
         super();
      }
      
      public static function show(param1:MapTipInfo, param2:DisplayObjectContainer = null) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:MapTipItem = null;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:MapTipItem = null;
         var _loc8_:MapItemTipInfo = null;
         tipMC = getTipMC();
         itemContainer = new Sprite();
         bgMC = UIManager.getMovieClip("MapTipBg");
         tipMC.addChild(bgMC);
         tipMC.addChild(itemContainer);
         if(Boolean(param1))
         {
            _loc3_ = 0;
            _loc5_ = 0;
            for each(_loc6_ in param1.contentList)
            {
               _loc7_ = new MapTipItem();
               _loc8_ = new MapItemTipInfo(param1.id,_loc6_);
               _loc7_.info = _loc8_;
               if(Boolean(_loc4_))
               {
                  _loc7_.y = _loc3_ + _loc4_.height + 2;
               }
               itemContainer.addChild(_loc7_);
               _loc4_ = _loc7_;
               _loc3_ = _loc7_.y;
               _loc5_++;
            }
            bgMC.width = itemContainer.width + leftGap * 2;
            bgMC.height = itemContainer.height + rightGap * 2;
            itemContainer.x = leftGap;
            itemContainer.y = rightGap;
         }
         if(Boolean(param2))
         {
            param2.addChild(tipMC);
         }
         else
         {
            LevelManager.appLevel.addChild(tipMC);
         }
         tipMC.x = -200;
         tipMC.y = -500;
         tipMC.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
      }
      
      public static function hide() : void
      {
         if(Boolean(tipMC))
         {
            tipMC.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
            DisplayUtil.removeAllChild(tipMC);
            DisplayUtil.removeForParent(tipMC);
         }
      }
      
      private static function enterFrameHandler(param1:Event) : void
      {
         if(tipMC == null)
         {
            return;
         }
         if(MainManager.getStage().mouseX + tipMC.width + 20 >= MainManager.getStageWidth())
         {
            tipMC.x = MainManager.getStageWidth() - tipMC.width - 10;
         }
         else
         {
            tipMC.x = MainManager.getStage().mouseX + 10;
         }
         if(MainManager.getStage().mouseY + tipMC.height + 20 >= MainManager.getStageHeight())
         {
            tipMC.y = MainManager.getStageHeight() - tipMC.height - 10;
         }
         else
         {
            tipMC.y = MainManager.getStage().mouseY - tipMC.height / 2;
         }
      }
      
      private static function getTipMC() : Sprite
      {
         if(tipMC == null)
         {
            tipMC = new Sprite();
         }
         return tipMC;
      }
   }
}

