package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPkUserInfo
   {
      
      private var _uid:uint;
      
      private var _hp:uint;
      
      private var _maxHp:uint;
      
      private var _where:uint;
      
      public function TeamPkUserInfo(param1:IDataInput)
      {
         super();
         this._uid = param1.readUnsignedInt();
         this._hp = param1.readUnsignedInt();
         this._maxHp = param1.readUnsignedInt();
         this._where = param1.readUnsignedInt();
         param1.readUnsignedInt();
         param1.readUnsignedInt();
      }
      
      public function get uid() : uint
      {
         return this._uid;
      }
      
      public function get hp() : uint
      {
         return this._hp;
      }
      
      public function get maxHp() : uint
      {
         return this._maxHp;
      }
      
      public function get isFreeze() : Boolean
      {
         return this._where == 2;
      }
   }
}

