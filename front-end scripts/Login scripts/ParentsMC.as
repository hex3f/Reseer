package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol40")]
   public dynamic class ParentsMC extends MovieClip
   {
      
      public var closeBtn:SimpleButton;
      
      public function ParentsMC()
      {
         addFrameScript(0,this.frame1);
         super();
      }
      
      public function clickHander(param1:*) : *
      {
         this.parent.removeChild(this);
      }
      
      internal function frame1() : *
      {
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.clickHander);
      }
   }
}

