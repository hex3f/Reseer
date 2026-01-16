package com.robot.app.quickWord
{
   import flash.display.DisplayObject;
   
   public class QuickWordController
   {
      
      private static var _quickWord:QuickWord;
      
      public function QuickWordController()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(_quickWord == null)
         {
            _quickWord = new QuickWord();
         }
      }
      
      public static function get quickWord() : QuickWord
      {
         if(_quickWord == null)
         {
            _quickWord = new QuickWord();
         }
         return _quickWord;
      }
      
      public static function show(param1:DisplayObject) : void
      {
         quickWord.show(param1);
      }
   }
}

