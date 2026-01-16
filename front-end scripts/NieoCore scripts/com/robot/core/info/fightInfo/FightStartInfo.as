package com.robot.core.info.fightInfo
{
   import com.robot.core.manager.MainManager;
   import flash.utils.IDataInput;
   
   public class FightStartInfo
   {
      
      private var _myInfo:FightPetInfo;
      
      private var _otherInfo:FightPetInfo;
      
      private var _infoArray:Array = [];
      
      private var _isCanAuto:Boolean;
      
      public function FightStartInfo(param1:IDataInput)
      {
         super();
         this._isCanAuto = param1.readUnsignedInt() == 1;
         var _loc2_:FightPetInfo = new FightPetInfo(param1);
         if(_loc2_.userID == MainManager.actorInfo.userID)
         {
            this._myInfo = _loc2_;
            this._otherInfo = new FightPetInfo(param1);
            this._infoArray.push(this._myInfo,this._otherInfo);
         }
         else
         {
            this._otherInfo = _loc2_;
            this._myInfo = new FightPetInfo(param1);
            this._infoArray.push(this._myInfo,this._otherInfo);
         }
      }
      
      public function get isCanAuto() : Boolean
      {
         return this._isCanAuto;
      }
      
      public function get myInfo() : FightPetInfo
      {
         return this._myInfo;
      }
      
      public function get otherInfo() : FightPetInfo
      {
         return this._otherInfo;
      }
      
      public function get infoArray() : Array
      {
         return this._infoArray;
      }
   }
}

