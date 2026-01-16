package com.robot.app.cmd
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class GameOverCmdListener extends BaseBeanController
   {
      
      private var arrayItem:Array;
      
      private var index:uint = 0;
      
      public function GameOverCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.GAME_OVER,this.gameOverHander);
         finish();
      }
      
      private function gameOverHander(param1:SocketEvent) : void
      {
         var itemKind:uint = 0;
         var i:int = 0;
         var power:uint = 0;
         var e:SocketEvent = param1;
         power = 0;
         var id:uint = 0;
         var count:uint = 0;
         var by:ByteArray = e.data as ByteArray;
         var socre:uint = by.readUnsignedInt();
         var iq:uint = by.readUnsignedInt();
         power = by.readUnsignedInt();
         var mate:uint = by.readUnsignedInt();
         NonoManager.info.iq += iq;
         NonoManager.info.power += power;
         NonoManager.info.mate += mate;
         itemKind = by.readUnsignedInt();
         this.arrayItem = new Array();
         i = 0;
         while(i < itemKind)
         {
            id = by.readUnsignedInt();
            count = by.readUnsignedInt();
            this.arrayItem.push([id,count]);
            i++;
         }
         if(iq > 0)
         {
            NpcTipDialog.show("你聪明所以我聪明！嘿嘿，你有没有觉得我又聪明一点了呢？ 你的NoNo获得了" + iq + "点智慧值。",function():void
            {
               if(power > 0)
               {
                  NpcTipDialog.show("你的NoNo 获得了" + power + "点能量值。",function():void
                  {
                     if(arrayItem.length > 0)
                     {
                        getItem(arrayItem[index]);
                     }
                  },NpcTipDialog.NONO);
               }
               else if(arrayItem.length > 0)
               {
                  getItem(arrayItem[index]);
               }
            },NpcTipDialog.NONO);
         }
         if(iq == 0 && power > 0)
         {
            NpcTipDialog.show("你的NoNo 获得了" + power + "点能量值。",function():void
            {
               if(arrayItem.length > 0)
               {
                  getItem(arrayItem[index]);
               }
            },NpcTipDialog.NONO);
         }
         if(iq == 0 && power == 0 && this.arrayItem.length > 0)
         {
            this.getItem(this.arrayItem[this.index]);
         }
      }
      
      private function getItem(param1:Array) : void
      {
         var id:uint = 0;
         var count:uint = 0;
         var name:String = null;
         var arr:Array = param1;
         if(arr == null)
         {
            return;
         }
         id = uint(arr[0]);
         count = uint(arr[1]);
         name = ItemXMLInfo.getName(id);
         if(id == 1)
         {
            MainManager.actorInfo.coins += count;
            Alarm.show("在本次游戏中，你获得了" + count + "赛尔豆",function():void
            {
               ++index;
               if(index < arrayItem.length)
               {
                  getItem(arrayItem[index]);
               }
               if(index == arrayItem.length)
               {
                  index = 0;
               }
            });
         }
         else if(id == 3)
         {
            Alarm.show("在本次游戏中，你获得了" + count + "点" + TextFormatUtil.getRedTxt("积累经验"),function():void
            {
               ++index;
               if(index < arrayItem.length)
               {
                  getItem(arrayItem[index]);
               }
               if(index == arrayItem.length)
               {
                  index = 0;
               }
            });
         }
         else
         {
            Alarm.show("在本次游戏中，你获得了" + count + "个<font color=\'#FF0000\'>" + name + "</font>",function():void
            {
               ++index;
               if(index < arrayItem.length)
               {
                  getItem(arrayItem[index]);
               }
               if(index == arrayItem.length)
               {
                  index = 0;
               }
            });
         }
      }
   }
}

