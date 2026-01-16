package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1901")]
   public dynamic class ui_ImgPanel extends MovieClip
   {
      
      public var bgMC:Panel_Background;
      
      public var closeBtn:Close_Btn;
      
      public var imgMC:MovieClip;
      
      public var load_MC:LOADING;
      
      public var saveBtn:SimpleButton;
      
      public function ui_ImgPanel()
      {
         super();
      }
   }
}

