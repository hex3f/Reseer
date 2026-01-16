package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_314 extends BaseMapProcess
   {
      
      private var recorder1:SimpleButton;
      
      private var recorder2:SimpleButton;
      
      private var bossMC:MovieClip;
      
      private var doorMC:MovieClip;
      
      private var door0:MovieClip;
      
      private var door1:MovieClip;
      
      private var clickMC:SimpleButton;
      
      private var doorGame:AppModel;
      
      public function MapProcess_314()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.recorder1 = this.conLevel["recorder1_mc"];
         this.recorder2 = this.conLevel["recorder2_mc"];
         this.bossMC = this.conLevel["boss_mc"];
         this.bossMC.buttonMode = true;
         this.bossMC.mouseChildren = false;
         this.bossMC.gotoAndStop(1);
         this.doorMC = this.conLevel["door_mc"];
         this.door0 = this.conLevel["door_0"];
         ToolTipManager.add(this.door0,"闭锁空间");
         this.door0.buttonMode = true;
         this.door0.visible = false;
         this.door1 = this.conLevel["door_1"];
         ToolTipManager.add(this.door1,"神秘空间");
         this.door1.buttonMode = true;
         this.door1.visible = false;
         this.doorMC.buttonMode = true;
         this.conLevel["guard"].visible = false;
         this.conLevel["guide_mc"].visible = false;
         var _loc1_:int = 0;
         while(_loc1_ < 5)
         {
            this.conLevel["shadow" + _loc1_.toString()].visible = false;
            this.conLevel["pet" + _loc1_.toString()].visible = false;
            _loc1_++;
         }
         this.topLevel["fog"].visible = false;
         this.addEvent();
      }
      
      override public function destroy() : void
      {
         this.removeEvent();
         this.recorder1 = null;
         this.recorder2 = null;
         this.bossMC = null;
         this.doorMC = null;
      }
      
      private function addEvent() : void
      {
         this.recorder1.addEventListener(MouseEvent.CLICK,this.onRecorderClickHandler);
         this.recorder2.addEventListener(MouseEvent.CLICK,this.onRecorderClickHandler);
         this.bossMC.addEventListener(MouseEvent.CLICK,this.onBossMCClickHandler);
         this.doorMC.addEventListener(MouseEvent.CLICK,this.onDoorMCClickHandler);
      }
      
      private function removeEvent() : void
      {
         this.recorder1.removeEventListener(MouseEvent.CLICK,this.onRecorderClickHandler);
         this.recorder2.removeEventListener(MouseEvent.CLICK,this.onRecorderClickHandler);
         this.bossMC.removeEventListener(MouseEvent.CLICK,this.onBossMCClickHandler);
         this.doorMC.removeEventListener(MouseEvent.CLICK,this.onDoorMCClickHandler);
         if(this.doorMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.doorMC.removeEventListener(Event.ENTER_FRAME,this.onDoorEffectHandler);
         }
      }
      
      private function onRecorderClickHandler(param1:MouseEvent) : void
      {
         if(Boolean(this.clickMC))
         {
            if(param1.currentTarget != this.clickMC)
            {
               this.topLevel["pet3"].visible = false;
               DisplayUtil.removeForParent(this.topLevel["pet3"]);
               this.topLevel["pet4"].visible = false;
               DisplayUtil.removeForParent(this.topLevel["pet4"]);
            }
         }
         else
         {
            this.clickMC = param1.currentTarget as SimpleButton;
            this.topLevel["pet1"].visible = false;
            DisplayUtil.removeForParent(this.topLevel["pet1"]);
            this.topLevel["pet2"].visible = false;
            DisplayUtil.removeForParent(this.topLevel["pet2"]);
         }
      }
      
      private function onBossMCClickHandler(param1:MouseEvent) : void
      {
         if(this.bossMC.currentFrame == 2)
         {
            FightInviteManager.fightWithBoss("尤纳斯");
            return;
         }
         this.bossMC.gotoAndStop(2);
      }
      
      private function onDoorMCClickHandler(param1:MouseEvent) : void
      {
         if(this.doorMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.doorMC.removeEventListener(Event.ENTER_FRAME,this.onDoorEffectHandler);
         }
         this.doorMC.gotoAndPlay(2);
         this.doorMC.buttonMode = false;
         this.doorMC.mouseEnabled = false;
         this.doorMC.addEventListener(Event.ENTER_FRAME,this.onDoorEffectHandler);
      }
      
      private function onDoorEffectHandler(param1:Event) : void
      {
         if(this.doorMC.currentFrame == this.doorMC.totalFrames)
         {
            this.doorMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
            this.door0.visible = true;
            this.door1.visible = true;
         }
      }
   }
}

