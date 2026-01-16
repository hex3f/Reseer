package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol264")]
   public dynamic class Effect_Trait_Down extends MovieClip
   {
      
      public function Effect_Trait_Down()
      {
         addFrameScript(0,this.frame1);
         super();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

