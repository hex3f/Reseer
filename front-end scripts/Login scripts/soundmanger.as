package
{
   import flash.media.Sound;
   import flash.media.SoundChannel;
   
   public class soundmanger
   {
      
      private static var _instance:soundmanger;
      
      public var sound:Sound;
      
      public var music:SoundChannel;
      
      public function soundmanger()
      {
         super();
         this.sound = new loginsound();
      }
      
      public static function getInstance() : soundmanger
      {
         if(_instance == null)
         {
            _instance = new soundmanger();
         }
         return _instance;
      }
      
      public function playBgMusic() : void
      {
         this.music = this.sound.play(0,9999);
      }
      
      public function stopBgMusic() : void
      {
         this.music.stop();
      }
   }
}

