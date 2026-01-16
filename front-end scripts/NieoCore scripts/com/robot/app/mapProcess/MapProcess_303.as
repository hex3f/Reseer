package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.temp.*;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_303 extends BaseMapProcess
   {
      
      private var axle_0:MovieClip;
      
      private var axle_1:MovieClip;
      
      private var axle_2:MovieClip;
      
      private var chestsDoor:MovieClip;
      
      private var chests:MovieClip;
      
      private var timer_0:Timer;
      
      private var timer_1:Timer;
      
      private var timer_2:Timer;
      
      private var checkArr:Array = [false,false];
      
      private var count_0:uint = 0;
      
      private var count_1:uint = 0;
      
      private var count_2:uint = 0;
      
      private var clickAxle:MovieClip;
      
      public function MapProcess_303()
      {
         super();
      }
      
      override protected function init() : void
      {
         MazeController.setup();
         this.axle_0 = conLevel["axle_0"];
         this.axle_1 = conLevel["axle_1"];
         this.axle_0.buttonMode = true;
         this.axle_1.buttonMode = true;
         this.axle_0.mouseChildren = false;
         this.axle_1.mouseChildren = false;
         this.axle_0.addEventListener(MouseEvent.CLICK,this.onClickAxle);
         this.axle_1.addEventListener(MouseEvent.CLICK,this.onClickAxle);
         this.chestsDoor = conLevel["chestsDoor"];
         this.chests = conLevel["chests"];
         this.chests.visible = false;
         this.chests.addEventListener(MouseEvent.CLICK,this.onGetChests);
         this.timer_0 = new Timer(1000,3);
         this.timer_1 = new Timer(1000,3);
         this.timer_2 = new Timer(1000,3);
         this.timer_0.addEventListener(TimerEvent.TIMER,this.onTimer_0);
         this.timer_1.addEventListener(TimerEvent.TIMER,this.onTimer_1);
         this.timer_0.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimer_0_Comp);
         this.timer_1.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimer_1_Comp);
         SocketConnection.addCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
         this.timer_0.removeEventListener(TimerEvent.TIMER,this.onTimer_0);
         this.timer_1.removeEventListener(TimerEvent.TIMER,this.onTimer_1);
         this.timer_0.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimer_0_Comp);
         this.timer_1.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimer_1_Comp);
         this.timer_0 = null;
         this.timer_1 = null;
      }
      
      private function onClickAxle(param1:MouseEvent) : void
      {
         this.clickAxle = param1.currentTarget as MovieClip;
         this.clickAxle.gotoAndStop(2);
         switch(this.clickAxle.name)
         {
            case "axle_0":
               if(this.timer_0.running)
               {
                  this.timer_0.reset();
               }
               this.timer_0.start();
               return;
            case "axle_1":
               if(this.timer_1.running)
               {
                  this.timer_1.reset();
               }
               this.timer_1.start();
         }
      }
      
      private function onTimer_0(param1:TimerEvent) : void
      {
         if(this.count_0 >= 5)
         {
            this.checkArr[0] = true;
         }
         ++this.count_0;
         this.check();
      }
      
      private function onTimer_1(param1:TimerEvent) : void
      {
         if(this.count_1 >= 5)
         {
            this.checkArr[1] = true;
         }
         ++this.count_1;
         this.check();
      }
      
      private function onTimer_0_Comp(param1:TimerEvent) : void
      {
         this.timer_0.stop();
         this.count_0 = 0;
         this.axle_0.gotoAndStop(1);
      }
      
      private function onTimer_1_Comp(param1:TimerEvent) : void
      {
         this.timer_1.stop();
         this.count_1 = 0;
         this.axle_1.gotoAndStop(1);
      }
      
      private function check() : void
      {
         var _loc1_:Boolean = false;
         for each(_loc1_ in this.checkArr)
         {
            if(_loc1_ == false)
            {
               return;
            }
         }
         this.chestsDoor.gotoAndStop(2);
         this.chests.buttonMode = true;
         this.chests.visible = true;
      }
      
      private function onGetChests(param1:MouseEvent) : void
      {
         this.chests.removeEventListener(MouseEvent.CLICK,this.onGetChests);
         DisplayUtil.removeForParent(this.chests);
         SocketConnection.send(CommandID.PRIZE_OF_ATRESIASPACE,1);
      }
      
      private function getPirze(param1:SocketEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         SocketConnection.removeCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
         var _loc7_:AresiaSpacePrize = param1.data as AresiaSpacePrize;
         var _loc8_:Array = _loc7_.monBallList;
         for each(_loc2_ in _loc8_)
         {
            _loc3_ = uint(_loc2_.itemID);
            _loc4_ = uint(_loc2_.itemCnt);
            _loc5_ = ItemXMLInfo.getName(_loc3_);
            _loc6_ = _loc4_ + "个<font color=\'#FF0000\'>" + _loc5_ + "</font>已经放入了你的储存箱！";
            if(_loc4_ != 0)
            {
               LevelManager.tipLevel.addChild(ItemInBagAlert.show(_loc3_,_loc6_));
            }
         }
      }
   }
}

