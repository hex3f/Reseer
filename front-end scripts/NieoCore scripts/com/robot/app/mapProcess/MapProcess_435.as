package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_435 extends BaseMapProcess
   {
      
      private var _boadMC:MovieClip;
      
      private var _avatarMC:MovieClip;
      
      private var _boatOutMC:MovieClip;
      
      private var _bossMC:MovieClip;
      
      public function MapProcess_435()
      {
         super();
         this.init();
         this.initResource();
      }
      
      public static function playMC(param1:MovieClip, param2:uint = 0, param3:Function = null) : void
      {
         var childMC:MovieClip = null;
         var mc:MovieClip = null;
         var frame:uint = 0;
         var func:Function = null;
         childMC = null;
         mc = param1;
         frame = param2;
         func = param3;
         if(frame > 0)
         {
            mc.gotoAndStop(frame);
            mc.addEventListener(Event.ENTER_FRAME,function():void
            {
               if(mc.currentFrame == frame)
               {
                  childMC = mc.getChildAt(0) as MovieClip;
                  if(Boolean(childMC))
                  {
                     mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                     mc = childMC;
                     mc.addEventListener(Event.ENTER_FRAME,function():void
                     {
                        if(mc.currentFrame == mc.totalFrames)
                        {
                           LevelManager.openMouseEvent();
                           mc.stop();
                           mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                           if(func != null)
                           {
                              func();
                           }
                        }
                     });
                     LevelManager.closeMouseEvent();
                     mc.gotoAndPlay(1);
                  }
               }
            });
         }
         else
         {
            mc.addEventListener(Event.ENTER_FRAME,function():void
            {
               if(mc.currentFrame == mc.totalFrames)
               {
                  LevelManager.openMouseEvent();
                  mc.stop();
                  mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  if(func != null)
                  {
                     func();
                  }
               }
            });
            LevelManager.closeMouseEvent();
            mc.gotoAndPlay(1);
         }
      }
      
      override protected function init() : void
      {
         this._bossMC = topLevel["boss_mc"];
         this._bossMC.visible = false;
         animatorLevel["errorMC"].visible = false;
         animatorLevel["shipInMC"].visible = false;
         animatorLevel["boatInMC"].visible = false;
         conLevel["pet_mc_0"].visible = false;
         conLevel["task_536"].visible = false;
         conLevel["box_btn"].visible = false;
         conLevel["jucks_mc"].visible = false;
         conLevel["jucks1_mc"].visible = false;
         conLevel["jucks2_mc"].visible = false;
         conLevel["jucks3_mc"].visible = false;
         conLevel["pet_mc_1"].buttonMode = true;
         conLevel["pet_mc_1"].mouseEnabled = true;
         conLevel["pet_mc_1"].addEventListener(MouseEvent.CLICK,this.clickPet_1);
      }
      
      private function clickPet_1(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("紫炎虫",1);
      }
      
      public function initResource() : void
      {
         this._boadMC = animatorLevel["boatMC"];
         this._boadMC.visible = false;
         this._avatarMC = conLevel["avatarMC"];
         this._avatarMC.mouseEnabled = true;
         this._avatarMC.buttonMode = true;
         this._avatarMC.gotoAndStop(1);
         this._boatOutMC = animatorLevel["boatOutMC"];
         this._boatOutMC.visible = false;
         this._avatarMC.addEventListener(MouseEvent.CLICK,this.onAvatarClickHandler);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.petFightOver);
      }
      
      private function petFightOver(param1:PetFightEvent) : void
      {
         var _loc2_:FightOverInfo = null;
         var _loc3_:uint = 0;
         var _loc4_:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.petFightOver);
         _loc2_ = _loc4_.dataObj as FightOverInfo;
         if(_loc2_.winnerID == MainManager.actorID)
         {
         }
      }
      
      private function onBossClickHandler(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("克拉尼特",1);
      }
      
      private function onAvatarClickHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(MainManager.actorInfo.clothes.length > 0)
         {
            NpcDialog.show(NPC.SEER,["糟糕！这里的气体果然极具腐蚀！看来必须0xff0000脱去身上的装备0xffffff才能前行了！"],["左边的石块怎么看起来这么奇怪？"]);
         }
         else
         {
            this._avatarMC.gotoAndStop(2);
            this._avatarMC.mouseEnabled = false;
            this._avatarMC.mouseChildren = false;
            this._boadMC.visible = true;
            playMC(this._boadMC,0,function():void
            {
               NpcDialog.show(NPC.NIT,["呵呵......我们又见面了！这次你是想要通过死河呢？还是想和我老家伙切磋一下呢？"],["什么？你难道是精灵？(我要和你切磋)","我想要渡过这条死河"],[fightBoss,crossRiver]);
            });
         }
      }
      
      private function crossRiver() : void
      {
         MainManager.actorModel.visible = false;
         DisplayUtil.removeForParent(this._boadMC);
         this._boadMC.visible = false;
         this._boatOutMC.visible = true;
         playMC(this._boatOutMC,2,function():void
         {
            MapManager.changeMap(436);
         });
      }
      
      private function fightBoss() : void
      {
         FightInviteManager.fightWithBoss("克拉尼特");
      }
      
      override public function destroy() : void
      {
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.petFightOver);
         MainManager.actorModel.visible = true;
         if(Boolean(this._avatarMC))
         {
            this._avatarMC.removeEventListener(MouseEvent.CLICK,this.onAvatarClickHandler);
         }
      }
   }
}

