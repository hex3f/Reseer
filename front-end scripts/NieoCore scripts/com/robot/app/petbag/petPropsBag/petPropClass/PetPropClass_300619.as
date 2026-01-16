package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   
   public class PetPropClass_300619
   {
      
      public function PetPropClass_300619(param1:PetPropInfo)
      {
         super();
         if(param1.petInfo.ev_attack == 255)
         {
            Alarm.show("你的<font color=\'#ff0000\'>" + PetXMLInfo.getName(param1.petInfo.id) + "</font>的" + TextFormatUtil.getRedTxt(param1.itemName.substr(0,5)) + "已满，无法注入哦！");
         }
         else if(255 + param1.petInfo.ev_defence + param1.petInfo.ev_sa + param1.petInfo.ev_sd + param1.petInfo.ev_sp + param1.petInfo.ev_hp > 510)
         {
            Alarm.show("你的<font color=\'#ff0000\'>" + PetXMLInfo.getName(param1.petInfo.id) + "</font>的学习力总值不能超过510，无法注入哦！");
         }
         else
         {
            SocketConnection.send(CommandID.USE_PET_ITEM_FULL_ABILITY_OF_STUDY,param1.petInfo.catchTime,1,param1.itemId,0);
         }
      }
   }
}

