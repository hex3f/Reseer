package com.robot.app.ogre
{
   import com.robot.app.mapProcess.active.SpecialPetActive;
   import com.robot.core.CommandID;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class SpecialPetCmdListener extends BaseBeanController
   {
      
      public function SpecialPetCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.SPECIAL_PET_NOTE,this.onSpecialList);
         finish();
      }
      
      private function onSpecialList(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         if(_loc3_ == 1)
         {
            SpecialPetActive.show(_loc4_);
         }
         else
         {
            SpecialPetActive.hide();
         }
      }
   }
}

