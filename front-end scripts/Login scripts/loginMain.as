package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol216")]
   public dynamic class loginMain extends MovieClip
   {
      
      public var savePwd:SimpleButton;
      
      public var proectedBtn:SimpleButton;
      
      public var idTxt:TextField;
      
      public var forgetPass:SimpleButton;
      
      public var savaMiTip:MovieClip;
      
      public var regBtn:SimpleButton;
      
      public var modifyPass:SimpleButton;
      
      public var otherBtn:SimpleButton;
      
      public var pwdTxt:TextField;
      
      public var savaPwdTip:MovieClip;
      
      public var logBtn:SimpleButton;
      
      public var saveMi:SimpleButton;
      
      public function loginMain()
      {
         super();
      }
      
      public function clickHandler3(param1:*) : void
      {
         navigateToURL(new URLRequest("http://account.61.com/protect"),"_blank");
      }
      
      public function clickHandler2(param1:*) : void
      {
         navigateToURL(new URLRequest("http://account.61.com/forget"),"_blank");
      }
      
      public function clickHandler(param1:*) : void
      {
         navigateToURL(new URLRequest("http://account.61.com/change"),"_blank");
      }
      
      internal function frame1() : *
      {
         this.modifyPass.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this.forgetPass.addEventListener(MouseEvent.CLICK,this.clickHandler2);
         this.proectedBtn.addEventListener(MouseEvent.CLICK,this.clickHandler3);
      }
   }
}

