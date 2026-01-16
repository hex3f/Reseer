package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300670 extends PetPropClass_300651
   {
      
      public function PetPropClass_300670(param1:PetPropInfo)
      {
         super(param1);
      }
      
      override protected function onChoose(param1:int, param2:String) : void
      {
         SocketConnection.send(CommandID.USE_PET_ITEM_FULL_ABILITY_OF_STUDY,_info.petInfo.catchTime,param1,_info.itemId,1);
      }
   }
}

