package com.robot.core.manager
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import org.taomee.utils.Utils;
   
   public class LoadingManager
   {
      
      private static var _loader:Loader;
      
      public function LoadingManager()
      {
         super();
      }
      
      public static function setup(param1:Loader) : void
      {
         _loader = param1;
      }
      
      public static function get loader() : Loader
      {
         return _loader;
      }
      
      public static function getMovieClip(param1:String) : MovieClip
      {
         return Utils.getMovieClipFromLoader(param1,_loader);
      }
   }
}

