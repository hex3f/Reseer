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
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_304 extends BaseMapProcess
   {
      
      private var btn_0:MovieClip;
      
      private var btn_1:MovieClip;
      
      private var arrowheadMC:MovieClip;
      
      private var chestsMC:MovieClip;
      
      private var direction:uint = 1;
      
      private var count:uint = 1;
      
      public function MapProcess_304()
      {
         super();
      }
      
      override protected function init() : void
      {
         MazeController.setup();
         var _loc1_:uint = Math.floor(Math.random() * 5);
         this.arrowheadMC = conLevel["arrowheadMC"];
         this.arrowheadMC.gotoAndStop(_loc1_);
         this.direction = _loc1_;
         this.btn_0 = conLevel["btn_0"];
         this.btn_1 = conLevel["btn_1"];
         this.btn_0.buttonMode = true;
         this.btn_1.buttonMode = true;
         var _loc2_:uint = Math.floor(Math.random() * 5);
         var _loc3_:uint = Math.floor(Math.random() * 5);
         this.btn_0.gotoAndStop(_loc2_);
         this.btn_1.gotoAndStop(_loc3_);
         this.btn_0.addEventListener(MouseEvent.CLICK,this.onClickBox);
         this.btn_1.addEventListener(MouseEvent.CLICK,this.onClickBox);
         this.chestsMC = conLevel["chestsMC"];
         this.chestsMC.gotoAndStop(1);
         SocketConnection.addCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
      }
      
      private function onClickBox(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         var mc:MovieClip = evt.currentTarget as MovieClip;
         this.count = mc.currentFrame;
         if(this.count == mc.totalFrames)
         {
            mc.gotoAndStop(1);
         }
         else
         {
            ++this.count;
            mc.gotoAndStop(this.count);
         }
         if(this.chestsMC == null)
         {
            return;
         }
         if(this.btn_0.currentFrame == this.direction && this.btn_1.currentFrame == this.direction)
         {
            this.chestsMC.gotoAndPlay(2);
            this.chestsMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               if(chestsMC.currentFrame == chestsMC.totalFrames)
               {
                  chestsMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  chestsMC.buttonMode = true;
                  chestsMC.addEventListener(MouseEvent.CLICK,onClickChests);
               }
            });
         }
      }
      
      private function onClickChests(param1:MouseEvent) : void
      {
         this.chestsMC.removeEventListener(MouseEvent.CLICK,this.onClickChests);
         DisplayUtil.removeForParent(this.chestsMC);
         this.chestsMC = null;
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

