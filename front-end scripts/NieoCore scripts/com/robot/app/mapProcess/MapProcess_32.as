package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.leiyiTrain.*;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_32 extends BaseMapProcess
   {
      
      public static var hasPlayAi:Boolean = false;
      
      private var _rockMc:MovieClip;
      
      private var _rockBtn:MovieClip;
      
      private var _leiyi_game:SimpleButton;
      
      public function MapProcess_32()
      {
         super();
      }
      
      override protected function init() : void
      {
         try
         {
            EventManager.addEventListener("LY_OUT",this.onLYShow);
            this._rockMc = conLevel.getChildByName("rockMc") as MovieClip;
            this._rockMc.gotoAndStop(1);
            this._rockMc.buttonMode = true;
            this._rockMc.mouseEnabled = false;
            this._rockMc.visible = false;
            this._rockBtn = conLevel.getChildByName("rockBtn") as MovieClip;
            this._rockBtn.mouseEnabled = false;
            this._rockBtn.visible = false;
            this._rockBtn.buttonMode = true;
            conLevel["bossBtn"].mouseEnabled = false;
            this.check();
         }
         catch(error:Error)
         {
         }
         try
         {
            conLevel["kaku_leiyi"].visible = false;
            conLevel["findItemMc"].visible = false;
            conLevel["jiaLeiyi"].visible = false;
            conLevel["task_122"].visible = false;
            btnLevel["cloud_mc"].visible = false;
            animatorLevel["leyi_effect"].visible = false;
            animatorLevel["leiyi_mc"].visible = false;
            animatorLevel["kaku32_mc"].visible = false;
            this._leiyi_game = btnLevel["game_btn"];
            ToolTipManager.add(this._leiyi_game,"雷伊特训");
            this._leiyi_game.addEventListener(MouseEvent.CLICK,this.clickLeiYIgame);
            this.initTask122();
         }
         catch(error:Error)
         {
         }
      }
      
      private function initTask122() : void
      {
         var pet:PetListInfo = null;
         var petInfo:PetInfo = null;
         var petArray:Array = PetManager.getBagMap();
         for each(pet in petArray)
         {
            if(pet.id == 70)
            {
               petInfo = PetManager.getPetInfo(pet.catchTime);
               PetManager.getCanStudySkill(petInfo.catchTime,function(param1:Array):void
               {
                  var skillArray:Array = param1;
                  if(skillArray.indexOf(10825) != -1)
                  {
                     DisplayUtil.removeForParent(conLevel["task_122"]);
                     conLevel["task_122"] = null;
                     DisplayUtil.removeForParent(conLevel["jiaLeiyi"]);
                     conLevel["jiaLeiyi"] = null;
                  }
                  else if(TasksManager.getTaskStatus(122) == TasksManager.UN_ACCEPT)
                  {
                     DisplayUtil.removeForParent(conLevel["task_122"]);
                     conLevel["task_122"] = null;
                     DisplayUtil.removeForParent(conLevel["jiaLeiyi"]);
                     conLevel["jiaLeiyi"] = null;
                  }
                  else if(TasksManager.getTaskStatus(122) == TasksManager.ALR_ACCEPT)
                  {
                     TasksManager.getProStatusList(122,function(param1:Array):void
                     {
                        if(Boolean(param1[0]) && Boolean(param1[1]) && Boolean(param1[2]) && !param1[3])
                        {
                           initTask_122();
                        }
                        else
                        {
                           DisplayUtil.removeForParent(conLevel["task_122"]);
                           conLevel["task_122"] = null;
                           DisplayUtil.removeForParent(conLevel["jiaLeiyi"]);
                           conLevel["jiaLeiyi"] = null;
                        }
                     });
                  }
                  else if(TasksManager.getTaskStatus(122) == TasksManager.COMPLETE)
                  {
                     DisplayUtil.removeForParent(conLevel["task_122"]);
                     conLevel["task_122"] = null;
                     DisplayUtil.removeForParent(conLevel["jiaLeiyi"]);
                     conLevel["jiaLeiyi"] = null;
                  }
               });
               return;
            }
         }
         DisplayUtil.removeForParent(conLevel["task_122"]);
         conLevel["task_122"] = null;
         DisplayUtil.removeForParent(conLevel["jiaLeiyi"]);
         conLevel["jiaLeiyi"] = null;
      }
      
      private function initTask_122() : void
      {
         conLevel["bossMc"].visible = false;
         conLevel["bossBtn"].visible = false;
         conLevel["bossBtn"].mouseEnabled = false;
         if(!hasPlayAi)
         {
            hasPlayAi = true;
            conLevel["task_122"].visible = true;
            AnimateManager.playMcAnimate(conLevel["task_122"],0,"",function():void
            {
               NpcDialog.show(NPC.GAIYA,["我不喜欢欠别人什么！既然你救了我一命，我就告诉你如何突破自己的极限！呵呵……"],["真正的敌人？自己？"],[function():void
               {
                  AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("task_122_1"),function():void
                  {
                     NpcDialog.show(NPC.GAIYA,["准备好作战了吗？呵呵……你能否打败自己呢？"],["准备好了！"],[function():void
                     {
                        NpcDialog.show(NPC.LEIYI,["我一定可以战胜自己！我一定要完成于赫然卡星人的约定！无限的潜能必定会释放！"],["点击水银湖中的倒影吧！"],[function():void
                        {
                           conLevel["jiaLeiyi"].visible = true;
                           conLevel["jiaLeiyi"].buttonMode = true;
                           conLevel["jiaLeiyi"].addEventListener(MouseEvent.CLICK,onJiaLeiyiClick);
                        }]);
                     }]);
                  });
               }]);
            });
         }
         else
         {
            conLevel["jiaLeiyi"].visible = true;
            conLevel["jiaLeiyi"].buttonMode = true;
            conLevel["jiaLeiyi"].addEventListener(MouseEvent.CLICK,this.onJiaLeiyiClick);
         }
      }
      
      private function onJiaLeiyiClick(param1:MouseEvent) : void
      {
         var info:PetInfo = null;
         var e:MouseEvent = param1;
         if(PetManager.length == 0)
         {
            Alarm.show("你的背包中没有精灵哦！");
            return;
         }
         info = PetManager.getPetInfo(PetManager.defaultTime);
         if(Boolean(info))
         {
            if(info.id != 70)
            {
               NpcDialog.show(NPC.LEIYI_IMAGE,["怎么？怕了吗？雷伊！你只有靠自己的力量战胜自己，这才能释放潜能！"],["快将雷伊设为首选精灵，点击雷伊倒影决战吧！"]);
            }
            else
            {
               NpcDialog.show(NPC.LEIYI_IMAGE,["准备好就开战！少婆婆妈妈的！快点击水银湖中的我对战吧！"],["注意看水银湖！"],[function():void
               {
                  LeiyiTrainController.fightJiaLeiyi();
               }]);
            }
         }
      }
      
      private function onLYShow(param1:Event) : void
      {
         this.showLY();
      }
      
      private function showLY() : void
      {
         conLevel["bossMc"]["mc"].gotoAndPlay(2);
         conLevel["bossBtn"].mouseEnabled = true;
      }
      
      public function hitLY() : void
      {
         FightInviteManager.fightWithBoss("雷伊");
      }
      
      private function check() : void
      {
         if(TasksManager.getTaskStatus(401) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatus(401,1,function(param1:Boolean):void
            {
               if(!param1)
               {
                  _rockMc.mouseEnabled = true;
                  _rockMc.visible = true;
                  _rockBtn.mouseEnabled = true;
                  _rockBtn.visible = true;
               }
            });
         }
      }
      
      private function clickLeiYIgame(param1:MouseEvent) : void
      {
         LeiyiTrainController.showTrainPanel();
      }
      
      override public function destroy() : void
      {
         EventManager.removeEventListener("LY_OUT",this.onLYShow);
         this._rockMc.removeEventListener(MouseEvent.CLICK,this.onMusicClick);
         this._rockMc = null;
         this._rockBtn = null;
         LeiyiTrainController.destory();
         ToolTipManager.remove(this._leiyi_game);
         this._leiyi_game.removeEventListener(MouseEvent.CLICK,this.clickLeiYIgame);
         this._leiyi_game = null;
         if(Boolean(conLevel["jiaLeiyi"]))
         {
            conLevel["jiaLeiyi"].removeEventListener(MouseEvent.CLICK,this.onJiaLeiyiClick);
         }
      }
      
      private function onMusicClick(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(!MainManager.actorModel.getIsPetFollw(22) && !MainManager.actorModel.getIsPetFollw(23) && !MainManager.actorModel.getIsPetFollw(24))
         {
            Alarm.show("只有带上你的<font color=\'#ff0000\'>毛毛</font>，这些音符才会起到作用呢。");
            return;
         }
         TasksManager.complete(401,1,function(param1:Boolean):void
         {
            _rockMc.removeEventListener(MouseEvent.CLICK,onMusicClick);
            if(param1)
            {
               DisplayUtil.removeForParent(_rockMc);
               Alarm.show("你帮助毛毛找到了一个音符！");
            }
         });
      }
      
      public function clearWaste() : void
      {
      }
      
      public function onRockHit() : void
      {
         DisplayUtil.removeForParent(this._rockBtn);
         this._rockMc.gotoAndStop(2);
         this._rockMc.addEventListener(MouseEvent.CLICK,this.onMusicClick);
      }
      
      public function onbossHit() : void
      {
         FightInviteManager.fightWithBoss("雷伊");
      }
   }
}

