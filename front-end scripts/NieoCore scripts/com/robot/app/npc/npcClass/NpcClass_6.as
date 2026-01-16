package com.robot.app.npc.npcClass
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.mapProcess.MapProcess_107;
   import com.robot.app.task.control.TaskController_96;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.mode.BossModel;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.npc.NpcInfo;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class NpcClass_6 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      private var _questionPanel:AppModel;
      
      private var _bossMC:BossModel;
      
      public function NpcClass_6(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onClick);
         this._curNpcModel.addEventListener(NpcEvent.TASK_WITHOUT_DES,this.onTaskWithoutDes);
      }
      
      private function onClick(param1:NpcEvent) : void
      {
         var e:NpcEvent = param1;
         this._curNpcModel.refreshTask();
         if(e.taskID == 96)
         {
            if(TasksManager.getTaskStatus(96) == TasksManager.ALR_ACCEPT)
            {
               if(!MainManager.actorInfo.hasNono)
               {
                  TasksManager.getProStatusList(96,function(param1:Array):void
                  {
                     if(Boolean(param1[0]) && !param1[1])
                     {
                        NpcDialog.show(NPC.SHAWN,[" 你的NoNo正在等你带它回家呢，快去吧，别让它等急咯！"],["恩，我这就去！"],null);
                     }
                  });
               }
               else
               {
                  this.checkNono();
                  if(!MainManager.actorModel.nono)
                  {
                     TasksManager.getProStatusList(96,function(param1:Array):void
                     {
                        var arr:Array = param1;
                        if(Boolean(arr[1]) && !arr[2])
                        {
                           NpcDialog.show(NPC.SHAWN,[" 你的NoNo暂时留在基地中了，稍后回基地去开启它，你就能了解到它的一些功能了。"],["怎样才能启用这些功能呢？"],[function():void
                           {
                              NpcDialog.show(NPC.SHAWN,[" NoNo虽然拥有很多特别的功能，但这些能力需要加载芯片才能实现。比如，只有加载了跟随模式芯片，才能让你的NoNo陪你走天下。"],["跟随模式芯片？"],[function():void
                              {
                                 NpcDialog.show(NPC.SHAWN,[" #8这是我送给你的礼物，回基地为你的NoNo加载上，我想你就能恍然大悟了。"],["（会是什么礼物呢？真期待啊！）"],[function():void
                                 {
                                    SocketConnection.addCmdListener(CommandID.NONO_GET_CHIP,onGetChip);
                                    SocketConnection.send(CommandID.NONO_GET_CHIP,13);
                                 }]);
                              }]);
                           }]);
                        }
                     });
                  }
                  else
                  {
                     TasksManager.getProStatusList(96,function(param1:Array):void
                     {
                        var arr:Array = param1;
                        if(Boolean(arr[1]) && !arr[2])
                        {
                           TasksManager.complete(96,2,function():void
                           {
                              completeTask();
                           },false);
                        }
                        if(Boolean(arr[2]) && !arr[3])
                        {
                           completeTask();
                        }
                     });
                  }
               }
            }
         }
         else
         {
            NpcDialog.show(NPC.SHAWN,["欢迎来到发明室的小赛尔，只有探索才会有更多的发现，求知欲和上进心是你成长的必要条件。"],["杰西卡的试炼"],[this.JXKtrain]);
         }
      }
      
      private function JXKtrain() : void
      {
         NpcDialog.show(NPC.SHAWN,["得到杰西卡的认可需要多元能力，做好挑战准备了吗？"],["准备好了","下次再来"],[this.fight]);
      }
      
      public function fight() : void
      {
         this.initJXKBoss();
      }
      
      private function initJXKBoss() : void
      {
         if(!this._bossMC)
         {
            this._bossMC = new BossModel(432,0);
            this._bossMC.show(new Point(677,247),0);
         }
         this._bossMC.mouseEnabled = true;
         this._bossMC.addEventListener(MouseEvent.CLICK,this.onBossClick);
         ToolTipManager.add(this._bossMC,"杰西卡");
      }
      
      private function onBossClick(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.mapID == 107)
         {
            this.enterFight();
         }
      }
      
      private function enterFight() : void
      {
         NpcDialog.show(NPC.SHAWN,["不同的挑战检验不同的能力，听说完成不同的挑战杰西卡会赠予你不同的力量，请选择你要挑战的选项："],["速杀之力：任意精灵单挑战胜杰西卡（仅限周一、周四、周日）","相持之命：多精灵五十回合以上战胜杰西卡（仅限周二、周五、周日）","宿命之战：用盖亚单挑战胜杰西卡（仅限周三、周六、周日）"],[this.fightOne,this.fightTwo,this.fightThree]);
      }
      
      private function fightOne() : void
      {
         if(MainManager.actorInfo.mapID == 107)
         {
            FightInviteManager.fightWithBoss("速杀之力",0);
         }
      }
      
      private function fightTwo() : void
      {
         if(MainManager.actorInfo.mapID == 107)
         {
            FightInviteManager.fightWithBoss("相持之命",1);
         }
      }
      
      private function fightThree() : void
      {
         if(MainManager.actorInfo.mapID == 107)
         {
            FightInviteManager.fightWithBoss("宿命之战",2);
         }
      }
      
      private function completeTask() : void
      {
         var mapTarget:MapProcess_107 = null;
         mapTarget = null;
         mapTarget = new MapProcess_107();
         mapTarget.mark.visible = true;
         NpcDialog.show(NPC.SHAWN,[" 你一定也希望自己的NoNo拥有更多能力，我想这本芯片手册会帮到你的，抽空一定要认真阅读下哦！"],["我一定会成为芯片达人的！"],[function():void
         {
            NpcDialog.show(NPC.SHAWN,[" 是不是奇怪为什么我的侠客和你的NoNo样子不同，#8因为侠客可是拥有超能力量的超能NoNo。"],["什么是超能NoNo呢？"],[function():void
            {
               NpcDialog.show(NPC.SHAWN,[" 嗯…这个问题还是让侠客来回答你吧，一会你可以直接问问它，或者打开右边的超能NoNo手册了解下吧！"],["那么超能NoNo有什么特别之处吗？"],[function():void
               {
                  NpcDialog.show(NPC.SHAWN,[" 超能NoNo的超能力会帮助你在探索中获得更多的乐趣，让你获得更多的惊喜哦。#8它带给小赛尔的好处，可是言之不尽的！等你也拥有自己的超能NoNo时，就能细细体会到啦！"],["恩，看来有必要好好了解下超能NoNo……"],[function():void
                  {
                     mapTarget.mark.visible = false;
                     TasksManager.complete(96,3,null,true);
                  }]);
               }]);
            }]);
         }]);
      }
      
      private function tasksCheck() : void
      {
         if(!MainManager.actorModel.nono)
         {
            TasksManager.getProStatusList(96,function(param1:Array):void
            {
               var arr:Array = param1;
               if(Boolean(arr[1]) && !arr[2])
               {
                  NpcDialog.show(NPC.SHAWN,[" 你的NoNo没有开机，暂时留在基地中啦。稍后回基地去开启它，你就能了解到它的一些功能了。"],["怎样才能启用这些功能呢？"],[function():void
                  {
                     NpcDialog.show(NPC.SHAWN,[" NoNo虽然拥有很多特别的功能，但这些能力需要加载芯片才能实现。比如，只有加载了跟随模式芯片，才能让你的NoNo陪你走天下。"],["跟随模式芯片？"],[function():void
                     {
                        NpcDialog.show(NPC.SHAWN,[" #8这是我送给你的礼物，回基地为你的NoNo加载上，我想你就能恍然大悟了。"],["（会是什么礼物呢？真期待啊！）"],[function():void
                        {
                           SocketConnection.addCmdListener(CommandID.NONO_GET_CHIP,onGetChip);
                           SocketConnection.send(CommandID.NONO_GET_CHIP,13);
                        }]);
                     }]);
                  }]);
               }
            });
         }
         else
         {
            TasksManager.getProStatusList(96,function(param1:Array):void
            {
               var mapTarget:MapProcess_107 = null;
               var arr:Array = param1;
               mapTarget = null;
               if(Boolean(arr[2]) && !arr[3])
               {
                  mapTarget = new MapProcess_107();
                  mapTarget.mark.visible = true;
                  NpcDialog.show(NPC.SHAWN,[" 你一定也希望自己的NoNo拥有更多能力，我想这本芯片手册会帮到你的，抽空一定要认真阅读下哦！"],["我一定会成为芯片达人的！"],[function():void
                  {
                     NpcDialog.show(NPC.SHAWN,[" 是不是奇怪为什么我的侠客和你的NoNo样子不同，#8因为侠客可是拥有超能力量的超能NoNo。"],["什么是超能NoNo呢？"],[function():void
                     {
                        NpcDialog.show(NPC.SHAWN,[" 嗯…这个问题还是让侠客来回答你吧，一会你可以直接问问它，或者打开右边的超能NoNo手册了解下吧！"],["那么超能NoNo有什么特别之处吗？"],[function():void
                        {
                           NpcDialog.show(NPC.SHAWN,[" 超能NoNo的超能力会帮助你在探索中获得更多的乐趣，让你获得更多的惊喜哦。#8它带给小赛尔的好处，可是言之不尽的！等你也拥有自己的超能NoNo时，就能细细体会到啦！"],["恩，看来有必要好好了解下超能NoNo……"],[function():void
                           {
                              TasksManager.complete(96,3,null,true);
                              mapTarget.mark.visible = false;
                           }]);
                        }]);
                     }]);
                  }]);
               }
            });
         }
      }
      
      private function checkNono() : void
      {
         if(MainManager.actorInfo.hasNono)
         {
            if(!MainManager.actorModel.nono)
            {
               TasksManager.getProStatusList(96,function(param1:Array):void
               {
                  if(Boolean(param1[2]) && !param1[3])
                  {
                     NpcDialog.show(NPC.SHAWN,[" 回基地打开NoNo的0xff0000储藏空间0xffffff，为它加载上0xff0000跟随模式芯片0xffffff，带上它一起来见我吧。"],["嘿嘿，带着NoNo逛一定很帅气！"],null);
                     return;
                  }
               });
            }
         }
      }
      
      private function onGetChip(param1:SocketEvent) : void
      {
         var data:ByteArray = null;
         var len:int = 0;
         var arr:Array = null;
         var i:int = 0;
         var id:uint = 0;
         var e:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.NONO_GET_CHIP,this.onGetChip);
         data = e.data as ByteArray;
         data.readUnsignedInt();
         data.readUnsignedInt();
         data.readUnsignedInt();
         len = int(data.readUnsignedInt());
         arr = [];
         i = 0;
         while(i < len)
         {
            arr.push({
               "id":data.readUnsignedInt(),
               "count":data.readUnsignedInt()
            });
            i++;
         }
         id = uint(arr[0].id);
         ItemInBagAlert.show(id,"一个" + TextFormatUtil.getRedTxt("跟随模式芯片") + "已放入你的NoNo仓库",function():void
         {
            NpcDialog.show(NPC.SHAWN,[" 回基地打开NoNo的0xff0000储藏空间0xffffff，为它加载上0xff0000跟随模式芯片0xffffff，带上它一起来见我吧。"],["嘿嘿，带着NoNo逛一定很帅气！"],[function():void
            {
               TasksManager.complete(96,2,null,true);
            }]);
         });
      }
      
      private function onTaskWithoutDes(param1:NpcEvent) : void
      {
         var e:NpcEvent = param1;
         if(Boolean(MainManager.actorInfo.hasNono) && TasksManager.getTaskStatus(96) == TasksManager.COMPLETE)
         {
            NpcTipDialog.show("为了保证你能确实得照顾好我发明的NoNo，这里有几个问题要考考你。\r仔细听好了哦。",this.showQuestion,NpcTipDialog.SHAWN);
         }
         else if(MainManager.actorInfo.hasNono)
         {
            if(Boolean(MainManager.actorModel.nono))
            {
               if(TasksManager.getTaskStatus(96) == TasksManager.UN_ACCEPT)
               {
                  TasksManager.accept(96,function():void
                  {
                     TasksManager.complete(96,0,function():void
                     {
                        TasksManager.complete(96,1,function():void
                        {
                           TasksManager.complete(96,2,function():void
                           {
                              tasksCheck();
                           },false);
                        },false);
                     },false);
                  });
               }
               else if(TasksManager.getTaskStatus(96) == TasksManager.ALR_ACCEPT)
               {
                  TasksManager.getProStatusList(96,function(param1:Array):void
                  {
                     var arr:Array = param1;
                     if(Boolean(arr[1]) && !arr[2])
                     {
                        TasksManager.complete(96,2,function():void
                        {
                           tasksCheck();
                        },false);
                     }
                  });
               }
            }
            else if(TasksManager.getTaskStatus(96) == TasksManager.UN_ACCEPT)
            {
               TasksManager.accept(96,function():void
               {
                  TasksManager.complete(96,0,function():void
                  {
                     TasksManager.complete(96,1,function():void
                     {
                        tasksCheck();
                     },false);
                  },false);
               });
            }
         }
         else if(TasksManager.getTaskStatus(96) == TasksManager.UN_ACCEPT)
         {
            TaskController_96.acceptTask();
         }
      }
      
      private function showQuestion() : void
      {
         if(!this._questionPanel)
         {
            this._questionPanel = ModuleManager.getModule(ClientConfig.getTaskModule("ShawnQuestion"),"正在载入问答题");
            this._questionPanel.setup();
         }
         this._questionPanel.show();
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.removeEventListener(NpcEvent.NPC_CLICK,this.onClick);
            this._curNpcModel.removeEventListener(NpcEvent.TASK_WITHOUT_DES,this.onTaskWithoutDes);
            this._curNpcModel.destroy();
            this._curNpcModel = null;
         }
         if(Boolean(this._questionPanel))
         {
            this._questionPanel.destroy();
            this._questionPanel = null;
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

