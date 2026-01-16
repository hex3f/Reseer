package com.robot.core.info.teamPK
{
   import com.robot.core.info.team.ArmInfo;
   import com.robot.core.utils.SolidType;
   import flash.utils.IDataInput;
   
   public class TeamPkBuildingInfo extends ArmInfo
   {
      
      private var _headID:uint;
      
      public function TeamPkBuildingInfo(param1:IDataInput, param2:uint)
      {
         super();
         this._headID = param2;
         this.id = param1.readUnsignedInt();
         form = param1.readUnsignedInt();
         buyTime = param1.readUnsignedInt();
         hp = param1.readUnsignedInt();
         pos.x = param1.readUnsignedInt();
         pos.y = param1.readUnsignedInt();
         dir = param1.readUnsignedInt();
         status = param1.readUnsignedInt();
      }
      
      override public function set id(param1:uint) : void
      {
         _id = param1;
         if(_id == 1)
         {
            styleID = this._headID;
            isFixed = true;
         }
         else
         {
            styleID = _id;
            isFixed = false;
         }
         if(_id == 1)
         {
            type = SolidType.HEAD;
         }
         else if(_id >= 2 && _id <= 60)
         {
            type = SolidType.INDUSTRY;
         }
         else if(_id >= 61 && _id <= 140)
         {
            type = SolidType.MILITARY;
         }
         else if(_id >= 141 && _id <= 200)
         {
            type = SolidType.DEFENSE;
         }
         else if(_id >= 800001 && _id <= 800200)
         {
            type = SolidType.FRAME;
         }
         else if(_id >= 800501 && _id <= 801000)
         {
            type = SolidType.PUT;
         }
      }
   }
}

