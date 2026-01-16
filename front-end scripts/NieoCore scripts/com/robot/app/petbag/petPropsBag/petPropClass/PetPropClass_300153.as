package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300153
   {
      
      public function PetPropClass_300153(param1:PetPropInfo)
      {
         super();
         SocketConnection.send(CommandID.SET_PET_CONST_FORM,param1.petInfo.catchTime,0);
      }
   }
}

