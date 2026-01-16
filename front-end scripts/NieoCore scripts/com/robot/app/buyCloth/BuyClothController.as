package com.robot.app.buyCloth
{
   import org.taomee.utils.DisplayUtil;
   
   public class BuyClothController
   {
      
      private static var _panel:BuyClothPanel;
      
      public function BuyClothController()
      {
         super();
      }
      
      private static function get panel() : BuyClothPanel
      {
         if(_panel == null)
         {
            _panel = new BuyClothPanel();
         }
         return _panel;
      }
      
      public static function show() : void
      {
         if(_panel == null)
         {
            panel.show();
            return;
         }
         if(!DisplayUtil.hasParent(panel))
         {
            panel.show();
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(_panel))
         {
            _panel.destroy();
            _panel = null;
         }
      }
   }
}

