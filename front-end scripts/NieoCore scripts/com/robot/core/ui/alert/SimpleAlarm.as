package com.robot.core.ui.alert
{
   import com.robot.core.manager.MainManager;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import gs.TweenLite;
   import org.taomee.utils.DisplayUtil;
   
   public class SimpleAlarm extends Sprite
   {
      
      private static var alarm:SimpleAlarm;
      
      private var bg:Shape;
      
      private var txt:TextField;
      
      private var tf:TextFormat;
      
      private var MARGIN:uint = 10;
      
      private var timer:Timer;
      
      private var bmp:Bitmap;
      
      public function SimpleAlarm()
      {
         super();
         cacheAsBitmap = true;
         this.bg = new Shape();
         addChild(this.bg);
         this.txt = new TextField();
         this.txt.cacheAsBitmap = true;
         this.txt.autoSize = TextFieldAutoSize.CENTER;
         this.txt.width = 260;
         this.txt.wordWrap = true;
         this.txt.selectable = false;
         this.tf = new TextFormat();
         this.tf.size = 14;
         this.tf.font = "Arial";
         this.tf.leading = 4;
         this.tf.letterSpacing = 1;
         this.tf.align = TextFormatAlign.CENTER;
         this.txt.defaultTextFormat = this.tf;
         this.mouseChildren = false;
         this.addEventListener(MouseEvent.CLICK,this.closeHandler);
         this.timer = new Timer(3000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      public static function show(param1:String, param2:Boolean = false) : void
      {
         alarm = new SimpleAlarm();
         alarm.show(param1,param2);
      }
      
      public static function hide() : void
      {
         DisplayUtil.removeForParent(alarm);
      }
      
      public function show(param1:String, param2:Boolean = false, param3:uint = 16777215, param4:uint = 13158, param5:uint = 168170) : void
      {
         if(param2)
         {
            param3 = 16776960;
            param4 = 14221356;
            param5 = 16738922;
         }
         this.txt.htmlText = "<font color=\'#" + param3.toString(16) + "\'>" + param1 + "</font>";
         this.bmp = DisplayUtil.copyDisplayAsBmp(this.txt);
         this.bmp.x = this.MARGIN;
         this.bmp.y = this.MARGIN;
         addChild(this.bmp);
         this.graphics.beginFill(param4,0.8);
         this.graphics.drawRoundRect(0,0,this.txt.width + this.MARGIN * 2,this.txt.height + this.MARGIN * 2 - 4,12,12);
         this.graphics.endFill();
         this.bg.graphics.lineStyle(2,param5);
         this.bg.graphics.drawRoundRect(4,4,this.txt.width + (this.MARGIN - 4) * 2,this.txt.height + (this.MARGIN - 4) * 2 - 4,10,10);
         this.bg.graphics.endFill();
         this.x = 340;
         this.y = 70;
         MainManager.getStage().addChild(this);
         this.timer.start();
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         this.destroy();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.destroy();
      }
      
      private function destroy() : void
      {
         TweenLite.to(this,2,{
            "alpha":0,
            "onComplete":this.comp
         });
         this.removeEventListener(MouseEvent.CLICK,this.closeHandler);
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
      }
      
      private function comp() : void
      {
         DisplayUtil.removeForParent(this);
         this.bg = null;
         this.txt = null;
         this.bmp = null;
      }
   }
}

