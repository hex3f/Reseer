package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.books.FlyBook;
   import com.robot.app.task.noviceGuide.GuideTaskAfter.GuideTaskFight;
   import com.robot.app.task.pioneerTaskList.BatteryTestTask;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class XixiDialog
   {
      
      private static var newPanel:MovieClip;
      
      public function XixiDialog()
      {
         super();
      }
      
      private static function showBatteryTask() : void
      {
         var _loc1_:BatteryTestTask = new BatteryTestTask();
      }
      
      public static function show(param1:uint = 0) : void
      {
         var id:uint = param1;
         var xixi:String = NpcTipDialog.CICI;
         var arr:Array = TasksManager.taskList;
         if(id == 94)
         {
            TasksManager.getProStatusList(94,function(param1:Array):void
            {
               var arr:Array = param1;
               if(Boolean(arr[0]) && !arr[1])
               {
                  ItemManager.addEventListener(ItemEvent.CLOTH_LIST,function():void
                  {
                     ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,arguments.callee);
                     if(ItemManager.containsCloth(100055))
                     {
                        MapManager.currentMap.controlLevel["arrowHeadMC"].visible = false;
                        NpcDialog.show(NPC.CICI,["慢！慢！你看我，都差点忘记和你说啦……在帕诺星系一些星球上我们发现了0xff0000黄晶矿0xffffff和0xff0000甲烷燃气0xffffff的采集点，我想现在你可以去含有这些资源的星球看看！"],["你可以再说得详细些吗？"],[function():void
                        {
                           NpcDialog.show(NPC.CICI,["先装备上0xff0000挖矿钻头0xffffff，去0xff0000火山星、克洛斯星或海洋星深水区0xffffff采集0xff00005块黄晶矿0xffffff。"],["好！我这就去！采好了我再回来找你哟！"],[function():void
                           {
                              TasksManager.complete(94,1,null,true);
                           }]);
                        }]);
                     }
                     else
                     {
                        NpcDialog.show(NPC.CICI,["咦？你忘了0xff0000气体收集器0xffffff在哪里买到？#8，在机械室0xff0000赛尔工厂0xffffff，可别再忘记咯！"],["好！我这就去看看！"]);
                     }
                  });
                  ItemManager.getCloth();
               }
               if(Boolean(arr[1]) && !arr[2])
               {
                  ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,function(param1:ItemEvent):void
                  {
                     var info:SingleItemInfo = null;
                     var evt:ItemEvent = param1;
                     ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,arguments.callee);
                     info = ItemManager.getCollectionInfo(400001);
                     if(info != null && info.itemNum >= 5)
                     {
                        NpcDialog.show(NPC.CICI,["哎呀！不错嘛！没想到你竟然这么快就上手咯！#6那么接下来再去采集0xff00005罐甲烷燃气0xffffff吧，你有信心完成任务吗？"],["小意思！没什么可以难倒我的！我这就起程！"],[function():void
                        {
                           TasksManager.complete(94,2,null,true);
                        }]);
                     }
                     else
                     {
                        NpcDialog.show(NPC.CICI,["你收集的黄晶矿不足0xff00005块0xffffff，请继续努力！"],["恩！我会再接再厉的！"]);
                     }
                  });
                  ItemManager.getCollection();
               }
               if(Boolean(arr[2]) && !arr[3])
               {
                  ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,function(param1:ItemEvent):void
                  {
                     ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,arguments.callee);
                     var _loc3_:SingleItemInfo = ItemManager.getCollectionInfo(400002);
                     if(_loc3_ != null && _loc3_.itemNum >= 5)
                     {
                        TasksManager.complete(94,3,null,true);
                     }
                     else
                     {
                        NpcDialog.show(NPC.CICI,["你收集的甲烷燃气不足0xff00005罐0xffffff，继续努力吧。"],["好的！这次我一定完成！"]);
                     }
                  });
                  ItemManager.getCollection();
               }
            });
            return;
         }
         if(TasksManager.taskList[1] == 0)
         {
            showNew();
            return;
         }
         if(TasksManager.taskList[2] == 1 && !GuideTaskModel.bReadFlyBook)
         {
            NpcTipDialog.show("看到<font color=\'#FF0000\'>精灵包</font>里的那只精灵了吧，是不是有点激动。别着急，我先给你介绍下赛尔号飞船，了解下我们远航的目的。",onReceive,xixi,-60);
            return;
         }
         if(!TasksManager.isComNoviceTask())
         {
            if(TasksManager.taskList[2] == 1)
            {
               if(TasksManager.taskList[0] == 3 && GuideTaskModel.bReadMonBook && GuideTaskModel.bTaskDoctor)
               {
                  NpcTipDialog.show("你已经从船长和博士那得到了不少信息吧，我现在把新手奖励送给你，现在你是赛尔号飞船上的新丁了，希望你结交到很多的好朋友一起探险哦!",onSubmit,xixi,-60);
               }
               else
               {
                  NpcTipDialog.show("罗杰船长和派特博士都在等你去拜访哦，别让他们等太久了哦。",null,xixi,-60);
               }
            }
            else if(TasksManager.taskList[2] == 3 && TasksManager.taskList[3] != 3)
            {
               NpcTipDialog.show("你已经得到了你的第一个精灵了吧，我也有自己的精灵哦，我们来一次精灵对战吧，看看谁的精灵更厉害。",onFight,xixi,-60);
            }
         }
      }
      
      private static function setTeskFun() : void
      {
      }
      
      private static function onReceive() : void
      {
         FlyBook.loadPanel();
      }
      
      private static function getFirstMonster() : void
      {
         DoctorGuideDialog.showChooseMonster();
      }
      
      public static function showNextDialog() : void
      {
         NpcTipDialog.show("    现在，罗杰船长和派特博士都等着要见你呢，你可以利用左下角的地图快速抵达船长室和实验室。当你得到指示回到我这里来，我会有份奖励给你。",onAcceptTask,NpcTipDialog.CICI,-60);
      }
      
      private static function onAcceptTask() : void
      {
      }
      
      private static function onFight() : void
      {
         GuideTaskFight.fight();
      }
      
      private static function onSubmit() : void
      {
         GuideTaskModel.submitTask();
      }
      
      private static function onCheckSkeeTask(param1:Array) : void
      {
         if(param1[0] == true && param1[1] == true)
         {
         }
      }
      
      public static function showNew() : void
      {
         var btn:SimpleButton = null;
         var closeBtn:SimpleButton = null;
         if(!newPanel)
         {
            newPanel = AssetsManager.getMovieClip("lib_newer_mc");
            DisplayUtil.align(newPanel,null,AlignType.MIDDLE_CENTER);
            btn = newPanel["goBtn"];
            btn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               getFirstMonster();
               DisplayUtil.removeForParent(newPanel);
            });
            closeBtn = newPanel["closeBtn"];
            closeBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               DisplayUtil.removeForParent(newPanel);
            });
         }
         LevelManager.appLevel.addChild(newPanel);
      }
   }
}

