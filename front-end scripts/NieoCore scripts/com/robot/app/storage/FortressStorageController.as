package com.robot.app.storage
{
   import org.taomee.utils.DisplayUtil;
   
   public class FortressStorageController
   {
      
      private static var _panel:FortressStoragePanel;
      
      public function FortressStorageController()
      {
         super();
      }
      
      public static function get panel() : FortressStoragePanel
      {
         if(_panel == null)
         {
            _panel = new FortressStoragePanel();
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
      
      public static function hide() : void
      {
         if(_panel == null)
         {
            return;
         }
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
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

