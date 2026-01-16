package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import ui_fla.Timeline_172;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1516")]
   public dynamic class ui_Normal_PetSkilBtn extends MovieClip
   {
      
      public var iconMC:Timeline_172;
      
      public var migTxt:TextField;
      
      public var nameTxt:TextField;
      
      public var ppTxt:TextField;
      
      public function ui_Normal_PetSkilBtn()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
   }
}

