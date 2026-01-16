package com.robot.app.buyItem
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.IconAlert;
   
   public class FitmentAction
   {
      
      public function FitmentAction()
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
            SocketConnection.send(CommandID.BUY_FITMENT,id,count);
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
            SocketConnection.send(CommandID.BUY_FITMENT,id,count);
         });
      }
   }
}

