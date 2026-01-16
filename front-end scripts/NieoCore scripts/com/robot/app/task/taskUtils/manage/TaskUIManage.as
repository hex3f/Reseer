package com.robot.app.task.taskUtils.manage
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.Utils;
   
   public class TaskUIManage
   {
      
      private static var _loader:Loader;
      
      public static var loadHash:HashMap = new HashMap();
      
      public function TaskUIManage()
      {
         super();
      }
      
      public static function getMovieClip(param1:String, param2:uint) : MovieClip
      {
         _loader = loadHash.getValue(param2);
         return Utils.getMovieClipFromLoader(param1,_loader);
      }
      
      public static function getButton(param1:String, param2:uint) : SimpleButton
      {
         _loader = loadHash.getValue(param2);
         return Utils.getSimpleButtonFromLoader(param1,_loader);
      }
      
      public static function destroyLoder(param1:uint) : void
      {
         var _loc2_:Loader = loadHash.getValue(param1);
         loadHash.remove(param1);
         _loc2_ = null;
      }
   }
}

