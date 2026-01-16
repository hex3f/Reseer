package com.robot.app.mapProcess.active.randomPet
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.mapProcess.active.SpecialPetActive;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.BobyModel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.manager.ResourceManager;
   
   public class NormalPet extends BobyModel implements IRandomPet
   {
      
      protected var _petMc:MovieClip;
      
      protected var id:uint;
      
      protected var timer:Timer;
      
      public function NormalPet()
      {
         super();
         this.timer = new Timer(10 * 1000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      public function show(param1:uint) : void
      {
         this.id = param1;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),this.onLoadPet,"pet");
      }
      
      private function click() : void
      {
         FightInviteManager.fightWithSpecial();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         showBox(SpecialPetActive.getStr(this.id));
      }
      
      private function onLoadPet(param1:DisplayObject) : void
      {
         this._petMc = param1 as MovieClip;
         this.addChild(this._petMc);
         this.timer.start();
         this._petMc.buttonMode = true;
         this._petMc.addEventListener(MouseEvent.CLICK,this.onClick);
         (this._petMc.getChildAt(0) as MovieClip).gotoAndStop(1);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.click();
      }
   }
}

