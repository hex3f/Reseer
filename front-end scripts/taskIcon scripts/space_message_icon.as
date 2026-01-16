package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol582")]
   public dynamic class space_message_icon extends MovieClip
   {
      
      public var message_effect:MovieClip;
      
      public var message_btn:MovieClip;
      
      public function space_message_icon()
      {
         addFrameScript(0,this.frame1,1,this.frame2);
         super();
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

