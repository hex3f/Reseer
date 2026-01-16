package com.robot.app.buyItem
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.FortressItemXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.utils.TextFormatUtil;
   
   public class ArmAction
   {
      
      public function ArmAction()
      {
         super();
      }
      
      public static function buyItem(param1:uint, param2:Boolean = true) : void
      {
         var price:uint = 0;
         var name:String = null;
         var id:uint = param1;
         var isTip:Boolean = param2;
         var str:String = null;
         if(!isTip)
         {
            SocketConnection.send(CommandID.ARM_UP_BUY,id);
            return;
         }
         price = uint(FortressItemXMLInfo.getPrice(id));
         name = FortressItemXMLInfo.getName(id);
         if(price > 0)
         {
            str = TextFormatUtil.getRedTxt(name) + "需要花费" + price.toString() + "赛尔豆，" + "你现在拥有" + MainManager.actorInfo.coins + "赛尔豆，要确定购买吗？";
         }
         else
         {
            str = TextFormatUtil.getRedTxt(name) + "免费赠送，你确定现在就要领取吗？";
         }
         Alert.show(str,function():void
         {
            SocketConnection.send(CommandID.ARM_UP_BUY,id);
         });
      }
   }
}

