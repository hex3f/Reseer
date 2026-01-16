package com.robot.core.info.fightInfo.attack
{
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import flash.utils.IDataInput;
   import org.taomee.manager.EventManager;
   
   public class FightOverInfo
   {
      
      private var _winnerID:uint;
      
      private var _reason:uint;
      
      public function FightOverInfo(param1:IDataInput)
      {
         super();
         this._reason = param1.readUnsignedInt();
         this._winnerID = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:uint = uint(param1.readUnsignedInt());
         MainManager.actorInfo.twoTimes = _loc2_;
         MainManager.actorInfo.threeTimes = _loc3_;
         MainManager.actorInfo.autoFightTimes = param1.readUnsignedInt();
         var _loc4_:uint = uint(param1.readUnsignedInt());
         var _loc5_:uint = uint(param1.readUnsignedInt());
         MainManager.actorInfo.energyTimes = _loc4_;
         MainManager.actorInfo.learnTimes = _loc5_;
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.ENERGY_TIMES_CHANGE));
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.SPEEDUP_CHANGE));
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.AUTO_FIGHT_CHANGE));
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.STUDY_TIMES_CHANGE));
      }
      
      public function get winnerID() : uint
      {
         return this._winnerID;
      }
      
      public function get reason() : uint
      {
         return this._reason;
      }
   }
}

