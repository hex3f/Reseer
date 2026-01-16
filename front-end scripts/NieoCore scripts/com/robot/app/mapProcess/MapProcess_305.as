package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.*;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.npc.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.events.SocketEvent;
   
   public class MapProcess_305 extends BaseMapProcess
   {
      
      private var jiantou_0:MovieClip;
      
      private var jiantou_1:MovieClip;
      
      private var qita:MovieClip;
      
      private var oilcanArr:Array = [];
      
      public function MapProcess_305()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         _loc1_ = null;
         MazeController.setup();
         conLevel["door_0"].visible = false;
         conLevel["door_1"].visible = false;
         this.jiantou_0 = conLevel["jiantou_0"];
         this.jiantou_1 = conLevel["jiantou_1"];
         this.jiantou_0.visible = false;
         this.jiantou_1.visible = false;
         this.qita = conLevel["qita"];
         this.qita.visible = false;
         while(_loc3_ < 8)
         {
            _loc2_ = "oilcan_" + _loc3_;
            _loc1_ = conLevel[_loc2_] as MovieClip;
            _loc1_.buttonMode = true;
            _loc1_.gotoAndStop(1);
            _loc1_.addEventListener(MouseEvent.CLICK,this.onClickOilcan);
            this.oilcanArr.push(_loc1_);
            _loc3_++;
         }
      }
      
      private function onClickOilcan(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc4_.currentFrame == 1)
         {
            _loc4_.gotoAndStop(2);
         }
         else
         {
            _loc4_.gotoAndStop(1);
         }
         for each(_loc2_ in this.oilcanArr)
         {
            if(_loc2_.currentFrame != 2)
            {
               return;
            }
         }
         for each(_loc3_ in this.oilcanArr)
         {
            _loc3_.removeEventListener(MouseEvent.CLICK,this.onClickOilcan);
            _loc3_.buttonMode = false;
         }
         conLevel["door_0"].visible = true;
         conLevel["door_1"].visible = true;
         this.jiantou_0.visible = true;
         this.jiantou_1.visible = true;
         if(Math.random() >= 0.5)
         {
            this.qita.visible = true;
            this.qita.buttonMode = true;
            this.qita.addEventListener(MouseEvent.CLICK,this.onFightQita);
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.oilcanArr)
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onClickOilcan);
            this.qita.removeEventListener(MouseEvent.CLICK,this.onFightQita);
         }
         MazeController.destroy();
      }
      
      private function onFightQita(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         SocketConnection.addCmdListener(CommandID.TALK_COUNT,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.TALK_COUNT,arguments.callee);
            var _loc3_:MiningCountInfo = param1.data as MiningCountInfo;
            var _loc4_:uint = _loc3_.miningCount;
            if(_loc4_ == 0)
            {
               FightInviteManager.fightWithBoss("奇塔");
            }
            else
            {
               NpcDialog.show(NPC.SEER,["已经达到捕捉上限了哟~"],["……"],null);
            }
         });
         SocketConnection.send(CommandID.TALK_COUNT,700013 - 500000);
      }
   }
}

