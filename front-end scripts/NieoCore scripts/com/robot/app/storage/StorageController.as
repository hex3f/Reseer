package com.robot.app.storage
{
   import org.taomee.utils.DisplayUtil;
   
   public class StorageController
   {
      
      private static var _panel:StoragePanel;
      
      public function StorageController()
      {
         super();
      }
      
      public static function get panel() : StoragePanel
      {
         if(_panel == null)
         {
            _panel = new StoragePanel();
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

