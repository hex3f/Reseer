package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1898")]
   public dynamic class LOADING extends MovieClip
   {
      
      public function LOADING()
      {
         super();
         addFrameScript(23,this.frame24);
      }
      
      internal function frame24() : *
      {
         gotoAndPlay(2);
      }
   }
}

