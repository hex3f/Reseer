package com.robot.core.manager
{
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.filters.DropShadowFilter;
   import org.taomee.component.UIComponent;
   import org.taomee.component.containers.HBox;
   import org.taomee.component.control.UIMovieClip;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.Utils;
   
   public class TaskIconManager
   {
      
      private static var box:HBox;
      
      private static var _loader:Loader;
      
      private static var iconArray:HashMap = new HashMap();
      
      private static var filter:DropShadowFilter = new DropShadowFilter(5,45,0,0.6);
      
      public function TaskIconManager()
      {
         super();
      }
      
      public static function setup(param1:Loader) : void
      {
         _loader = param1;
         box = new HBox();
         box.width = MainManager.getStageWidth() - 15;
         box.height = 94;
         box.gap = 10;
         box.halign = FlowLayout.RIGHT;
         box.valign = FlowLayout.MIDLLE;
         LevelManager.iconLevel.addChild(box);
      }
      
      public static function getIcon(param1:String) : InteractiveObject
      {
         return Utils.getDisplayObjectFromLoader(param1,_loader) as InteractiveObject;
      }
      
      public static function addIcon(param1:DisplayObject) : void
      {
         var _loc2_:UIComponent = null;
         if(!iconArray.containsKey(param1))
         {
            _loc2_ = new UIMovieClip(param1);
            box.appendAt(_loc2_,0);
            param1.filters = [filter];
            iconArray.add(param1,_loc2_);
         }
      }
      
      public static function delIcon(param1:DisplayObject) : void
      {
         var _loc2_:UIComponent = null;
         if(iconArray.containsKey(param1))
         {
            _loc2_ = iconArray.getValue(param1) as UIComponent;
            box.remove(_loc2_);
            iconArray.remove(param1);
         }
      }
   }
}

