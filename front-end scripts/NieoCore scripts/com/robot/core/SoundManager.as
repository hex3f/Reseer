package com.robot.core
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.MapLibManager;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class SoundManager
   {
      
      private static var soundChannel:SoundChannel;
      
      private static var currentSound:Sound;
      
      private static var dict:Dictionary = new Dictionary();
      
      public static var isPlay_b:Boolean = true;
      
      private static var _soundUrl:String = "";
      
      private static var _loading:Boolean = false;
      
      init();
      
      public function SoundManager()
      {
         super();
      }
      
      public static function playSound() : void
      {
         var _loc2_:String = null;
         var _loc1_:Sound = null;
         var _loc3_:SoundTransform = new SoundTransform(0.2);
         if(isPlay_b == true)
         {
            _loc1_ = dict["map_" + MainManager.actorInfo.mapID];
            _loc2_ = MapXMLInfo.getBgSoundIdByMapId(MapManager.getResMapID(MainManager.actorInfo.mapID));
            if(Boolean(_loc1_))
            {
               if(getQualifiedClassName(_loc1_) == getQualifiedClassName(currentSound))
               {
                  return;
               }
               if(Boolean(soundChannel))
               {
                  soundChannel.stop();
               }
               soundChannel = _loc1_.play(0,999999,_loc3_);
               currentSound = _loc1_;
            }
            else
            {
               stopSound();
               try
               {
                  if(_loc2_ == "")
                  {
                     soundChannel = MapLibManager.getSound("sound").play(0,999999,_loc3_);
                  }
                  else
                  {
                     _soundUrl = ClientConfig.getMapSound(_loc2_);
                     playing();
                  }
               }
               catch(e:Error)
               {
               }
            }
         }
      }
      
      private static function playing() : void
      {
         currentSound = new Sound();
         currentSound.addEventListener(Event.COMPLETE,onSoundComHandler);
         currentSound.load(new URLRequest(_soundUrl));
         _loading = true;
      }
      
      private static function onSoundComHandler(param1:Event) : void
      {
         _loading = false;
         currentSound.removeEventListener(Event.COMPLETE,onSoundComHandler);
         soundChannel = currentSound.play(0,99999);
      }
      
      public static function stopSound() : void
      {
         if(Boolean(soundChannel))
         {
            soundChannel.stop();
         }
         if(Boolean(currentSound))
         {
            if(_loading)
            {
               try
               {
                  currentSound.close();
               }
               catch(e:Error)
               {
               }
            }
            currentSound.removeEventListener(Event.COMPLETE,onSoundComHandler);
            currentSound = null;
         }
      }
      
      private static function init() : void
      {
         add(AssetsManager.getClass("KLS_Sound"),10,11,12);
         add(AssetsManager.getClass("HS_Sound"),15);
         add(AssetsManager.getClass("HY_Sound"),20,21,22);
         add(AssetsManager.getClass("YX_Sound"),25,26,27);
         add(AssetsManager.getClass("HEK_Sound"),30);
      }
      
      private static function add(param1:Class, ... rest) : void
      {
         var _loc3_:Number = 0;
         for each(_loc3_ in rest)
         {
            dict["map_" + _loc3_] = new param1() as Sound;
         }
      }
      
      public static function set setIsPlay(param1:Boolean) : void
      {
         isPlay_b = param1;
      }
      
      public static function get getIsPlay() : Boolean
      {
         return isPlay_b;
      }
   }
}

