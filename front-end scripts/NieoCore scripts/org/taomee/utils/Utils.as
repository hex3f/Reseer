package org.taomee.utils
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.media.Sound;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class Utils
   {
      
      private static var _bmdPacket:Dictionary = new Dictionary(true);
      
      public function Utils()
      {
         super();
      }
      
      public static function getClass(param1:String) : Class
      {
         var name:String = param1;
         var ClassReference:Class = null;
         try
         {
            ClassReference = getDefinitionByName(name) as Class;
         }
         catch(e:Error)
         {
            return null;
         }
         return ClassReference;
      }
      
      public static function getClassFromLoader(param1:String, param2:Loader) : Class
      {
         var _loc3_:ApplicationDomain = param2.contentLoaderInfo.applicationDomain;
         if(_loc3_.hasDefinition(param1))
         {
            return _loc3_.getDefinition(param1) as Class;
         }
         return null;
      }
      
      public static function getMovieClipFromLoader(param1:String, param2:Loader) : MovieClip
      {
         var _loc3_:DisplayObject = getDisplayObjectFromLoader(param1,param2);
         return _loc3_ == null ? null : _loc3_ as MovieClip;
      }
      
      public static function getDisplayObjectFromLoader(param1:String, param2:Loader) : DisplayObject
      {
         var name:String = param1;
         var loader:Loader = param2;
         var classReference:Class = getClassFromLoader(name,loader);
         if(classReference == null)
         {
            return null;
         }
         try
         {
            return new classReference() as DisplayObject;
         }
         catch(e:Error)
         {
            return null;
         }
      }
      
      public static function getBitmapDataFromLoader(param1:String, param2:Loader, param3:Boolean = false) : BitmapData
      {
         var classReference:Class = null;
         var name:String = param1;
         var loader:Loader = param2;
         var isCache:Boolean = param3;
         var bmd:BitmapData = null;
         if(Boolean(_bmdPacket[name]))
         {
            return _bmdPacket[name];
         }
         classReference = getClassFromLoader(name,loader);
         if(Boolean(classReference))
         {
            try
            {
               bmd = new classReference(0,0) as BitmapData;
            }
            catch(e:Error)
            {
            }
            if(isCache)
            {
               if(Boolean(bmd))
               {
                  _bmdPacket[name] = bmd;
               }
            }
            return bmd;
         }
         return null;
      }
      
      public static function getLoaderClass(param1:Loader) : Class
      {
         return param1.contentLoaderInfo.applicationDomain.getDefinition(getQualifiedClassName(param1.content)) as Class;
      }
      
      public static function getSoundFromLoader(param1:String, param2:Loader) : Sound
      {
         var _loc3_:Class = getClassFromLoader(param1,param2);
         return new _loc3_() as Sound;
      }
      
      public static function getSimpleButtonFromLoader(param1:String, param2:Loader) : SimpleButton
      {
         var _loc3_:DisplayObject = getDisplayObjectFromLoader(param1,param2);
         return _loc3_ == null ? null : _loc3_ as SimpleButton;
      }
      
      public static function getSpriteFromLoader(param1:String, param2:Loader) : Sprite
      {
         var _loc3_:DisplayObject = getDisplayObjectFromLoader(param1,param2);
         return _loc3_ == null ? null : _loc3_ as Sprite;
      }
      
      public static function getClassByObject(param1:DisplayObject) : Class
      {
         var obj:DisplayObject = param1;
         var mcs:Class = null;
         try
         {
            mcs = getClassFromLoader(getQualifiedClassName(obj),obj.loaderInfo.loader) as Class;
         }
         catch(e:Error)
         {
            return null;
         }
         return mcs;
      }
   }
}

