package com.robot.app.bag
{
   import org.taomee.utils.DisplayUtil;
   
   public class BagController
   {
      
      private static var _bagPanel:BagPanel;
      
      private static var model:BagClothModel;
      
      public function BagController()
      {
         super();
      }
      
      public static function get panel() : BagPanel
      {
         if(!_bagPanel)
         {
            _bagPanel = new BagPanel();
            model = new BagClothModel(_bagPanel);
         }
         return _bagPanel;
      }
      
      public static function show() : void
      {
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
            model.clear();
         }
         else
         {
            panel.show();
         }
      }
      
      public static function openEvent() : void
      {
         panel.openEvent();
      }
      
      public static function closeEvent() : void
      {
         panel.closeEvent();
      }
   }
}

