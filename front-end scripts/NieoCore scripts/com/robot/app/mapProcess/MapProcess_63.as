package com.robot.app.mapProcess
{
   import com.robot.app.task.control.TaskController_133;
   import com.robot.app.task.control.TaskController_91;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_63 extends BaseMapProcess
   {
      
      private var _loader:MCLoader;
      
      private var gelinMC:MovieClip;
      
      private var buluMC:MovieClip;
      
      private var gbMovie:MovieClip;
      
      private var bridgeMC:MovieClip;
      
      private var stoneMC:MovieClip;
      
      private var jingyuanMC:MovieClip;
      
      private var headID:uint = 0;
      
      private var _mc:MovieClip;
      
      public function MapProcess_63()
      {
         super();
      }
      
      override protected function init() : void
      {
         depthLevel["jellyseer_mc"].visible = false;
         this._mc = this.conLevel["aimatMc"];
         this.conLevel["aimatHitMc"].alpha = 0;
         this.conLevel["aimatHitMc"].mouseEnabled = false;
         this.conLevel["aimatHitMc"].mouseChildren = false;
         this.conLevel["blueMc"].visible = false;
         this.initTask_91();
         this.initTask133();
         this.initSwirlMC();
      }
      
      private function initSwirlMC() : void
      {
         conLevel["swirlMC"].stop();
         conLevel["swirlMC"].visible = false;
      }
      
      private function completeTask133() : void
      {
         NpcDialog.show(NPC.SHIKONG,["我是超能系精灵史空，我常年居住在遗忘领域，没有欢笑！没有悲伤！又或者我已经忘记我是精灵了……"],["天啊！它原来是精灵！！！"],[function():void
         {
            NpcDialog.show(NPC.SHIKONG,["音乐的愉悦、故事的伤感！我想我已经找到了自己失去的“心”！可是……我不想回到那个冷冰冰的遗忘领域……"],["如果你不嫌弃！我带着你吧！我会照顾好你的！"],[function():void
            {
               NpcDialog.show(NPC.SHIKONG,["音乐的愉悦、故事的伤感！我想我已经找到了自己失去的“心”！你愿意带我找寻更多的情感吗#2"],["如果你不嫌弃！我带着你吧！我会照顾好你的！"],[function():void
               {
                  AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],2,"mc2",function():void
                  {
                     NpcDialog.show(NPC.SHIKONG,[MainManager.actorInfo.nick + "，为了报答你，我现在就用我的超能力让你看看布鲁和格林吧！注意看咯！"],["真的吗？！真的吗？！"],[function():void
                     {
                        AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("b&gbye"),function():void
                        {
                           depthLevel["jellyseer_mc"].visible = false;
                           NpcDialog.show(NPC.SEER,["我好想他们……不过能看到他们这么快乐！我也就放心了！"],["史空我会好好待你的……"],[function():void
                           {
                              TasksManager.complete(TaskController_133.TASK_ID,3);
                           }]);
                        });
                     }]);
                  });
               }]);
            }]);
         }]);
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
               if(Boolean(arr[1]) && !arr[2])
               {
                  depthLevel["jellyseer_mc"].visible = true;
                  NpcDialog.show(NPC.JELLYSEER,["你为什么会带我来这里？就因为风景美丽吗？这里似乎没什么特别的吧……"],["但是这里曾经发生的故事很特别！"],[function():void
                  {
                     NpcDialog.show(NPC.SEER,["很久以前有两个小精灵，格林和布鲁，他们一直寻寻觅觅的找着对方，想要寻找儿时的记忆，他们……"],["为什么我仿佛看到了以前的画面……"],[function():void
                     {
                        AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("b&gmiss"),function():void
                        {
                           NpcDialog.show(NPC.JELLYSEER,["精灵也可以有情感、精灵也可以有自己喜欢的乐趣……这才是精灵吗？为什么我感觉我有些悲伤！我有情感了？"],["不对！这个赛尔一定有古怪！！"],[function():void
                           {
                              NpcDialog.show(NPC.SEER,["你到底是谁？你想要干嘛？？快说！！！！"],["什么！精灵！？！"],[function():void
                              {
                                 AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],1,"mc1",function():void
                                 {
                                    TasksManager.complete(TaskController_133.TASK_ID,2,function(param1:Boolean):void
                                    {
                                       completeTask133();
                                    });
                                 });
                              }]);
                           }]);
                        });
                     }]);
                  }]);
               }
               else if(Boolean(arr[2]) && !arr[3])
               {
                  depthLevel["jellyseer_mc"].visible = true;
                  completeTask133();
                  AnimateManager.playMcAnimate(depthLevel["jellyseer_mc"],1,"mc1",function():void
                  {
                  });
               }
               else
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
      
      private function initTask_91() : void
      {
         this.gelinMC = conLevel["gelinMC"];
         this.gelinMC.buttonMode = true;
         this.gelinMC.addEventListener(MouseEvent.CLICK,this.onClickGelin);
         this.buluMC = conLevel["buluMC"];
         this.gelinMC.buttonMode = true;
         this.buluMC.addEventListener(MouseEvent.CLICK,this.onClickBulu);
         this.gbMovie = animatorLevel["gbMovie"];
         this.gbMovie.gotoAndStop(1);
         this.bridgeMC = animatorLevel["bridgeMC"];
         this.bridgeMC.gotoAndStop(1);
         this.stoneMC = animatorLevel["stoneMC"];
         this.stoneMC.visible = false;
         this.stoneMC.gotoAndStop(1);
         this.jingyuanMC = conLevel["jingyuanMC"];
         if(TasksManager.getTaskStatus(91) == TasksManager.COMPLETE)
         {
            DisplayUtil.removeForParent(this.gbMovie);
            this.stoneMC.visible = true;
            this.gelinMC.buttonMode = false;
            this.gelinMC.removeEventListener(MouseEvent.CLICK,this.onClickGelin);
            this.gelinMC.buttonMode = false;
            this.buluMC.removeEventListener(MouseEvent.CLICK,this.onClickBulu);
            return;
         }
         if(TasksManager.getTaskStatus(91) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(91,function(param1:Array):void
            {
               if(!param1[0])
               {
                  buluMC.buttonMode = false;
                  buluMC.removeEventListener(MouseEvent.CLICK,onClickBulu);
                  AimatController.addEventListener(AimatEvent.PLAY_END,shotBulu);
               }
               if(Boolean(param1[0]) && !param1[1])
               {
                  gbMovie.gotoAndStop(2);
                  buluMC.buttonMode = true;
                  buluMC.addEventListener(MouseEvent.CLICK,onHelpBulu);
               }
               if(Boolean(param1[1]) && !param1[2])
               {
                  gbMovie.gotoAndStop(4);
                  buluMC.buttonMode = true;
                  buluMC.addEventListener(MouseEvent.CLICK,onRemoveBulu);
               }
               if(Boolean(param1[2]) && !param1[3])
               {
                  DisplayUtil.removeForParent(gbMovie);
                  stoneMC.visible = true;
                  stoneMC.gotoAndStop(3);
                  jingyuanMC.buttonMode = true;
                  jingyuanMC.addEventListener(MouseEvent.CLICK,getJingyuan);
               }
            });
         }
      }
      
      private function onClickBulu(param1:MouseEvent) : void
      {
         if(TasksManager.getTaskStatus(91) == TasksManager.UN_ACCEPT)
         {
            NpcDialog.show(NPC.BULU,["..................."],["布鲁到底怎么了？先去问问格林吧！"]);
         }
      }
      
      private function onClickGelin(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         if(TasksManager.getTaskStatus(91) == TasksManager.ALR_ACCEPT)
         {
            NpcDialog.show(NPC.GELIN,["拜托你！拜托你！救救我的好朋友吧！#4"],["布鲁一定会没事！"]);
         }
         else
         {
            NpcDialog.show(NPC.GELIN,["#4呜呜……怎么办？怎么办？布鲁好像因为长期在沙漠中缺水而昏倒了！怎么办？你能救救布鲁吗？拜托你！"],["快快！我想到办法了！","你先别急！让我想想办法……"],[function():void
            {
               NpcDialog.show(NPC.SEER,["缺水……缺水……你说我用0xff0000高压水枪0xffffff灌输一点水给布鲁，它会不会好一点呢？#7"],["不管这么多了！先试试吧！"],[function():void
               {
                  TasksManager.accept(91,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        TaskController_91.showPanel();
                     }
                  });
                  buluMC.buttonMode = false;
                  buluMC.removeEventListener(MouseEvent.CLICK,onClickBulu);
                  AimatController.addEventListener(AimatEvent.PLAY_END,shotBulu);
               }]);
            }]);
         }
      }
      
      private function shotBulu(param1:AimatEvent) : void
      {
         var id:uint = 0;
         var evt:AimatEvent = param1;
         if(evt.info.userID != MainManager.actorID)
         {
            return;
         }
         for each(id in MainManager.actorInfo.clothIDs)
         {
            if(ItemXMLInfo.getType(id) == "head")
            {
               this.headID = id;
            }
         }
         if(this.headID == 100052)
         {
            if(this.buluMC.hitTestPoint(evt.info.endPos.x,evt.info.endPos.y))
            {
               AimatController.removeEventListener(AimatEvent.PLAY_END,this.shotBulu);
               this.gbMovie.gotoAndStop(2);
               NpcDialog.show(NPC.SEER,["哈哈！#1布鲁似乎有点起色了！我这就带着我的0xff0000水系精灵0xffffff，用它的技能帮助布鲁恢复！！！"],["我这就把水系精灵带在身边！"],[function():void
               {
                  TasksManager.complete(91,0,null,true);
                  buluMC.buttonMode = true;
                  buluMC.addEventListener(MouseEvent.CLICK,onHelpBulu);
               }]);
            }
         }
         else
         {
            NpcDialog.show(NPC.SEER,["咦？#7怎么没有用？哎呀！我装备的不是0xff0000高压水枪0xffffff！（高压水枪可以在机械室领取到哦）"],["快去机械室领取"]);
         }
      }
      
      private function onHelpBulu(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         var petIsWrong:Function = function():void
         {
            NpcDialog.show(NPC.GELIN,["喂！你没有把0xff0000水系精灵0xffffff带在身边啦！快点救救布鲁吧……"],["这回一定把水系精灵带在身边！"]);
         };
         var hasPet:Function = function():void
         {
            buluMC.buttonMode = false;
            buluMC.removeEventListener(MouseEvent.CLICK,onHelpBulu);
            AnimateManager.playMcAnimate(gbMovie,3,"mc3",function():void
            {
               NpcDialog.show(NPC.GELIN,["好呀！！！好呀！！！布鲁似乎有点起色了！布鲁有救咯！布鲁有救咯！#8"],["我会再加把劲的!"],[function():void
               {
                  NpcDialog.show(NPC.SEER,["哇！#8布鲁看起来有点气色咯!不对！现在还不是高兴时候呐!我这就继续对着布鲁灌输水！布鲁你也要加油啊!"],["加油加油!我们一起加油！！"],[function():void
                  {
                     AnimateManager.playMcAnimate(gbMovie,4,"mc4",function():void
                     {
                        NpcDialog.show(NPC.SEER,["不要……不要再喷水了！你都已经没力气了！#2相信我，我一定会想到其他办法的！你先好好休息下吧！"],["我一定能够想到其他办法的！"],[function():void
                        {
                           NpcDialog.show(NPC.SEER,["缺水……水……对啦！布鲁不是生活在水里嘛！如果把它放入水里这是不是会好的快些？"],["不管怎么样，我都要试试！"],[function():void
                           {
                              TasksManager.complete(91,1,null,true);
                              buluMC.buttonMode = true;
                              buluMC.addEventListener(MouseEvent.CLICK,onRemoveBulu);
                           }]);
                        }]);
                     });
                  }]);
               }]);
            });
         };
         if(Boolean(MainManager.actorModel.pet))
         {
            if(PetXMLInfo.getTypeCN(MainManager.actorModel.pet.info.petID) == "水")
            {
               hasPet();
            }
            else
            {
               petIsWrong();
            }
         }
         else
         {
            hasPet();
         }
      }
      
      private function onRemoveBulu(param1:MouseEvent) : void
      {
         var nick:String = null;
         var url:String = null;
         nick = null;
         url = null;
         var evt:MouseEvent = param1;
         this.gelinMC.buttonMode = false;
         this.gelinMC.removeEventListener(MouseEvent.CLICK,this.onClickGelin);
         this.buluMC.buttonMode = false;
         this.buluMC.removeEventListener(MouseEvent.CLICK,this.onRemoveBulu);
         MainManager.actorModel.visible = false;
         nick = MainManager.actorInfo.nick;
         url = ClientConfig.getFullMovie("buandgelin");
         AnimateManager.playMcAnimate(this.gbMovie,5,"mc5",function():void
         {
            MainManager.actorModel.visible = true;
            NpcDialog.show(NPC.GELIN,["你在搞什么啊！#5我的好朋友布鲁呢？它去哪里了？它到底怎么了！你干嘛把它放入水里？它现在去哪里了？？？？你还我布鲁！"],["我只是想要救它！没想到……"],[function():void
            {
               NpcDialog.show(NPC.SEER,["都怪我自作聪明……布鲁……布鲁……对不起……#4"],["都是我太自作聪明了！都是我！"],[function():void
               {
                  AnimateManager.playFullScreenAnimate(url,function():void
                  {
                     gbMovie.gotoAndStop(6);
                     NpcDialog.show(NPC.SEER,["哈哈哈！哈哈！#8布鲁复活咯！布鲁复活咯！太棒了！"],["布鲁复活咯！！！"],[function():void
                     {
                        NpcDialog.show(NPC.BULUGELIN,["嘻嘻……" + nick + "，谢谢你！#6要不是你，我们两个也没机会再次重逢了！其实我们当初是为了比赛谁能先找到最美丽的月影湖而分散的，没想到竟然都找到了这里！O(∩_∩)O"],["看到你们在一起我就很开心了！"],[function():void
                        {
                           NpcDialog.show(NPC.SEER,["哈哈……没事！没事！看到布鲁没事，看到你们能够重逢！我已经很开心啦！#8嘿嘿……"],["看到它们重逢的画面我真激动！"],[function():void
                           {
                              NpcDialog.show(NPC.BULUGELIN,[nick + "，我们要走咯！我们两个约定好一起去更多美丽的地方旅行咯！这次我们不会分开了！你可要珍惜你身边的好朋友哦！不能也因为一点小事就分开啦！我们该走了，有机会的话再见吧……"],["我一定会珍惜我身边的朋友！"],[function():void
                              {
                                 DisplayUtil.removeForParent(gbMovie);
                                 AnimateManager.playMcAnimate(bridgeMC,2,"mc2",function():void
                                 {
                                    bridgeMC.gotoAndStop(1);
                                    stoneMC.visible = true;
                                    AnimateManager.playMcAnimate(stoneMC,2,"mc2",function():void
                                    {
                                       TasksManager.complete(91,2,null,true);
                                       stoneMC.gotoAndStop(3);
                                       jingyuanMC.buttonMode = true;
                                       jingyuanMC.addEventListener(MouseEvent.CLICK,getJingyuan);
                                    });
                                 });
                              }]);
                           }]);
                        }]);
                     }]);
                  });
               }]);
            }]);
         });
      }
      
      private function getJingyuan(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         this.jingyuanMC.buttonMode = false;
         this.jingyuanMC.removeEventListener(MouseEvent.CLICK,this.getJingyuan);
         NpcDialog.show(NPC.SEER,["咦？？这个是什么？真的有东西在动啊！！！#7"],["不怕！不怕！我再认真看看！"],[function():void
         {
            NpcDialog.show(NPC.SEER,["啊!这形状，这样子……似乎是……精元？精灵的精元？哈哈哈！真的是精灵的精元哦！我这就把你带回基地，让NoNo来孵化你！小东西，你长什么样子呢？"],["小东西，我真想看看孵化后的你……"],[function():void
            {
               TasksManager.complete(91,3);
               stoneMC.gotoAndStop(1);
            }]);
         }]);
      }
      
      override public function destroy() : void
      {
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.shotBulu);
         DisplayUtil.removeForParent(conLevel["swirlMC"]);
         if(Boolean(this._loader))
         {
            this._loader.clear();
            this._loader = null;
         }
      }
   }
}

