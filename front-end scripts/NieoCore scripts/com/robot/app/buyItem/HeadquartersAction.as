package com.robot.app.buyItem
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.ui.alert.IconAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class HeadquartersAction
   {
      
      public function HeadquartersAction()
      {
         super();
      }
      
      public static function buyItem(param1:uint, param2:Boolean = true, param3:uint = 1) : void
      {
         var price:uint = 0;
         var name:String = null;
         var id:uint = param1;
         var isTip:Boolean = param2;
         var count:uint = param3;
         var str:String = null;
         if(ItemXMLInfo.getVipOnly(id))
         {
            if(!MainManager.actorInfo.vip)
            {
               Alarm.show("你还没有开通超能NoNo，不能购买这个装备哦！");
               return;
            }
         }
         if(!isTip)
         {
            SocketConnection.send(CommandID.HEAD_BUY,id,count);
            return;
         }
         price = uint(ItemXMLInfo.getPrice(id));
         name = ItemXMLInfo.getName(id);
         if(price > 0)
         {
            if(MainManager.isRoomHalfDay)
            {
               str = "<font color=\'#ff0000\'>" + name + "</font>需要花费" + price.toString() + "赛尔豆，<font color=\'#ff0000\'>（半价日只需要花费" + price / 2 + "赛尔豆）</font>，要确定购买吗？";
            }
            else
            {
               str = "<font color=\'#ff0000\'>" + name + "</font>需要花费" + price.toString() + "赛尔豆，" + "你现在拥有" + MainManager.actorInfo.coins + "赛尔豆，要确定购买吗？";
            }
         }
         else
         {
            str = "<font color=\'#ff0000\'>" + name + "</font>免费赠送，你确定现在就要领取吗？";
         }
         IconAlert.show(str,id,function():void
         {
            SocketConnection.send(CommandID.HEAD_BUY,id,count);
         });
      }
      
      public static function buySinItem(param1:uint, param2:uint) : void
      {
         SocketConnection.send(CommandID.ITEM_BUY,param1,param2);
      }
      
      public static function exchangeSinItem(param1:uint, param2:uint) : void
      {
         var type:uint = param1;
         var need:uint = param2;
         if(MainManager.actorInfo.fightBadge < need)
         {
            Alert.show("你的战斗徽章数不够!");
            return;
         }
         Alert.show("你确定要兑换吗?",function():void
         {
            SocketConnection.addCmdListener(CommandID.EXCHANGE_CLOTH_COMPLETE,onEcHandler);
            SocketConnection.send(CommandID.EXCHANGE_CLOTH_COMPLETE,type);
         });
      }
      
      private static function onEcHandler(param1:SocketEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         SocketConnection.removeCmdListener(CommandID.EXCHANGE_CLOTH_COMPLETE,onEcHandler);
         var _loc4_:ByteArray = param1.data as ByteArray;
         _loc4_.readUnsignedInt();
         _loc4_.readUnsignedInt();
         MainManager.actorInfo.fightBadge = _loc4_.readUnsignedInt();
         var _loc5_:uint = _loc4_.readUnsignedInt();
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc2_ = _loc4_.readUnsignedInt();
            _loc3_ = _loc4_.readUnsignedInt();
            Alarm.show(_loc3_ + "个" + TextFormatUtil.getRedTxt(ItemXMLInfo.getName(_loc2_)) + "已经放入你的背包。");
            _loc6_++;
         }
      }
      
      public static function exchangePet(param1:uint, param2:uint) : void
      {
         var type:uint = param1;
         var need:uint = param2;
         var f:uint = uint(MainManager.actorInfo.fightBadge);
         if(MainManager.actorInfo.fightBadge < need)
         {
            Alert.show("你的战斗徽章数不够!");
            return;
         }
         Alert.show("你确定要兑换吗?",function():void
         {
            SocketConnection.addCmdListener(CommandID.EXCHANGE_PET_COMPLETE,onExtPetHandler);
            SocketConnection.send(CommandID.EXCHANGE_PET_COMPLETE,type);
         });
      }
      
      private static function onExtPetHandler(param1:SocketEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:String = null;
         SocketConnection.removeCmdListener(CommandID.EXCHANGE_PET_COMPLETE,onExtPetHandler);
         var _loc8_:ByteArray = param1.data as ByteArray;
         MainManager.actorInfo.fightBadge = _loc8_.readUnsignedInt();
         var _loc9_:uint = _loc8_.readUnsignedInt();
         var _loc10_:uint = _loc8_.readUnsignedInt();
         if(_loc9_ != 0)
         {
            _loc2_ = PetXMLInfo.getName(_loc9_);
            Alarm.show("一个" + TextFormatUtil.getRedTxt(_loc2_) + "作为奖励已经放入你的精灵仓库！");
            PetManager.addStorage(_loc9_,_loc10_);
         }
         else
         {
            _loc3_ = _loc8_.readUnsignedInt();
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = _loc8_.readUnsignedInt();
               _loc6_ = _loc8_.readUnsignedInt();
               _loc7_ = ItemXMLInfo.getName(_loc5_);
               Alarm.show(_loc6_.toString() + "个" + TextFormatUtil.getRedTxt(_loc7_) + "作为奖励已经放入你的背包！");
               _loc4_++;
            }
         }
      }
   }
}

