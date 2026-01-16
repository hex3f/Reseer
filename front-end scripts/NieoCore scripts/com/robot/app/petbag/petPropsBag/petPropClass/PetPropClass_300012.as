package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   
   public class PetPropClass_300012
   {
      
      public function PetPropClass_300012(param1:PetPropInfo)
      {
         super();
         if(param1.petInfo.hp == param1.petInfo.maxHp)
         {
            Alarm.show("你的<font color=\'#ff0000\'>" + param1.petInfo.name + "</font>不需要再使用此物品啦!");
         }
         else
         {
            SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,param1.petInfo.catchTime,param1.itemId);
         }
      }
   }
}

