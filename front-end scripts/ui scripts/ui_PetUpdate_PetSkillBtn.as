package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import ui_fla.Timeline_172;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1641")]
   public dynamic class ui_PetUpdate_PetSkillBtn extends MovieClip
   {
      
      public var iconMC:Timeline_172;
      
      public var migTxt:TextField;
      
      public var nameTxt:TextField;
      
      public var ppTxt:TextField;
      
      public function ui_PetUpdate_PetSkillBtn()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

