package com.robot.app.petUpdate
{
   import com.robot.core.CommandID;
   import com.robot.core.info.pet.update.PetUpdatePropInfo;
   import com.robot.core.info.pet.update.PetUpdateSkillInfo;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class PetUpdateCmdListener extends BaseBeanController
   {
      
      private var petUpdatePropCon:PetUpdatePropController;
      
      private var petUpdataeSkillCon:PetUpdateSkillController;
      
      public function PetUpdateCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         this.petUpdatePropCon = new PetUpdatePropController();
         this.petUpdataeSkillCon = new PetUpdateSkillController();
         SocketConnection.addCmdListener(CommandID.NOTE_UPDATE_PROP,this.onUpdateProp);
         SocketConnection.addCmdListener(CommandID.NOTE_UPDATE_SKILL,this.onUpdateSkill);
         finish();
      }
      
      private function onUpdateProp(param1:SocketEvent) : void
      {
         this.petUpdatePropCon.setup(param1.data as PetUpdatePropInfo);
      }
      
      private function onUpdateSkill(param1:SocketEvent) : void
      {
         var _loc2_:PetUpdateSkillInfo = param1.data as PetUpdateSkillInfo;
         this.petUpdataeSkillCon.setup(_loc2_);
      }
   }
}

