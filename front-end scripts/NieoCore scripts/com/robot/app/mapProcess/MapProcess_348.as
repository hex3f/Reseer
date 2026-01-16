package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.taskscollection.Task947;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_348 extends BaseMapProcess
   {
      
      private var _eye:MovieClip;
      
      private var _numLight:int;
      
      private var _light:MovieClip;
      
      private var _hamo:MovieClip;
      
      private var _takelin:MovieClip;
      
      private var _saiweier:MovieClip;
      
      private var _taxiya:MovieClip;
      
      public function MapProcess_348()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.initBoss();
         this.initInter();
         Task947.initForMap348(this);
      }
      
      override public function destroy() : void
      {
         Task947.destroy();
         if(Boolean(this._hamo))
         {
            ToolTipManager.remove(this._hamo);
            this._hamo.removeEventListener(MouseEvent.CLICK,this.onClickHamo);
            this._hamo = null;
         }
         if(Boolean(this._takelin))
         {
            ToolTipManager.remove(this._takelin);
            this._takelin.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
            this._takelin = null;
         }
         if(Boolean(this._saiweier))
         {
            ToolTipManager.remove(this._saiweier);
            this._saiweier.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
            this._saiweier = null;
         }
         if(Boolean(this._taxiya))
         {
            ToolTipManager.remove(this._taxiya);
            this._taxiya.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
            this._taxiya = null;
         }
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterHandler);
         this._eye = null;
         this._light.removeEventListener(MouseEvent.CLICK,this.onClickLight);
         this._light = null;
      }
      
      public function initBoss() : void
      {
         this._hamo = this.conLevel["hamo"] as MovieClip;
         this._hamo.buttonMode = true;
         this._hamo.addEventListener(MouseEvent.CLICK,this.onClickHamo);
         ToolTipManager.add(this._hamo,"哈莫雷特");
         this._takelin = this.conLevel["takelin"] as MovieClip;
         this._takelin.buttonMode = true;
         this._takelin.addEventListener(MouseEvent.CLICK,this.onFightBoss);
         ToolTipManager.add(this._takelin,"塔克林");
         this._saiweier = this.conLevel["saiweier"] as MovieClip;
         this._saiweier.buttonMode = true;
         this._saiweier.addEventListener(MouseEvent.CLICK,this.onFightBoss);
         ToolTipManager.add(this._saiweier,"塞维尔");
         this._taxiya = this.conLevel["taxiya"] as MovieClip;
         this._taxiya.buttonMode = true;
         this._taxiya.addEventListener(MouseEvent.CLICK,this.onFightBoss);
         ToolTipManager.add(this._taxiya,"塔西亚");
      }
      
      public function onClickHamo(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("哈莫雷特",2);
      }
      
      private function onFightBoss(param1:MouseEvent) : void
      {
         if(MapManager.currentMap.id == 348)
         {
            if(param1.currentTarget.name == "taxiya")
            {
               FightInviteManager.fightWithBoss("塔西亚",1);
            }
            if(param1.currentTarget.name == "saiweier")
            {
               FightInviteManager.fightWithBoss("塞维尔",3);
            }
            if(param1.currentTarget.name == "takelin")
            {
               FightInviteManager.fightWithBoss("塔克林",0);
            }
         }
      }
      
      private function initInter() : void
      {
         this._eye = this.conLevel["eye"] as MovieClip;
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterHandler);
         this._light = this.conLevel["light"] as MovieClip;
         this._light.addEventListener(MouseEvent.CLICK,this.onClickLight);
      }
      
      private function onWalkEnterHandler(param1:RobotEvent) : void
      {
         this._eye.x = 64 + (MainManager.actorModel.x - 180) / 780 * 16;
         this._eye.y = 56 - (MainManager.actorModel.y - 80) / 480 * 16;
      }
      
      private function onClickLight(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target is SimpleButton)
         {
            _loc2_ = param1.target.parent as MovieClip;
            if(_loc2_.currentFrame != 2)
            {
               _loc2_.gotoAndStop(2);
               this._numLight += 1;
               if(this._numLight == 3)
               {
                  this._light.removeEventListener(MouseEvent.CLICK,this.onClickLight);
                  (this.conLevel["shengjiang"] as MovieClip).play();
                  DisplayUtil.removeForParent(this.typeLevel["path"] as MovieClip);
                  MapManager.currentMap.makeMapArray();
               }
            }
         }
      }
   }
}

