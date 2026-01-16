package §515_fla§
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol539")]
   public dynamic class egbth_191 extends MovieClip
   {
      
      public var mc:MovieClip;
      
      public var mc1:MovieClip;
      
      public function egbth_191()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         stop();
         mc1.visible = false;
         mc1.gotoAndStop(1);
         mc.alpha = 0;
      }
   }
}

