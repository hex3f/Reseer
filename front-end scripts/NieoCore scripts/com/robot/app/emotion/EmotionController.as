package com.robot.app.emotion
{
   import flash.display.DisplayObject;
   import org.taomee.utils.DisplayUtil;
   
   public class EmotionController
   {
      
      private static var _e:EmotionPanel;
      
      public function EmotionController()
      {
         super();
      }
      
      public static function get panel() : EmotionPanel
      {
         if(_e == null)
         {
            _e = new EmotionPanel();
         }
         return _e;
      }
      
      public static function show(param1:DisplayObject) : void
      {
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
         }
         else
         {
            panel.show(param1);
         }
      }
   }
}

