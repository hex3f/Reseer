package com.robot.app.energy.utils
{
   import com.robot.app.energy.ore.DayOreCount;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.task.CateInfo;
   import com.robot.core.info.task.DayTalkInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.Direction;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.events.SocketEvent;
   
   public class EnergyController
   {
      
      private static var npcDoctorMc:String;
      
      private static var _type:uint;
      
      private static var dayOre:DayOreCount;
      
      private static var waitTime:Timer;
      
      private static var mapId:uint;
      
      private static var tipStr:String;
      
      private static var bMiningStr:String;
      
      private static var type:String;
      
      public function EnergyController()
      {
         super();
      }
      
      public static function exploit(param1:uint = 0) : void
      {
         switch(MapManager.currentMap.id)
         {
            case 10:
               _type = 1;
               bMiningStr = "1";
               break;
            case 21:
               _type = 2;
               bMiningStr = "1";
               break;
            case 15:
               _type = 3;
               bMiningStr = "1";
               break;
            case 20:
               _type = 4;
               bMiningStr = "2";
               break;
            case 25:
               _type = 5;
               bMiningStr = "2";
               break;
            case 16:
               _type = 6;
               bMiningStr = "2";
               break;
            case 34:
               _type = 7;
               bMiningStr = "3";
               break;
            case 105:
               _type = 9;
               bMiningStr = "4";
               break;
            case 106:
               if(param1 != 1)
               {
                  _type = 10;
                  bMiningStr = "5";
                  break;
               }
               if(param1 == 1)
               {
                  _type = 11;
                  bMiningStr = "6";
               }
               break;
            case 49:
               _type = 12;
               bMiningStr = "7";
               break;
            case 54:
               switch(param1)
               {
                  case 1:
                     _type = 14;
                     bMiningStr = "8";
                     break;
                  case 2:
                     _type = 15;
                     bMiningStr = "9";
                     break;
                  case 3:
                     _type = 16;
                     bMiningStr = "10";
               }
               break;
            case 325:
               _type = 17;
               bMiningStr = "1";
               break;
            case 328:
               _type = 18;
               bMiningStr = "2";
         }
         init();
      }
      
      private static function init() : void
      {
         npcDoctorMc = NpcTipDialog.SHU_KE;
         if(MainManager.actorInfo.actionType == 1)
         {
            NpcTipDialog.show("   你正处于飞行中,是不能进行能源采集的...",null,npcDoctorMc,-80);
            return;
         }
         switch(bMiningStr)
         {
            case "10":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有欧古德矿石了？！\n   采摘欧古德矿石需要专业工具" + TextFormatUtil.getRedTxt("电能锯子") + "，你可以在赫尔卡星拆除导弹后获得哦，若你已经拥有它了，赶快装备上它吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "9":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有希罗里矿石了？！\n   采摘希罗里矿石需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "8":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有露尼亚矿石了？！\n   采摘露尼亚矿石需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "7":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有电能石了？！\n   采摘电能石需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "6":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有豆豆果实了？！\n   采摘豆豆果实需要专业工具" + TextFormatUtil.getRedTxt("电能锯子") + "，你可以在外面拆除导弹后获得哦，若你已经拥有它了，赶快装备上它吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "5":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有纳格晶体了？！\n   采摘纳格晶体需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "4":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有蘑菇结晶了？！\n    矿石挖掘需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "1":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有黄晶矿了？！\n    矿石挖掘需要专业工具" + TextFormatUtil.getRedTxt("挖矿钻头") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "2":
               if(MainManager.actorInfo.clothIDs.indexOf(100055) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有甲烷燃气了？！\n    采集甲烷燃气需要专业工具" + TextFormatUtil.getRedTxt("气体收集器") + "，若你已从赛尔飞船机械室找到它，快把它装备上吧！",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "3":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
               {
                  NpcTipDialog.show("你也发现这里有藤结晶了？！\n   采摘藤结晶需要专业工具" + TextFormatUtil.getRedTxt("电能锯子") + "，你可以在外面拆除导弹后获得哦，若你已经拥有它了，赶快装备上它吧！",null,npcDoctorMc,-80);
                  return;
               }
         }
         mapId = MapManager.currentMap.id;
         countExploitTimes();
      }
      
      private static function countExploitTimes() : void
      {
         dayOre = new DayOreCount();
         dayOre.addEventListener(DayOreCount.countOK,onCountOK);
         dayOre.sendToServer(_type);
      }
      
      private static function onCountOK(param1:Event) : void
      {
         dayOre.removeEventListener(DayOreCount.countOK,onCountOK);
         switch(bMiningStr)
         {
            case "10":
               tipStr = "欧古德矿石";
               type = "采摘";
               if(DayOreCount.oreCount >= 1)
               {
                  Alarm.show("你今天已经挖过欧古德矿石了");
                  return;
               }
               break;
            case "9":
               tipStr = "希罗里矿石";
               type = "挖掘";
               if(DayOreCount.oreCount >= 1)
               {
                  Alarm.show("你今天已经挖过希罗里矿石了");
                  return;
               }
               break;
            case "8":
               tipStr = "露尼亚矿石";
               type = "挖掘";
               if(DayOreCount.oreCount >= 1)
               {
                  Alarm.show("你今天已经挖过露尼亚矿石了");
                  return;
               }
               break;
            case "7":
               tipStr = "电能石";
               type = "挖掘";
               if(DayOreCount.oreCount >= 2)
               {
                  Alarm.show("你今天已经挖过电能石了");
                  return;
               }
               break;
            case "6":
               tipStr = "豆豆果实";
               type = "采摘";
               if(DayOreCount.oreCount >= 1)
               {
                  Alarm.show("你今天已经挖过豆豆果实了。");
                  return;
               }
               break;
            case "5":
               tipStr = "纳格晶体";
               type = "挖掘";
               if(DayOreCount.oreCount >= 1)
               {
                  NpcTipDialog.show("为了纳格晶体可持续挖掘，这里每天只能挖掘1次。你可以去其它星球看看还有没有矿石可以挖掘，或者明天再来挖掘。",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "4":
               tipStr = "蘑菇结晶";
               type = "挖掘";
               if(DayOreCount.oreCount >= 3)
               {
                  NpcTipDialog.show("为了蘑菇结晶可持续挖掘，这里每天只能挖掘3次。你可以去其它星球看看还有没有矿石可以挖掘，或者明天再来挖掘。",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "1":
               tipStr = "黄晶矿";
               type = "挖掘";
               if(DayOreCount.oreCount >= 5)
               {
                  NpcTipDialog.show("为了黄晶矿可持续挖掘，这里每天只能挖掘5次。你可以去其它星球看看还有没有矿石可以挖掘，或者明天再来挖掘。",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "2":
               tipStr = "甲烷燃气";
               type = "采集";
               if(DayOreCount.oreCount >= 2)
               {
                  NpcTipDialog.show("为了甲烷燃气可持续采集，这里每天只能收集2次。你可以去其它星球看看还有没有甲烷燃气可以采集，或者明天再来采集。",null,npcDoctorMc,-80);
                  return;
               }
               break;
            case "3":
               tipStr = "藤结晶";
               type = "采摘";
               if(DayOreCount.oreCount >= 1)
               {
                  NpcTipDialog.show("你是一个勤劳的小赛尔，你已经完成了今天的晶体藤蔓切割任务，明天再来帮忙吧。",null,npcDoctorMc,-80);
                  return;
               }
         }
         var _loc2_:String = "探测发现这块区域埋藏着能源" + tipStr + ",宝贵的能源" + tipStr + "可以给赛尔飞船提供能源。\n    你是否要" + type + "一些这样的" + tipStr + "呢？";
         NpcTipDialog.showAnswer(_loc2_,exploitNow,null,NpcTipDialog.SHU_KE);
      }
      
      private static function exploitNow() : void
      {
         switch(bMiningStr)
         {
            case "10":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
               }
               else
               {
                  MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
               }
               MainManager.actorModel.specialAction(100059);
               break;
            case "9":
               MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "8":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "7":
               MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "6":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100059);
               break;
            case "5":
               MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "4":
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "1":
               if(mapId == 15 || mapId == 21)
               {
                  MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
               }
               if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  break;
               }
               MainManager.actorModel.specialAction(100014);
               break;
            case "2":
               if(MainManager.actorInfo.clothIDs.indexOf(100055) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
                  MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
                  break;
               }
               MainManager.actorModel.specialAction(100055);
               break;
            case "3":
               if(MainManager.actorInfo.clothIDs.indexOf(100059) == -1)
               {
                  MainManager.actorModel.specialAction(100717);
               }
               else
               {
                  MainManager.actorModel.specialAction(100059);
               }
         }
         var _loc1_:Sprite = MainManager.actorModel.sprite;
         _loc1_.parent.addChild(_loc1_);
         if(waitTime != null)
         {
            waitTime.removeEventListener(TimerEvent.TIMER,onTimer);
            waitTime.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         }
         waitTime = new Timer(1000,3);
         waitTime.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         waitTime.addEventListener(TimerEvent.TIMER,onTimer);
         waitTime.start();
         MainManager.actorModel.sprite.addEventListener(RobotEvent.WALK_START,onWalk);
      }
      
      private static function onTimeOver(param1:TimerEvent) : void
      {
         waitTime.removeEventListener(TimerEvent.TIMER,onTimer);
         waitTime.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         SocketConnection.addCmdListener(CommandID.TALK_CATE,onSuccess);
         SocketConnection.send(CommandID.TALK_CATE,_type);
      }
      
      private static function onWalk(param1:RobotEvent) : void
      {
         waitTime.removeEventListener(TimerEvent.TIMER,onTimer);
         waitTime.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         MainManager.actorModel.sprite.removeEventListener(RobotEvent.WALK_START,onWalk);
         waitTime.stop();
         MainManager.actorModel.stop();
         stopAct();
         if(bMiningStr == "3")
         {
            MainManager.actorModel.direction = Direction.DOWN;
         }
         NpcTipDialog.show("随便走动是无法挖到" + tipStr + "的!",null,npcDoctorMc,-80);
         MainManager.actorModel.skeleton.getSkeletonMC().scaleX = 1;
      }
      
      private static function onTimer(param1:TimerEvent) : void
      {
      }
      
      public static function destory() : void
      {
         if(waitTime != null)
         {
            waitTime.stop();
            waitTime.removeEventListener(TimerEvent.TIMER,onTimer);
            waitTime.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
            waitTime = null;
         }
         stopAct();
         MainManager.actorModel.sprite.removeEventListener(RobotEvent.WALK_START,onWalk);
         dayOre = null;
      }
      
      private static function stopAct() : void
      {
         MainManager.actorModel.stopSpecialAct();
         if(mapId == 15 || mapId == 21)
         {
            MainManager.actorModel.skeleton.getSkeletonMC().scaleX = 1;
         }
      }
      
      public static function exploitOK() : void
      {
         MainManager.actorModel.sprite.removeEventListener(RobotEvent.WALK_START,onWalk);
         stopAct();
      }
      
      private static function onSuccess(param1:SocketEvent) : void
      {
         var info:DayTalkInfo = null;
         var _cateInfo:CateInfo = null;
         var e:SocketEvent = param1;
         _cateInfo = null;
         var str:String = null;
         var str1:String = null;
         var nameStr:String = null;
         var n1:String = null;
         var ruleStr:String = null;
         var setStr:Function = function():void
         {
            switch(_cateInfo.id)
            {
               case 400001:
                  ruleStr = "块";
                  break;
               case 400002:
                  ruleStr = "罐";
                  break;
               case 400009:
                  ruleStr = "块";
               case 400014:
                  ruleStr = "块";
                  break;
               default:
                  ruleStr = "个";
            }
            nameStr = ItemXMLInfo.getName(_cateInfo.id);
         };
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,onSuccess);
         info = e.data as DayTalkInfo;
         if(info.outList.length > 0)
         {
            if(info.outList.length == 1)
            {
               _cateInfo = info.outList[0];
               setStr();
               str = "看样子你" + type + "到了" + _cateInfo.count.toString() + ruleStr + nameStr + "。" + nameStr + "都已经放入你的储存箱里了。\n<font color=\'#FF0000\'>    快去飞船动力室看看它有什么用</font>";
               if(_cateInfo == null)
               {
               }
            }
            else
            {
               _cateInfo = info.outList[0];
               setStr();
               str = "由于" + TextFormatUtil.getRedTxt("超能NoNo") + "的帮助，精炼出" + _cateInfo.count.toString() + ruleStr + nameStr + "！";
               n1 = nameStr;
               _cateInfo = info.outList[1];
               setStr();
               str1 = "你已经获得了" + info.outList[1].count.toString() + ruleStr + nameStr + "。";
               str = str1 + "\n" + "    " + str + nameStr + "和" + n1 + "已经放入你的存储箱中。";
            }
         }
         NpcTipDialog.show(str,null,npcDoctorMc,-80);
         if(bMiningStr == "3")
         {
            MainManager.actorModel.direction = Direction.DOWN;
         }
         MainManager.actorModel.skeleton.getSkeletonMC().scaleX = 1;
         exploitOK();
      }
   }
}

