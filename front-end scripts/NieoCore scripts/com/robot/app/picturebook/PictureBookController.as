package com.robot.app.picturebook
{
   import com.robot.app.picturebook.ui.PictureBookPanel;
   import org.taomee.utils.DisplayUtil;
   
   public class PictureBookController
   {
      
      private static var _pbp:PictureBookPanel;
      
      public function PictureBookController()
      {
         super();
      }
      
      public static function get panel() : PictureBookPanel
      {
         if(_pbp == null)
         {
            _pbp = new PictureBookPanel();
         }
         return _pbp;
      }
      
      public static function searchId(param1:int) : void
      {
         panel.serachId(param1);
      }
      
      public static function hide() : void
      {
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
         }
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
   }
}

