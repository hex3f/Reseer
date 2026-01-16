package com.robot.core.utils
{
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TextFormatUtil
   {
      
      private static var _tfm:TextFormat = new TextFormat("宋体",12,16777215,null,null,null,null,null,null,null,null,null,3);
      
      public function TextFormatUtil()
      {
         super();
      }
      
      public static function appDefaultFormatText(param1:TextField, param2:String, param3:uint) : void
      {
         _tfm.color = param3;
         _tfm.bold = false;
         _tfm.size = 12;
         _tfm.italic = false;
         _tfm.underline = false;
         appendOne(param1,param2);
      }
      
      public static function appContentFormatText(param1:TextField, param2:String, param3:Object) : void
      {
         _tfm.color = param3.color;
         _tfm.bold = param3.bold;
         _tfm.size = param3.size;
         _tfm.italic = param3.italic;
         _tfm.underline = param3.underline;
         appendOne(param1,param2);
      }
      
      public static function appSenderFormatText(param1:TextField, param2:String, param3:Boolean) : void
      {
         if(param3)
         {
            _tfm.color = 255;
         }
         else
         {
            _tfm.color = 32768;
         }
         _tfm.bold = false;
         _tfm.size = 12;
         _tfm.italic = false;
         _tfm.underline = false;
         appendOne(param1,param2);
      }
      
      public static function appSeparatorFormatText(param1:TextField, param2:String, param3:uint) : void
      {
         _tfm.color = param3;
         _tfm.bold = true;
         _tfm.size = 12;
         _tfm.italic = false;
         _tfm.underline = false;
         appendOne(param1,param2);
      }
      
      public static function getEventTxt(param1:String, param2:String) : String
      {
         return "<a href=\'event:" + param2 + "\'><font color=\'#FF0000\'>" + param1 + "</font></a>";
      }
      
      public static function getRedTxt(param1:String) : String
      {
         return "<font color=\'#FF0000\'>" + param1 + "</font>";
      }
      
      public static function getBlueTxt(param1:String) : String
      {
         return "<font color=\'#0000FF\'>" + param1 + "</font>";
      }
      
      private static function appendOne(param1:TextField, param2:String) : void
      {
         param1.replaceText(param1.length,param1.length + 1,param2);
         param1.setTextFormat(_tfm,param1.length - param2.length,param1.length);
      }
   }
}

