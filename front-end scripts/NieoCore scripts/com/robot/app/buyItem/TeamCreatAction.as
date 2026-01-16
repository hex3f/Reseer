package com.robot.app.buyItem
{
   import com.robot.app.task.taskUtils.taskDialog.DynamicNpcTipDialog;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.events.Event;
   
   public class TeamCreatAction
   {
      
      public function TeamCreatAction()
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
         if(!isTip)
         {
            SocketConnection.send(CommandID.TEAM_CREAT_ITEM,id,count);
            return;
         }
         if(ItemXMLInfo.getVipOnly(id))
         {
            if(!MainManager.actorInfo.superNono)
            {
               DynamicNpcTipDialog.show("只有" + TextFormatUtil.getRedTxt("超能NoNo") + "才能帮助你制造这套特殊的保卫战装备哟！",function():void
               {
                  var r:VipSession = new VipSession();
                  r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
                  {
                  });
                  r.getSession();
               },NpcTipDialog.NONO);
               return;
            }
         }
         price = uint(ItemXMLInfo.getUseEnergy(id));
         name = ItemXMLInfo.getName(id);
         if(price > 0)
         {
            str = "制造" + TextFormatUtil.getRedTxt(name) + "装备部件将消耗你的" + price.toString() + "能源值，确定要开始制造吗？";
         }
         else
         {
            str = TextFormatUtil.getRedTxt(name) + "免费赠送，你确定现在就要领取吗？";
         }
         Alert.show(str,function():void
         {
            SocketConnection.send(CommandID.TEAM_CREAT_ITEM,id,count);
         });
      }
   }
}

