package com.robot.core.manager.map
{
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.media.Sound;
   import org.taomee.utils.Utils;
   
   public class MapLibManager
   {
      
      private static var _loader:Loader;
      
      public function MapLibManager()
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
      
      public static function getClass(param1:String) : Class
      {
         return Utils.getClassFromLoader(param1,_loader);
      }
      
      public static function getMovieClip(param1:String) : MovieClip
      {
         return Utils.getMovieClipFromLoader(param1,_loader);
      }
      
      public static function getButton(param1:String) : SimpleButton
      {
         return Utils.getSimpleButtonFromLoader(param1,_loader);
      }
      
      public static function getBitmap(param1:String) : Bitmap
      {
         return new Bitmap(Utils.getBitmapDataFromLoader(param1,_loader));
      }
      
      public static function getSound(param1:String) : Sound
      {
         return Utils.getSoundFromLoader(param1,_loader);
      }
   }
}

