package com.robot.core.cmd
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class SpringGiftNoticeCmdListener extends BaseBeanController
   {
      
      public function SpringGiftNoticeCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         finish();
      }
      
      private function onGigtNoticeHandler(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         MainManager.actorInfo.coins = _loc2_.readUnsignedInt();
         MainManager.actorInfo.superNono = true;
         _loc2_.readUnsignedInt();
         NonoManager.info.superEnergy = _loc2_.readUnsignedInt();
         NonoManager.info.superLevel = _loc2_.readUnsignedInt();
         NonoManager.info.superStage = _loc2_.readUnsignedInt();
         MainManager.actorInfo.vipLevel = NonoManager.info.superLevel;
         MainManager.actorInfo.vipValue = NonoManager.info.superEnergy;
         MainManager.actorInfo.vipStage = NonoManager.info.superStage;
         if(Boolean(MainManager.actorModel.nono))
         {
            MainManager.actorModel.hideNono();
            MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
         }
      }
   }
}

