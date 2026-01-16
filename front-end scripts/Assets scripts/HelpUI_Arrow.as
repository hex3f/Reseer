package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol300")]
   public dynamic class HelpUI_Arrow extends MovieClip
   {
      
      public function HelpUI_Arrow()
      {
         super();
         addFrameScript(70,this.frame71);
      }
      
      internal function frame71() : *
      {
         stop();
      }
   }
}

