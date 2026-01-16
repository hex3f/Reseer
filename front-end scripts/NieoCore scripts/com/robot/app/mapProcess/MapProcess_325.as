package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.EnergyController;
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.control.TaskController_133;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   
   public class MapProcess_325 extends BaseMapProcess
   {
      
      public static var oneString:String = "unclick";
      
      public static var twoString:String = "unclick";
      
      public static var threeString:String = "unclick";
      
      public static var visiteMaomao:String = "unVisit";
      
      public static var vistiteEva:String = "unVisit";
      
      private var npcPet:MovieClip;
      
      private var waterBig:MovieClip;
      
      private var waterLittle:MovieClip;
      
      private var showWord:MovieClip;
      
      private var taskOver:MovieClip;
      
      private var showMusic:MovieClip;
      
      private var oneSound:Sound;
      
      private var musicCenter:MovieClip;
      
      private var chanel:SoundChannel;
      
      private var channel2:SoundChannel;
      
      private var twoSound:Sound;
      
      private var index:Number = 0;
      
      private var musicShort:MovieClip;
      
      private var padThink:MovieClip;
      
      private var screenTu:MovieClip;
      
      private var godSound:Sound;
      
      private var godChannel:SoundChannel;
      
      private var musicIdArr:Array = [3,2,6,7,5,4,1];
      
      private var musicIDArr:Array = [5,6,7];
      
      private var tempMusicId:Array = [];
      
      private var boss_mc:MovieClip;
      
      private var boss_btn:SimpleButton;
      
      private var _markMc:MovieClip;
      
      private var musicNum:uint = 0;
      
      private var isBoss:Boolean;
      
      private var musicId:uint = 0;
      
      private var isInTask:Boolean;
      
      public function MapProcess_325()
      {
         super();
      }
      
      override protected function init() : void
      {
         var i:uint = 0;
         var m:BaseMapProcess = null;
         this.musicNum = 0;
         this.isBoss = false;
         this.isInTask = false;
         this.boss_mc = conLevel["boss_mc"];
         this.boss_btn = conLevel["boss_btn"];
         this.boss_btn.visible = false;
         this.boss_btn.addEventListener(MouseEvent.CLICK,this.clickBossHandler);
         this.boss_mc.gotoAndStop(1);
         this.padThink = conLevel["thinkPad"];
         this.padThink.buttonMode = true;
         this.padThink.addEventListener(MouseEvent.CLICK,this.thinksFun);
         this.npcPet = conLevel["petNpc"];
         this.npcPet.buttonMode = true;
         this.waterBig = conLevel["bigWater"];
         this.waterLittle = conLevel["littleWater"];
         this.taskOver = conLevel["overTaskShow"];
         this.musicShort = btnLevel["shortMusic"];
         this.musicShort.buttonMode = true;
         conLevel["shortTree"].gotoAndStop(1);
         this.musicShort.addEventListener(MouseEvent.MOUSE_OVER,this.screenPlay);
         this.musicShort.addEventListener(MouseEvent.MOUSE_OUT,this.screenOver);
         this.musicShort.addEventListener(MouseEvent.CLICK,this.shortPlay);
         this.screenTu = topLevel["tuya"];
         this.screenTu.buttonMode = true;
         this.screenTu.visible = false;
         i = 1;
         while(i < 8)
         {
            conLevel["music" + i].buttonMode = true;
            conLevel["music" + i].gotoAndStop(1);
            conLevel["music" + i].addEventListener(MouseEvent.CLICK,this.musicPlay);
            i++;
         }
         if(TasksManager.getTaskStatus(97) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(97,function(param1:Array):void
            {
               var url:String = null;
               var arr:Array = param1;
               if(Boolean(arr[3]) && !arr[4])
               {
                  npcPet.gotoAndStop(353);
                  if(Boolean(npcPet["mc2"]))
                  {
                     npcPet["mc2"].gotoAndStop(1);
                  }
               }
               if(Boolean(arr[4]) && !arr[5])
               {
                  url = ClientConfig.getFullMovie("musicStart");
                  AnimateManager.playFullScreenAnimate(url,function():void
                  {
                     NpcDialog.show(NPC.PENNYHIGH,["帕尼！喜！#6……*（&乐！月……*（……（#入"],["它这说的是什么啊？"],[function():void
                     {
                        AnimateManager.playMcAnimate(npcPet,458,"mc3",function():void
                        {
                           screenTu.visible = true;
                           npcPet.mouseChildren = false;
                           npcPet.mouseEnabled = false;
                           screenTu["screen"].addEventListener(MouseEvent.CLICK,meansShow);
                        });
                     }]);
                  });
               }
            });
         }
         if(TasksManager.getTaskStatus(97) == TasksManager.COMPLETE)
         {
            this.npcPet.gotoAndStop(1);
         }
         this.musicCenter = conLevel["centerMusic"];
         this.musicCenter.buttonMode = true;
         this.musicCenter.addEventListener(MouseEvent.CLICK,this.musicShow);
         this.waterBig.gotoAndStop(1);
         this.taskOver.gotoAndStop(1);
         this.npcPet.addEventListener(MouseEvent.CLICK,this.speak);
         this.initTask133();
         m = this;
      }
      
      private function screenPlay(param1:MouseEvent) : void
      {
         conLevel["shortTree"].gotoAndStop(2);
      }
      
      private function screenOver(param1:MouseEvent) : void
      {
         conLevel["shortTree"].gotoAndStop(1);
      }
      
      private function meansShow(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.screenTu.visible = false;
         topLevel.mouseChildren = false;
         topLevel.mouseEnabled = false;
         this.npcPet.mouseChildren = true;
         this.npcPet.mouseEnabled = true;
         NpcDialog.show(NPC.SEER,["月亮出现？弹奏音乐？入口打开？帕尼是想告诉我只有当月亮出现，我们弹奏音乐，才可以进入下一个入口吗？#8"],["晕！帕尼竟然又睡着了！"],[function():void
         {
            TasksManager.complete(97,5,null,true);
            npcPet.gotoAndStop(1);
         }]);
      }
      
      private function thinksFun(param1:MouseEvent) : void
      {
         conLevel["overTaskShow"].gotoAndPlay(1);
         this.godSound = MapLibManager.getSound("godSound");
         this.padThink.mouseChildren = false;
         this.padThink.mouseEnabled = false;
         this.godChannel = this.godSound.play();
         this.godChannel.addEventListener(Event.SOUND_COMPLETE,this.godOver);
      }
      
      private function godOver(param1:Event) : void
      {
         this.godSound = null;
         this.padThink.mouseChildren = true;
         this.padThink.mouseEnabled = true;
      }
      
      private function shortPlay(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.twoSound = MapLibManager.getSound("musicdizi");
         this.musicShort.mouseEnabled = false;
         this.musicShort.mouseChildren = false;
         this.channel2 = this.twoSound.play();
         this.channel2.addEventListener(Event.SOUND_COMPLETE,this.completeTwo);
         TasksManager.getProStatusList(97,function(param1:Array):void
         {
            var arr:Array = param1;
            if(Boolean(arr[1]) && !arr[2])
            {
               if(threeString != "click")
               {
                  musicShort.removeEventListener(MouseEvent.MOUSE_OVER,screenPlay);
                  musicShort.removeEventListener(MouseEvent.MOUSE_OUT,screenOver);
                  conLevel["shortTree"].gotoAndStop(3);
                  AnimateManager.playMcAnimate(conLevel["shortTree"],3,"mc2",function():void
                  {
                     var _loc1_:AppModel = null;
                     var _loc2_:String = null;
                     musicShort.addEventListener(MouseEvent.MOUSE_OVER,screenPlay);
                     musicShort.addEventListener(MouseEvent.MOUSE_OUT,screenOver);
                     threeString = "click";
                     conLevel["shortTree"].gotoAndStop(1);
                     if(oneString == "click" && twoString == "click")
                     {
                        TasksManager.complete(97,2,null,true);
                     }
                     else
                     {
                        _loc1_ = null;
                        _loc2_ = "TaskPanel_97";
                        if(Boolean(_loc1_))
                        {
                           _loc1_.destroy();
                           _loc1_ = null;
                        }
                        _loc1_ = new AppModel(ClientConfig.getTaskModule(_loc2_),"正在打开任务信息");
                        _loc1_.setup();
                        _loc1_.show();
                     }
                  });
               }
            }
         });
      }
      
      private function completeTwo(param1:Event) : void
      {
         this.twoSound = null;
         this.musicShort.mouseChildren = true;
         this.musicShort.mouseEnabled = true;
      }
      
      private function musicShow(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.waterLittle.gotoAndStop(1);
         this.waterLittle.visible = false;
         this.waterBig.gotoAndPlay(1);
         TasksManager.getProStatusList(97,function(param1:Array):void
         {
            var arr:Array = param1;
            if(Boolean(arr[1]) && !arr[2])
            {
               if(twoString != "click")
               {
                  AnimateManager.playMcAnimate(musicCenter,2,"mc",function():void
                  {
                     var _loc1_:AppModel = null;
                     var _loc2_:String = null;
                     twoString = "click";
                     musicCenter.gotoAndStop(1);
                     if(oneString == "click" && threeString == "click")
                     {
                        TasksManager.complete(97,2,null,true);
                     }
                     else
                     {
                        _loc1_ = null;
                        _loc2_ = "TaskPanel_97";
                        if(Boolean(_loc1_))
                        {
                           _loc1_.destroy();
                           _loc1_ = null;
                        }
                        _loc1_ = new AppModel(ClientConfig.getTaskModule(_loc2_),"正在打开任务信息");
                        _loc1_.setup();
                        _loc1_.show();
                     }
                  });
               }
            }
         });
         this.oneSound = MapLibManager.getSound("centerMusic");
         this.chanel = this.oneSound.play();
         this.musicCenter.mouseChildren = false;
         this.musicCenter.mouseEnabled = false;
         this.chanel.addEventListener(Event.SOUND_COMPLETE,this.musicComplete);
      }
      
      private function musicComplete(param1:Event) : void
      {
         this.waterLittle.visible = true;
         this.chanel.removeEventListener(Event.SOUND_COMPLETE,this.musicComplete);
         this.musicCenter.mouseChildren = true;
         this.musicCenter.mouseEnabled = true;
         this.waterBig.gotoAndStop(1);
         this.waterLittle.gotoAndPlay(1);
         this.oneSound = null;
      }
      
      private function isPlayMusic(param1:uint) : void
      {
         var n:uint = param1;
         if(this.musicIDArr[this.musicNum] == n)
         {
            ++this.musicNum;
            if(this.musicNum == 3)
            {
               if(this.isInTask)
               {
                  this.musicNum = 0;
                  AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],2,"mc2",function():void
                  {
                     NpcDialog.show(NPC.SEER,["什么！！什么！！赛尔飞起来了？我真的眼花了吗？#7"],["我刚刚明明有看到史空飞起来啊……"],[function():void
                     {
                        NpcDialog.show(NPC.JELLYSEER,["带我去月影花园看看吧……那里也跟这里一样奇妙吗？也有音乐吗？"],["哎呀！哎呀！你别着急啊……"],[function():void
                        {
                           TasksManager.complete(TaskController_133.TASK_ID,1,function(param1:Boolean):void
                           {
                              MapManager.changeMap(63);
                           });
                        }]);
                     }]);
                  });
               }
            }
         }
         else
         {
            ++this.musicNum;
            if(this.musicNum >= 3)
            {
               if(this.isInTask)
               {
                  NpcDialog.show(NPC.JELLYSEER,["我想你弹奏错了……再认真看下琴谱吧！#1（★★△△**△）"],["我再去试试看！"],[function():void
                  {
                     musicNum = 0;
                  }]);
               }
            }
         }
      }
      
      private function isShowBoss(param1:uint) : void
      {
         if(this.isBoss)
         {
            return;
         }
         if(this.musicIdArr[this.musicId] == param1)
         {
            ++this.musicId;
            if(this.musicId == 7)
            {
               this.isBoss = true;
               this.boss_mc.gotoAndPlay(2);
               this.boss_mc.addFrameScript(this.boss_mc.totalFrames - 1,this.endBoss);
            }
            return;
         }
         if(this.musicIdArr[0] == param1)
         {
            this.musicId = 1;
         }
      }
      
      private function endBoss() : void
      {
         this.boss_btn.visible = true;
         this.boss_mc.gotoAndStop(this.boss_mc.totalFrames - 1);
         this.boss_mc.addFrameScript(this.boss_mc.totalFrames - 1,null);
      }
      
      private function clickBossHandler(param1:MouseEvent) : void
      {
         if(MapManager.currentMap.id == 325)
         {
            FightInviteManager.fightWithBoss("奈尼芬多");
         }
      }
      
      private function musicPlay(param1:MouseEvent) : void
      {
         var soud:Sound = null;
         var k:uint = 0;
         k = 0;
         var e:MouseEvent = param1;
         var name:String = e.currentTarget.name;
         name = name.substr(5,name.length);
         k = uint(name);
         this.isShowBoss(k);
         this.isPlayMusic(k);
         TasksManager.getProStatusList(97,function(param1:Array):void
         {
            var arr:Array = param1;
            if(Boolean(arr[1]) && !arr[2])
            {
               if(oneString != "click" && k == 4)
               {
                  conLevel["music4"].gotoAndStop(51);
                  AnimateManager.playMcAnimate(conLevel["music4"],51,"mc",function():void
                  {
                     var _loc1_:AppModel = null;
                     var _loc2_:String = null;
                     conLevel["music" + k].gotoAndStop(1);
                     oneString = "click";
                     if(threeString == "click" && twoString == "click")
                     {
                        TasksManager.complete(97,2,null,true);
                     }
                     else
                     {
                        _loc1_ = null;
                        _loc2_ = "TaskPanel_97";
                        if(Boolean(_loc1_))
                        {
                           _loc1_.destroy();
                           _loc1_ = null;
                        }
                        _loc1_ = new AppModel(ClientConfig.getTaskModule(_loc2_),"正在打开任务信息");
                        _loc1_.setup();
                        _loc1_.show();
                     }
                  });
               }
            }
         });
         soud = MapLibManager.getSound("Sound" + k);
         soud.play();
         conLevel["music" + k].gotoAndPlay(1);
      }
      
      private function speak(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(TasksManager.getTaskStatus(97) == TasksManager.UN_ACCEPT)
         {
            this.npcPet.gotoAndPlay(71);
            LevelManager.closeMouseEvent();
            this.npcPet.addEventListener(Event.ENTER_FRAME,this.overSleep);
         }
         else if(TasksManager.getTaskStatus(97) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(97,function(param1:Array):void
            {
               var arr:Array = param1;
               if(Boolean(arr[2]) && !arr[3])
               {
                  NpcDialog.show(NPC.PENNY,["#2呼……"],["哈哈哈！！果然醒了！但是它为什么这么沮丧呢？"],[function():void
                  {
                     npcPet.gotoAndStop(352);
                     AnimateManager.playMcAnimate(npcPet,352,"mc2",function():void
                     {
                        npcPet["mc2"].gotoAndStop(1);
                        NpcDialog.show(NPC.SEER,["这个不是云霄星上的0xff0000毛毛0xffffff和塔克星上的0xff0000伊娃0xffffff？哎呀！我怎么就没想到呢！它们两个也是音乐小天才啊！我想帕尼一个人表演肯定很孤单！如果能来一个精灵大合唱呢？哈哈哈！#1"],["我这就去找它们帮忙咯！"],[function():void
                        {
                           TasksManager.complete(97,3,null,true);
                        }]);
                     });
                  }]);
               }
               else if(Boolean(arr[3]) && !arr[4])
               {
                  NpcDialog.show(NPC.SEER,["我所期待的两位天才来了吗？"],["哦，差点忘记了，我这就去！"],[function():void
                  {
                     TasksManager.complete(97,3,null,true);
                  }]);
               }
               else
               {
                  NpcDialog.show(NPC.SEER,["不叫醒这个家伙！我可就没有办法去其它地方探险咯！不行！我一定要想到办法！"],["我一定能够想到办法的！"]);
               }
            });
         }
         else
         {
            NpcDialog.show(NPC.PENNYHIGH,["Zzzzzzz……"],["嘘！我们就别吵小家伙睡觉了！"]);
         }
      }
      
      private function overSleep(param1:Event) : void
      {
         var e:Event = param1;
         if(Boolean(this.npcPet["mc"]))
         {
            if(this.npcPet["mc"].currentFrame == this.npcPet["mc"].totalFrames)
            {
               this.npcPet.removeEventListener(Event.ENTER_FRAME,this.overSleep);
               this.npcPet.gotoAndPlay(1);
               NpcDialog.show(NPC.SEER,["气死我了！那家伙竟然在这里睡觉！#5气死我了！气死我了！我都不能到下一个地方去探险了！！！"],["要不我们去问问博士？","不理就不理！我一会再来！"],[function():void
               {
                  TasksManager.accept(97,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        TasksManager.complete(97,0,null,true);
                        LevelManager.openMouseEvent();
                     }
                  });
               }]);
            }
         }
      }
      
      public function exploitOre() : void
      {
         EnergyController.exploit(29);
      }
      
      override public function destroy() : void
      {
         this.boss_btn.removeEventListener(MouseEvent.CLICK,this.clickBossHandler);
         this.boss_btn = null;
         if(Boolean(this.chanel))
         {
            this.chanel.stop();
            this.chanel.removeEventListener(Event.SOUND_COMPLETE,this.musicComplete);
            this.chanel = null;
         }
         if(Boolean(this.channel2))
         {
            this.channel2.stop();
            this.channel2.removeEventListener(Event.SOUND_COMPLETE,this.completeTwo);
            this.channel2 = null;
         }
         if(Boolean(this.godChannel))
         {
            this.godChannel.stop();
            this.godChannel.removeEventListener(Event.SOUND_COMPLETE,this.godOver);
         }
         this.npcPet.removeEventListener(Event.ENTER_FRAME,this.overSleep);
      }
      
      private function initTask133() : void
      {
         if(TasksManager.getTaskStatus(TaskController_133.TASK_ID) == TasksManager.UN_ACCEPT)
         {
            depthLevel["jellyseer_mc"].visible = false;
         }
         else if(TasksManager.getTaskStatus(TaskController_133.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_133.TASK_ID,function(param1:Array):void
            {
               var arr:Array = param1;
               if(!arr[0])
               {
                  NpcDialog.show(NPC.JELLYSEER,["这是什么声音？为什么这么清脆悦耳……啦啦啦！哆唻咪……咪#1"],["咦？难道是我眼花了？这个赛尔身边怎么荧光闪闪！"],[function():void
                  {
                     AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],1,"mc1",function():void
                     {
                        NpcDialog.show(NPC.JELLYSEER,["你能用0xff0000铃铛草0xffffff为我弹奏一曲吗？#6我很想听听它的声音……你照着这个弹一定会很好听哦！#99#98#97"],["总感觉这个赛尔有点奇怪！我多想了吧……"],[function():void
                        {
                           TasksManager.complete(TaskController_133.TASK_ID,0,function(param1:Boolean):void
                           {
                              isInTask = param1;
                           });
                        }]);
                     });
                  }]);
               }
               if(Boolean(arr[0]) && !arr[1])
               {
                  isInTask = true;
                  AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],1,"mc1",null);
               }
               if(Boolean(arr[1]) && !arr[2])
               {
                  depthLevel["jellyseer_mc"].visible = false;
               }
            });
         }
         else
         {
            depthLevel["jellyseer_mc"].visible = false;
         }
      }
   }
}

