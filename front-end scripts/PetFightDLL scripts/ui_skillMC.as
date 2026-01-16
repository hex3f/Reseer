package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1340")]
   public dynamic class ui_skillMC extends MovieClip
   {
      
      public var pp_txt:TextField;
      
      public var bgMC:MovieClip;
      
      public var name_txt:TextField;
      
      public var iconMC:MovieClip;
      
      public function ui_skillMC()
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

