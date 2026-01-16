package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol469")]
   public dynamic class Effect_Trait_Up extends MovieClip
   {
      
      public function Effect_Trait_Up()
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

