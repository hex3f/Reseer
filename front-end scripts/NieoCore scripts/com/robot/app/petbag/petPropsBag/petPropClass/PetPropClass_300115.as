package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300115
   {
      
      public function PetPropClass_300115(param1:PetPropInfo)
      {
         super();
         SocketConnection.send(CommandID.USE_SPEEDUP_ITEM,param1.itemId);
      }
   }
}

