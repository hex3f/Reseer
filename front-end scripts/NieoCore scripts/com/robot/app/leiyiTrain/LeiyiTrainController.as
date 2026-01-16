package com.robot.app.leiyiTrain
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.petUpdate.updatePanel.UpdateSkillManager;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.PetEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.info.pet.update.UpdateSkillInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.EventManager;
   
   public class LeiyiTrainController
   {
      
      private static var _trainApp:AppModel;
      
      private static var _energyPanel:AppModel;
      
      private static var _skillPanel:AppModel;
      
      private static var _info:UpdateSkillInfo;
      
      public static var isPlayEnergy:Boolean = false;
      
      private static var _isPlay:Boolean = false;
      
      private static var _isShow:Boolean = false;
      
      public function LeiyiTrainController()
      {
         super();
      }
      
      public static function creatIcon() : void
      {
         var idArray:Array = null;
         var proArray:Array = null;
         idArray = null;
         proArray = null;
         idArray = [];
         proArray = [];
         PetManager.addEventListener(PetEvent.UPDATE_INFO,function(param1:PetEvent):void
         {
            var pet:PetListInfo = null;
            var e:PetEvent = param1;
            var petArray:Array = PetManager.getBagMap();
            for each(pet in petArray)
            {
               if(pet.id == 70)
               {
                  PetManager.getCanStudySkill(pet.catchTime,function(param1:Array):void
                  {
                     var skillArray:Array = null;
                     skillArray = param1;
                     if(skillArray.indexOf(10825) != -1)
                     {
                        return;
                     }
                     if(TasksManager.getTaskStatus(121) == TasksManager.UN_ACCEPT)
                     {
                        TasksManager.accept(121);
                     }
                     if(TasksManager.getTaskStatus(121) == TasksManager.ALR_ACCEPT && skillArray.indexOf(10823) != -1)
                     {
                        idArray.push(121);
                        proArray.push(0);
                     }
                     if(TasksManager.getTaskStatus(122) != TasksManager.UN_ACCEPT)
                     {
                        TasksManager.getProStatusList(122,function(param1:Array):void
                        {
                           if(!param1[0] && skillArray.indexOf(20363) != -1)
                           {
                              idArray.push(122);
                              proArray.push(0);
                           }
                           if(!param1[1] && skillArray.indexOf(10824) != -1)
                           {
                              idArray.push(122);
                              proArray.push(1);
                           }
                           if(!param1[2] && skillArray.indexOf(20364) != -1)
                           {
                              idArray.push(122);
                              proArray.push(2);
                           }
                           if(!param1[3] && skillArray.indexOf(10825) != -1)
                           {
                              idArray.push(122);
                              proArray.push(3);
                           }
                           completeTaskPro(idArray,proArray);
                        });
                     }
                     else
                     {
                        completeTaskPro(idArray,proArray);
                     }
                  });
                  return;
               }
            }
         });
         PetManager.upDate();
      }
      
      private static function completeTaskPro(param1:Array, param2:Array) : void
      {
         var id:Array = null;
         var pro:Array = null;
         id = param1;
         pro = param2;
         if(id.length > 0 && pro.length > 0)
         {
            TasksManager.complete(id[0],pro[0],function(param1:Boolean):void
            {
               id.shift();
               pro.shift();
               completeTaskPro(id,pro);
            });
         }
      }
      
      public static function delIcon() : void
      {
      }
      
      private static function onIconClickHandler(param1:MouseEvent) : void
      {
         showSkillPanel(false);
      }
      
      public static function showTrainPanel() : void
      {
         creatIcon();
         if(!_trainApp)
         {
            _trainApp = new AppModel(ClientConfig.getAppModule("LeiyiTrainPanel"),"正在打开训练面板");
            _trainApp.setup();
            _trainApp.sharedEvents.addEventListener(Event.OPEN,onOpenHandler);
            _trainApp.sharedEvents.addEventListener(Event.CLOSE,onCloseHandler);
         }
         _trainApp.show();
      }
      
      private static function destroyTrainPanel() : void
      {
         if(Boolean(_trainApp))
         {
            _trainApp.sharedEvents.removeEventListener(Event.OPEN,onOpenHandler);
            _trainApp.sharedEvents.removeEventListener(Event.CLOSE,onCloseHandler);
            _trainApp.destroy();
            _trainApp = null;
         }
      }
      
      private static function onOpenHandler(param1:Event) : void
      {
         _trainApp.hide();
         check(showEnergyPanel);
      }
      
      private static function onCloseHandler(param1:Event) : void
      {
         _trainApp.hide();
         check(showSkillPanel);
      }
      
      private static function check(param1:Function) : void
      {
         if(PetManager.length == 0)
         {
            Alarm.show("你的背包中没有精灵哦！");
            return;
         }
         var _loc2_:PetInfo = PetManager.getPetInfo(PetManager.defaultTime);
         if(Boolean(_loc2_))
         {
            if(_loc2_.id != 70)
            {
               NpcDialog.show(NPC.SEER,["哎呀！快把雷伊设为对战的首选精灵，再来进行雷伊极限修行哦！"],["我现在就把雷伊设为首选精灵！"]);
            }
            else
            {
               param1();
            }
         }
      }
      
      public static function showEnergyPanel() : void
      {
         LeiyiTrainController.check(LeiyiEnergyNewPanelController.show);
      }
      
      public static function showSkillPanel(param1:Boolean = true) : void
      {
         if(!_skillPanel)
         {
            _skillPanel = new AppModel(ClientConfig.getAppModule("LeiyiSkillTrainPanel"),"正在打开雷伊体能训练");
            _skillPanel.setup();
            _skillPanel.sharedEvents.addEventListener(Event.OPEN,onOpenTrainHandler);
         }
         _skillPanel.init(param1);
         _skillPanel.show();
      }
      
      private static function onOpenTrainHandler(param1:Event) : void
      {
         showTrainPanel();
      }
      
      public static function destory() : void
      {
         destroyTrainPanel();
         if(Boolean(_energyPanel))
         {
            _energyPanel.sharedEvents.removeEventListener(Event.OPEN,onOpenHandler);
            _energyPanel.destroy();
            _energyPanel = null;
         }
         if(Boolean(_skillPanel))
         {
            _skillPanel.sharedEvents.removeEventListener(Event.OPEN,onOpenHandler);
            _skillPanel.destroy();
            _skillPanel = null;
         }
      }
      
      public static function initTrain_0() : void
      {
         var info:PetInfo = null;
         if(TasksManager.getTaskStatus(121) != TasksManager.ALR_ACCEPT)
         {
            return;
         }
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
               NpcDialog.show(NPC.SEER,["哎呀！快把雷伊设为对战的0xff0000首选精灵0xffffff再点击0xff0000里奥斯0xffffff吧！0xff0000白光刃0xffffff能否在这次对战中发挥极限呢？"],["准备好了就点击里奥斯吧！"]);
            }
            else
            {
               NpcDialog.show(NPC.SEER,["雷神啊雷神！你准备好了吗？一会记得多使用0xff0000白光刃0xffffff，我相信你一定能够领悟其中的奥秘的！0xff0000里奥斯0xffffff来吧！"],["我要开始对战！"],[function():void
               {
                  if(!_isPlay)
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("leiyiStartAimat"),function():void
                     {
                        _isPlay = true;
                        startFight_0();
                     });
                  }
                  else
                  {
                     startFight_0();
                  }
               }]);
            }
         }
      }
      
      private static function startFight_0() : void
      {
         PetManager.addEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_0);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_0);
         if(MapManager.currentMap.id == 17)
         {
            FightInviteManager.fightWithBoss("里奥斯",1);
         }
      }
      
      private static function onSkillHandler_0(param1:PetEvent) : void
      {
         _isShow = true;
         _info = param1.obj() as UpdateSkillInfo;
         PetManager.removeEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_0);
         TasksManager.complete(121,0);
         TasksManager.setTaskStatus(121,3);
      }
      
      private static function onFightComplete_0(param1:PetFightEvent) : void
      {
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_0);
         if((e.dataObj as FightOverInfo).winnerID == MainManager.actorID)
         {
            if(_isShow)
            {
               _isPlay = false;
               _isShow = false;
               UpdateSkillManager.update(_info,function():void
               {
                  AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("leiyiVsliaos"));
               });
            }
            else
            {
               NpcDialog.show(NPC.SEER,["怎么可能！难道是没有使用正确的技能吗？雷伊你再用0xff0000白光刃0xffffff试试！"],["快点击里奥斯再试试吧！"]);
            }
         }
      }
      
      public static function initTrain_1(param1:MovieClip) : void
      {
         var info:PetInfo = null;
         var mc:MovieClip = null;
         mc = param1;
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
               NpcDialog.show(NPC.TIYASI,["很久以前雷伊曾经救过我！我只会用尽全身的能力去训练他！把雷伊设为你的0xff0000首选精灵0xffffff再来吧！"],["准备好了吗？点击提亚斯吧！"]);
            }
            else if(!_isPlay)
            {
               mc.mouseEnabled = false;
               mc.mouseChildren = false;
               AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("leiyiHelpTiyas"),function():void
               {
                  NpcDialog.show(NPC.TIYASI,["如果没有你，我早已经灰飞烟灭了！呵呵……雷伊和我进行精灵对战吧！记得使用0xff0000雷雨天0xffffff！"],["快点击提亚斯进行对战吧！"],[function():void
                  {
                     _isPlay = true;
                     mc.mouseEnabled = true;
                     mc.mouseChildren = true;
                  }]);
               });
            }
            else
            {
               startFight_1();
            }
         }
      }
      
      private static function startFight_1() : void
      {
         NpcDialog.show(NPC.TIYASI,["我的能力就是速度快，0xff0000雷雨天0xffffff应该可以在对战时发挥它的极限作用！记住了吗？"],["我要开始对战！"],[function():void
         {
            PetManager.addEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_1);
            EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_1);
            if(MapManager.currentMap.id == 27)
            {
               FightInviteManager.fightWithBoss("提亚斯",1);
            }
         }]);
      }
      
      private static function onSkillHandler_1(param1:PetEvent) : void
      {
         _isShow = true;
         _info = param1.obj() as UpdateSkillInfo;
         PetManager.removeEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_1);
      }
      
      private static function onFightComplete_1(param1:PetFightEvent) : void
      {
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_1);
         if((e.dataObj as FightOverInfo).winnerID == MainManager.actorID)
         {
            if(_isShow)
            {
               _isPlay = false;
               _isShow = false;
               TasksManager.complete(122,0,function(param1:Boolean):void
               {
                  var b:Boolean = param1;
                  UpdateSkillManager.update(_info,function():void
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("leiyiStartAimat2"));
                  });
               });
            }
            else
            {
               NpcDialog.show(NPC.TIYASI,["记住了！每个精灵都会有自己的特点！我就是速度快！雷伊技能中的0xff0000雷雨天0xffffff可以在和我对战中发挥极限！再来一次!"],["快点击提亚斯再来试试吧！"]);
            }
         }
      }
      
      public static function initTrain_2(param1:SimpleButton) : void
      {
         var info:PetInfo = null;
         var mc:SimpleButton = null;
         mc = param1;
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
               NpcDialog.show(NPC.LEINADUO,["我佩服的精灵只有一个！那就是0xff0000雷伊0xffffff！我只会帮助雷伊训练它的特殊技能0xff0000极电千鸟0xffffff！"],["准备好了吗？点击雷纳多吧！"]);
            }
            else if(!_isPlay)
            {
               mc.enabled = false;
               mc.mouseEnabled = false;
               NpcDialog.show(NPC.LEINADUO,["呵呵！当初阻止我破坏提亚斯的蛋？现在竟然还想我训练你的特殊技能？休想！！！接招吧！"],["雷伊小心！"],[function():void
               {
                  AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("test1"),function():void
                  {
                     NpcDialog.show(NPC.LEINADUO,["为什么？为什么？你明明可以打败我的！但是却为了我的孩子……"],["雷伊为什么停止攻击了呢？"],[function():void
                     {
                        NpcDialog.show(NPC.LEIYI,["每个精灵的元神都有着它自己的意义不是吗？当初我会保护提亚斯的蛋，现在我一样会保护你的孩子……"],["雷伊！果然是当之无愧的精灵之王！"],[function():void
                        {
                           NpcDialog.show(NPC.LEINADUO,["呵呵！点我和我进行对战！记得使用0xff0000极电千鸟0xffffff，我来训练你！"],["快点击雷纳多吧！"],[function():void
                           {
                              _isPlay = true;
                              mc.enabled = true;
                              mc.mouseEnabled = true;
                           }]);
                        }]);
                     }]);
                  });
               }]);
            }
            else
            {
               startFight_2();
            }
         }
      }
      
      private static function startFight_2() : void
      {
         PetManager.addEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_2);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_2);
         if(MapManager.currentMap.id == 49)
         {
            FightInviteManager.fightWithBoss("雷纳多",1);
         }
      }
      
      private static function onSkillHandler_2(param1:PetEvent) : void
      {
         _isShow = true;
         _info = param1.obj() as UpdateSkillInfo;
         PetManager.removeEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_2);
      }
      
      private static function onFightComplete_2(param1:PetFightEvent) : void
      {
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_2);
         if((e.dataObj as FightOverInfo).winnerID == MainManager.actorID)
         {
            if(_isShow)
            {
               _isPlay = false;
               _isShow = false;
               TasksManager.complete(122,1,function(param1:Boolean):void
               {
                  var b:Boolean = param1;
                  UpdateSkillManager.update(_info,function():void
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("test2"));
                  });
               });
            }
            else
            {
               NpcDialog.show(NPC.LEINADUO,["我能够抵挡极电千鸟的威力！没关系！我们再来一次！记得用0xff0000极电千鸟0xffffff将我击败！"],["快点击雷纳多再来试试吧！"]);
            }
         }
      }
      
      public static function initTrain_3(param1:MovieClip) : void
      {
         var info:PetInfo = null;
         var mc:MovieClip = null;
         mc = param1;
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
               NpcDialog.show(NPC.AKXY,["雷伊！你还在等什么？还不快出来和我对战！只有懦弱的家伙才会选择逃避！记得受我十回合的攻击，在我0xff0000麻痹状态0xffffff下将我击败！"],["快点击阿克希亚出战吧！"]);
            }
            else if(!_isPlay)
            {
               mc.mouseEnabled = false;
               mc.mouseChildren = false;
               NpcDialog.show(NPC.AKXY,["我绝不容许你们伤害这里任何一只精灵！绝不！有什么就冲我来吧！#5"],["难道阿克希亚把我们当成海盗了？"],[function():void
               {
                  NpcDialog.show(NPC.LEIYI,["难道你真的不记得我了吗？我就是你当初救过的那个家伙……"],["什么！？雷伊！阿克希亚！他们之前发生过什么？"],[function():void
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("test3"),function():void
                     {
                        NpcDialog.show(NPC.AKXY,["想要成为真正的王者就不能有感情、不能手软！在战场上，我就是你的对手！"],["可是他把你当成救命恩人啊……"],[function():void
                        {
                           NpcDialog.show(NPC.AKXY,["如果你能够撑住我0xff000010回合0xffffff的攻击，并且在我0xff0000麻痹状态0xffffff下将我击败！那么，呵呵……上吧！"],["雷伊！你一定要过了自己那一关！快点击阿克希亚！"],[function():void
                           {
                              _isPlay = true;
                              mc.mouseEnabled = true;
                              mc.mouseChildren = true;
                           }]);
                        }]);
                     });
                  }]);
               }]);
            }
            else
            {
               startFight_3();
            }
         }
      }
      
      private static function startFight_3() : void
      {
         PetManager.addEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_3);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_3);
         if(MapManager.currentMap.id == 40)
         {
            FightInviteManager.fightWithBoss("阿克希亚",1);
         }
      }
      
      private static function onSkillHandler_3(param1:PetEvent) : void
      {
         _isShow = true;
         _info = param1.obj() as UpdateSkillInfo;
         PetManager.removeEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_3);
      }
      
      private static function onFightComplete_3(param1:PetFightEvent) : void
      {
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_3);
         if((e.dataObj as FightOverInfo).winnerID == MainManager.actorID)
         {
            if(_isShow)
            {
               _isPlay = false;
               _isShow = false;
               TasksManager.complete(122,2,function(param1:Boolean):void
               {
                  var b:Boolean = param1;
                  UpdateSkillManager.update(_info,function():void
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("test4"));
                  });
               });
            }
            else
            {
               NpcDialog.show(NPC.AKXY,["你还在手软吗？难道这个就是你所谓的精灵王者？再来！再来一次！！记得承受我10回合的攻击，并且在我0xff0000麻痹状态0xffffff下将我击倒！别再心软了！"],["快点击阿克希亚再来试试吧！"]);
            }
         }
      }
      
      public static function fightJiaLeiyi() : void
      {
         PetManager.addEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_4);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_4);
         if(MapManager.currentMap.id == 32)
         {
            FightInviteManager.fightWithBoss("雷伊",10006);
         }
      }
      
      private static function onSkillHandler_4(param1:PetEvent) : void
      {
         _isShow = true;
         _info = param1.obj() as UpdateSkillInfo;
         PetManager.removeEventListener(PetEvent.STUDY_SPECIAL_SKILL,onSkillHandler_4);
      }
      
      private static function onFightComplete_4(param1:PetFightEvent) : void
      {
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightComplete_4);
         if((e.dataObj as FightOverInfo).winnerID == MainManager.actorID)
         {
            if(_isShow)
            {
               _isShow = false;
               TasksManager.complete(122,3,function(param1:Boolean):void
               {
                  var b:Boolean = param1;
                  UpdateSkillManager.update(_info,function():void
                  {
                     AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("task_122_2"));
                  });
                  TasksManager.setTaskStatus(122,3);
                  delIcon();
               });
            }
            else
            {
               NpcDialog.show(NPC.LEIYI_IMAGE,["怎么？连你自己这关都过不了吗？那你还当什么雷神？继续！"],["快点击水银湖倒影中的雷伊！"]);
            }
         }
         else
         {
            NpcDialog.show(NPC.LEIYI_IMAGE,["怎么？连你自己这关都过不了吗？那你还当什么雷神？继续！"],["快点击水银湖倒影中的雷伊！"]);
         }
      }
   }
}

