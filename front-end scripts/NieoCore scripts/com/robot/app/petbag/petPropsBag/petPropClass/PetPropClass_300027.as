package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300027
   {
      
      public function PetPropClass_300027(param1:PetPropInfo)
      {
         super();
         SocketConnection.send(CommandID.USE_SPEEDUP_ITEM,param1.itemId);
      }
   }
}

