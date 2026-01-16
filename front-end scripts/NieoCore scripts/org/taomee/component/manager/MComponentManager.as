package org.taomee.component.manager
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import org.taomee.component.tips.ToolTip;
   
   public class MComponentManager
   {
      
      public static var root:DisplayObjectContainer;
      
      public static var stage:Stage;
      
      public static var font:String;
      
      public static var fontSize:uint;
      
      public static var bgAlpha:Number;
      
      public function MComponentManager()
      {
         super();
      }
      
      public static function get stageWidth() : Number
      {
         return stage.stageWidth;
      }
      
      public static function get stageHeight() : Number
      {
         return stage.stageHeight;
      }
      
      public static function setup(param1:DisplayObjectContainer, param2:uint = 12, param3:String = "Arial", param4:Number = 0) : void
      {
         root = param1;
         stage = param1.stage;
         fontSize = param2;
         font = param3;
         bgAlpha = param4;
         ToolTip.setup();
      }
   }
}

