package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.mapProcess.active.ActivePet_0;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MapProcess_342 extends BaseMapProcess
   {
      
      private var timer:Timer;
      
      private var netMC:MovieClip;
      
      private var activePet:ActivePet_0;
      
      public function MapProcess_342()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.timer = new Timer(5000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this.timer.start();
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         this.timer.stop();
         this.activePet = new ActivePet_0(414);
         this.netMC = conLevel["net_mc"];
         this.netMC.buttonMode = true;
         this.netMC.addEventListener(MouseEvent.CLICK,this.onNetMCClickHandler);
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         if(MapManager.currentMap.id == 342)
         {
            FightInviteManager.fightWithBoss("乌普",0);
         }
      }
      
      private function onNetMCClickHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.netMC.mouseEnabled = false;
         AnimateManager.playMcAnimate(this.netMC,0,"",function():void
         {
            if(activePet.catchPet())
            {
               activePet.visible = false;
               AnimateManager.playMcAnimate(conLevel["isCatch_mc"],0,"",function():void
               {
                  conLevel["isCatch_mc"].buttonMode = true;
                  conLevel["isCatch_mc"].mouseChildren = false;
                  conLevel["isCatch_mc"].addEventListener(MouseEvent.CLICK,clickHandler);
               });
            }
            else
            {
               AnimateManager.playMcAnimate(conLevel["noCatch_mc"],0,"",function():void
               {
                  netMC.mouseEnabled = true;
               });
            }
         });
      }
      
      override public function destroy() : void
      {
         if(Boolean(this.timer))
         {
            this.timer.stop();
            this.timer.removeEventListener(MouseEvent.CLICK,this.onNetMCClickHandler);
            this.timer = null;
         }
         if(Boolean(this.activePet))
         {
            this.activePet.destroy();
            this.activePet = null;
         }
      }
   }
}

