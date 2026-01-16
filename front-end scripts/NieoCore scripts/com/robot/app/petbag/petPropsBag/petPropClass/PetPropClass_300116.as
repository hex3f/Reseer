package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300116
   {
      
      public function PetPropClass_300116(param1:PetPropInfo)
      {
         super();
         SocketConnection.send(CommandID.USE_ENERGY_XISHOU,param1.itemId);
      }
   }
}

