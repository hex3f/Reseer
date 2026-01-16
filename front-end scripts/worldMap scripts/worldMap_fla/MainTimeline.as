package worldMap_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var backBtn:SimpleButton;
      
      public var closeBtn:SimpleButton;
      
      public var btn_url:SimpleButton;
      
      public var galaxyMC:MovieClip;
      
      public var serverNameTxt:TextField;
      
      public var shipBtnMC:MovieClip;
      
      public function MainTimeline()
      {
         super();
         this.btn_url.addEventListener(MouseEvent.CLICK,this.OpenURL);
      }
      
      public function OpenURL(param1:*) : void
      {
         navigateToURL(new URLRequest("http://b23.tv/PnApbvX"),"_blank");
      }
      
      public function closeHandler(param1:MouseEvent) : *
      {
         this.parent.removeChild(this);
      }
   }
}

