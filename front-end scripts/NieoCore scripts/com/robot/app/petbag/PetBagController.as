package com.robot.app.petbag
{
   import com.robot.app.petbag.ui.PetBagPanel;
   import org.taomee.utils.DisplayUtil;
   
   public class PetBagController
   {
      
      private static var _panel:PetBagPanel;
      
      public function PetBagController()
      {
         super();
      }
      
      public static function get panel() : PetBagPanel
      {
         if(_panel == null)
         {
            _panel = new PetBagPanel();
         }
         return _panel;
      }
      
      public static function show() : void
      {
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
         }
         else
         {
            panel.show();
         }
      }
      
      public static function closeEvent() : void
      {
         panel.closeEvent();
      }
      
      public static function openEvent() : void
      {
         panel.openEvent();
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

