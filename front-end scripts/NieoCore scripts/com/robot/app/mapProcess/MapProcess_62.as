package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.core.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.pet.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   
   public class MapProcess_62 extends BaseMapProcess
   {
      
      public function MapProcess_62()
      {
         super();
      }
      
      override protected function init() : void
      {
         if(FightInviteManager.isKillBigPetB0 == false)
         {
            SocketConnection.addCmdListener(CommandID.PET_BARGE_LIST,this.addCmListenrPet);
            SocketConnection.send(CommandID.PET_BARGE_LIST,242,242);
         }
      }
      
      private function addCmListenrPet(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_BARGE_LIST,this.addCmListenrPet);
         var _loc2_:PetBargeListInfo = param1.data as PetBargeListInfo;
         var _loc3_:Array = _loc2_.isKillList;
         if(_loc3_.length != 0)
         {
            FightInviteManager.isKillBigPetB0 = true;
         }
         else
         {
            EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,this.onCloseFight);
         }
      }
      
      private function onCloseFight(param1:PetFightEvent) : void
      {
         var _loc2_:FightOverInfo = param1.dataObj["data"];
         if(_loc2_.winnerID == MainManager.actorInfo.userID)
         {
            EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,this.onCloseFight);
            FightInviteManager.isKillBigPetB0 = true;
         }
      }
      
      override public function destroy() : void
      {
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,this.onCloseFight);
      }
      
      public function changeMap() : void
      {
         MapManager.changeMap(63);
      }
   }
}

