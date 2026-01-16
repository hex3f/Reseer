package com.robot.core.ui.loading.loadingstyle
{
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class TitleOnlyLoading extends BaseLoadingStyle implements ILoadingStyle
   {
      
      private static const KEY:String = "titleOnlyLoading";
      
      protected var titleText:TextField;
      
      public function TitleOnlyLoading(param1:DisplayObjectContainer, param2:String = "Loading...", param3:Boolean = false)
      {
         super(param1,param3);
         this.titleText = loadingMC["content_txt"];
         this.titleText.autoSize = TextFieldAutoSize.CENTER;
         this.titleText.text = param2;
      }
      
      override public function changePercent(param1:Number, param2:Number) : void
      {
         super.changePercent(param1,param2);
      }
      
      override public function setTitle(param1:String) : void
      {
         this.titleText.text = param1;
      }
      
      override public function destroy() : void
      {
         this.titleText = null;
         super.destroy();
      }
      
      override protected function getKey() : String
      {
         return KEY;
      }
   }
}

