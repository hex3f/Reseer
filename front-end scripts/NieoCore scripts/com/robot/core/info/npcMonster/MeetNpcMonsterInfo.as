package com.robot.core.info.npcMonster
{
   import flash.utils.IDataInput;
   
   public class MeetNpcMonsterInfo
   {
      
      private var _rect:uint;
      
      public function MeetNpcMonsterInfo(param1:IDataInput)
      {
         super();
         this._rect = param1.readUnsignedInt();
      }
      
      public function get rect() : uint
      {
         return this._rect;
      }
   }
}

