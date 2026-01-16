package com.robot.core.aimat
{
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import org.taomee.manager.PopUpManager;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatGridPanel
   {
      
      private static var bgMC:MovieClip;
      
      private static var gridArray:Array = [];
      
      setup();
      
      public function AimatGridPanel()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:AimatGrid = null;
         var _loc2_:Number = NaN;
         _loc1_ = null;
         _loc2_ = 0;
         bgMC = UIManager.getMovieClip("ui_ThrowThingPanel");
         _loc1_ = new AimatGrid();
         _loc1_.x = 6;
         _loc1_.y = 4;
         bgMC.addChild(_loc1_);
         _loc1_.itemID = 0;
         _loc1_.addEventListener(AimatGrid.CLICK,onGridClick);
         _loc2_ = 1;
         while(_loc2_ < 9)
         {
            _loc1_ = new AimatGrid();
            _loc1_.x = 6 + (_loc1_.width + 3) * (_loc2_ % 3);
            _loc1_.y = 4 + (_loc1_.height + 3) * Math.floor(_loc2_ / 3);
            bgMC.addChild(_loc1_);
            gridArray.push(_loc1_);
            _loc1_.addEventListener(AimatGrid.CLICK,onGridClick);
            _loc2_++;
         }
         ItemManager.addEventListener(ItemEvent.THROW_LIST,onThrowList);
      }
      
      public static function show(param1:DisplayObject) : void
      {
         if(DisplayUtil.hasParent(bgMC))
         {
            hide();
            return;
         }
         clear();
         PopUpManager.showForDisplayObject(bgMC,param1,PopUpManager.TOP_LEFT,true,new Point((bgMC.width + param1.width) / 2,0));
         ItemManager.getThrowThing();
      }
      
      public static function hide() : void
      {
         DisplayUtil.removeForParent(bgMC,false);
      }
      
      private static function onThrowList(param1:Event) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:AimatGrid = null;
         var _loc4_:Array = ItemManager.getThrowIDs();
         var _loc5_:Number = 0;
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = gridArray[_loc5_];
            _loc3_.itemID = _loc2_;
            _loc5_++;
         }
      }
      
      private static function clear() : void
      {
         var _loc1_:AimatGrid = null;
         for each(_loc1_ in gridArray)
         {
            _loc1_.empty();
         }
      }
      
      private static function onGridClick(param1:Event) : void
      {
         hide();
      }
   }
}

