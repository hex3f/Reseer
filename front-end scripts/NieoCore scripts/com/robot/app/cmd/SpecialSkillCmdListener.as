package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.update.UpdateSkillInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class SpecialSkillCmdListener extends BaseBeanController
   {
      
      public function SpecialSkillCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.LEARN_SPECIAL_SKILL_NOTICE,this.onSpecialHandler);
         finish();
      }
      
      private function onSpecialHandler(param1:SocketEvent) : void
      {
         var _loc5_:UpdateSkillInfo = null;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = new UpdateSkillInfo();
            _loc5_.petCatchTime = _loc2_.readUnsignedInt();
            _loc6_ = _loc2_.readUnsignedInt();
            _loc7_ = _loc2_.readUnsignedInt();
            if(_loc6_ == 0)
            {
               _loc5_.activeSkills = [];
               _loc5_.unactiveSkills = [_loc7_];
            }
            else
            {
               _loc5_.activeSkills = [_loc6_];
               _loc5_.unactiveSkills = [];
            }
            PetManager.dispatchEvent(new PetEvent(PetEvent.STUDY_SPECIAL_SKILL,_loc5_.petCatchTime,_loc5_));
            _loc4_++;
         }
      }
   }
}

