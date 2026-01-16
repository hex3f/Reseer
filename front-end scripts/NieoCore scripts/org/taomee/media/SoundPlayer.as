package org.taomee.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class SoundPlayer extends EventDispatcher
   {
      
      private var _position:Number = 0;
      
      private var _sound:Sound;
      
      private var _soundChannel:SoundChannel;
      
      private var _soundState:int = SoundPlayerState.NOTLOADED;
      
      private var _cyc:Boolean;
      
      private var _url:String = "";
      
      private var _autoStart:Boolean;
      
      public function SoundPlayer(param1:String = "", param2:Boolean = false, param3:Boolean = false)
      {
         super();
         this.load(param1,param2,param3);
      }
      
      public function destroy() : void
      {
         this.stop();
         this._sound = null;
         this._soundChannel = null;
      }
      
      public function play() : void
      {
         if(this._url == "")
         {
            return;
         }
         if(this._soundState == SoundPlayerState.PLAYING)
         {
            return;
         }
         if(Boolean(this._soundChannel))
         {
            this._soundChannel.stop();
            this._soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
            this._soundChannel = null;
         }
         this._soundChannel = this._sound.play(this._position);
         this._soundChannel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         this._soundState = SoundPlayerState.PLAYING;
      }
      
      public function get leftPeak() : Number
      {
         return this._soundChannel.leftPeak;
      }
      
      public function stop() : void
      {
         if(this._soundState == SoundPlayerState.NOTLOADED)
         {
            return;
         }
         if(this._soundChannel == null)
         {
            this._soundState = SoundPlayerState.STOPPED;
            return;
         }
         this._position = 0;
         this._soundChannel.stop();
         this._soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         this._soundState = SoundPlayerState.STOPPED;
      }
      
      private function onLoadOpen(param1:Event) : void
      {
         this._sound.removeEventListener(Event.OPEN,this.onLoadOpen);
         dispatchEvent(param1);
         if(this._autoStart)
         {
            if(this._soundState == SoundPlayerState.PAUSED)
            {
               return;
            }
            if(this._soundState == SoundPlayerState.STOPPED)
            {
               return;
            }
            this._position = 0;
            this.play();
         }
      }
      
      public function set position(param1:Number) : void
      {
         var _loc2_:Boolean = this._soundState == SoundPlayerState.PLAYING;
         this.pause();
         this._position = param1;
         if(_loc2_)
         {
            this.play();
         }
      }
      
      public function get duration() : Number
      {
         return this._sound.length;
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         this.stop();
         dispatchEvent(param1);
         if(this._cyc)
         {
            this.play();
         }
      }
      
      public function get volume() : Number
      {
         return this._soundChannel.soundTransform.volume;
      }
      
      public function get rightPeak() : Number
      {
         return this._soundChannel.rightPeak;
      }
      
      public function get position() : Number
      {
         return this._soundChannel.position;
      }
      
      public function set autoStart(param1:Boolean) : void
      {
         this._autoStart = param1;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set cyc(param1:Boolean) : void
      {
         this._cyc = param1;
      }
      
      public function get autoStart() : Boolean
      {
         return this._autoStart;
      }
      
      public function set volume(param1:Number) : void
      {
         var _loc2_:SoundTransform = this._soundChannel.soundTransform;
         _loc2_.volume = param1;
         this._soundChannel.soundTransform = _loc2_;
      }
      
      public function load(param1:String, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1 == "")
         {
            return;
         }
         if(param1 == this._url)
         {
            return;
         }
         this._url = param1;
         this._sound = new Sound();
         this._sound.load(new URLRequest(param1));
         this._sound.addEventListener(Event.OPEN,this.onLoadOpen);
         this._sound.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress);
         this._sound.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this._autoStart = param2;
         this._cyc = param3;
      }
      
      public function pause() : void
      {
         if(this._soundState == SoundPlayerState.NOTLOADED)
         {
            return;
         }
         if(this._soundChannel == null)
         {
            this._soundState = SoundPlayerState.PAUSED;
            return;
         }
         if(this._soundState == SoundPlayerState.PAUSED)
         {
            return;
         }
         this._position = this._soundChannel.position;
         this._soundChannel.stop();
         this._soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         this._soundState = SoundPlayerState.PAUSED;
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      public function get cyc() : Boolean
      {
         return this._cyc;
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         this._sound.removeEventListener(ProgressEvent.PROGRESS,this.onLoadProgress);
         this._sound.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         dispatchEvent(param1);
      }
   }
}

