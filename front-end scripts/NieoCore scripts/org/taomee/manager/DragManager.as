package org.taomee.manager
{
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.ds.HashMap;
   
   public class DragManager
   {
      
      private static var _collectionMap:HashMap = new HashMap();
      
      public function DragManager()
      {
         super();
      }
      
      public static function add(param1:InteractiveObject, param2:Sprite) : void
      {
         if(param1 is Sprite)
         {
            (param1 as Sprite).buttonMode = true;
         }
         param1.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
         param1.addEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
         _collectionMap.add(param1,param2);
      }
      
      public static function remove(param1:InteractiveObject) : void
      {
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
         param1.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
         var _loc2_:Sprite = _collectionMap.getValue(param1) as Sprite;
         if(Boolean(_loc2_))
         {
            _collectionMap.remove(param1);
            _loc2_ = null;
         }
      }
      
      private static function onMouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = _collectionMap.getValue(param1.currentTarget as InteractiveObject) as Sprite;
         if(Boolean(_loc2_))
         {
            _loc2_.stopDrag();
         }
      }
      
      private static function onMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = _collectionMap.getValue(param1.currentTarget as InteractiveObject) as Sprite;
         if(Boolean(_loc2_))
         {
            DepthManager.bringToTop(_loc2_);
            _loc2_.startDrag();
         }
      }
   }
}

