package com.robot.app.buyPetProps
{
   import org.taomee.utils.DisplayUtil;
   
   public class BuyPetPropsController
   {
      
      private static var _panel:BuyPetPropsPanel;
      
      public function BuyPetPropsController()
      {
         super();
      }
      
      public static function get panel() : BuyPetPropsPanel
      {
         if(_panel == null)
         {
            _panel = new BuyPetPropsPanel();
         }
         return _panel;
      }
      
      public static function show() : void
      {
         if(!DisplayUtil.hasParent(panel))
         {
            panel.show();
         }
      }
   }
}

