package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol422")]
   public dynamic class getPPAllInfo extends MovieClip
   {
      
      public var color:MovieClip;
      
      public var pwdTxt:TextField;
      
      public var robotTxt:TextField;
      
      public var goShipBtn:SimpleButton;
      
      public var miIdtxt:TextField;
      
      public var bgMc:MovieClip;
      
      public function getPPAllInfo()
      {
         super();
      }
      
      internal function frame1() : *
      {
         this.bgMc.visible = false;
      }
   }
}

