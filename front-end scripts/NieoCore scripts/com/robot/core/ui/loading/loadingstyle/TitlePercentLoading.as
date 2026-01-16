package com.robot.core.ui.loading.loadingstyle
{
   import com.robot.core.config.UpdateConfig;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class TitlePercentLoading extends TitleOnlyLoading implements ILoadingStyle
   {
      
      private static const KEY:String = "titlePercentLoading";
      
      protected var percentText:TextField;
      
      protected var percentBar:MovieClip;
      
      private var barWidth:Number;
      
      private var showCloseBtn:Boolean = true;
      
      private var tipTxt:TextField;
      
      private var timer:Timer;
      
      public function TitlePercentLoading(param1:DisplayObjectContainer, param2:String = "Loading...", param3:Boolean = false)
      {
         super(param1,param2,this.showCloseBtn);
         this.percentText = loadingMC["perNum"];
         this.percentText.text = "0%";
         this.tipTxt = loadingMC["tip_txt"];
         this.percentBar = loadingMC["loadingBar"];
         this.barWidth = 200;
         var _loc4_:Array = UpdateConfig.loadingArray.slice();
         var _loc5_:uint = Math.floor(Math.random() * _loc4_.length);
         this.tipTxt.text = _loc4_[_loc5_];
         this.timer = new Timer(2000);
         this.timer.addEventListener(TimerEvent.TIMER,this.changeTip);
         this.timer.start();
      }
      
      private function changeTip(param1:TimerEvent) : void
      {
         var _loc2_:Array = UpdateConfig.loadingArray.slice();
         var _loc3_:uint = Math.floor(Math.random() * _loc2_.length);
         this.tipTxt.text = _loc2_[_loc3_];
      }
      
      override public function changePercent(param1:Number, param2:Number) : void
      {
         super.changePercent(param1,param2);
         this.percentText.text = percent + "%";
         this.percentBar.gotoAndStop(percent);
      }
      
      override public function setTitle(param1:String) : void
      {
         super.setTitle(param1);
      }
      
      override public function destroy() : void
      {
         this.percentText = null;
         this.percentBar = null;
         this.tipTxt = null;
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.changeTip);
         this.timer = null;
         super.destroy();
      }
      
      override protected function getKey() : String
      {
         return KEY;
      }
   }
}

