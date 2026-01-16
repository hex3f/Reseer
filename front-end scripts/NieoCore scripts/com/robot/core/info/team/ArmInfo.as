package com.robot.core.info.team
{
   import com.robot.core.config.xml.FortressItemXMLInfo;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.ArmManager;
   import com.robot.core.utils.SolidType;
   import flash.utils.IDataInput;
   import org.taomee.ds.HashMap;
   
   public class ArmInfo extends FitmentInfo
   {
      
      public var styleID:uint;
      
      public var buyTime:uint;
      
      public var isUsed:Boolean;
      
      public var form:uint;
      
      public var hp:uint;
      
      public var workCount:uint;
      
      public var donateCount:uint;
      
      public var res:HashMap = new HashMap();
      
      public var resNum:uint;
      
      public function ArmInfo()
      {
         super();
      }
      
      public static function setFor2941(param1:ArmInfo, param2:IDataInput = null) : void
      {
         param1.id = param2.readUnsignedInt();
         param1.pos.x = param2.readUnsignedInt();
         param1.pos.y = param2.readUnsignedInt();
         param1.dir = param2.readUnsignedInt();
         param1.status = param2.readUnsignedInt();
      }
      
      public static function setFor2942(param1:ArmInfo, param2:IDataInput = null) : void
      {
         param1.id = param2.readUnsignedInt();
         param1.usedCount = param2.readUnsignedInt();
         param1.allCount = param2.readUnsignedInt();
      }
      
      public static function setFor2964(param1:ArmInfo, param2:IDataInput = null) : void
      {
         param1.id = param2.readUnsignedInt();
         param1.buyTime = param2.readUnsignedInt();
         param1.form = param2.readUnsignedInt();
         param1.pos.x = param2.readUnsignedInt();
         param1.pos.y = param2.readUnsignedInt();
         param1.dir = param2.readUnsignedInt();
         param1.status = param2.readUnsignedInt();
      }
      
      public static function setFor2966(param1:ArmInfo, param2:IDataInput = null) : void
      {
         param1.buyTime = param2.readUnsignedInt();
         param1.id = param2.readUnsignedInt();
         param1.form = param2.readUnsignedInt();
         param1.isUsed = Boolean(param2.readUnsignedInt());
      }
      
      public static function setFor2967_2965(param1:ArmInfo, param2:IDataInput = null) : void
      {
         var _loc3_:* = 0;
         param1.id = param2.readUnsignedInt();
         param1.buyTime = param2.readUnsignedInt();
         param1.form = param2.readUnsignedInt();
         param1.hp = param2.readUnsignedInt();
         param1.workCount = param2.readUnsignedInt();
         param1.donateCount = param2.readUnsignedInt();
         param1.res.clear();
         param1.resNum = 0;
         var _loc4_:Array = FortressItemXMLInfo.getResIDs(param1.id,param1.form);
         var _loc5_:int = 0;
         while(_loc5_ < 4)
         {
            _loc3_ = uint(param2.readUnsignedInt());
            param1.resNum += _loc3_;
            param1.res.add(_loc4_[_loc5_],_loc3_);
            _loc5_++;
         }
         param1.pos.x = param2.readUnsignedInt();
         param1.pos.y = param2.readUnsignedInt();
         param1.dir = param2.readUnsignedInt();
         param1.status = param2.readUnsignedInt();
      }
      
      override public function set id(param1:uint) : void
      {
         _id = param1;
         if(_id == 1)
         {
            this.styleID = ArmManager.headquartersID;
            isFixed = true;
         }
         else
         {
            this.styleID = _id;
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
      
      public function clone() : ArmInfo
      {
         var _loc1_:ArmInfo = new ArmInfo();
         _loc1_.id = id;
         _loc1_.styleID = this.styleID;
         _loc1_.pos = pos.clone();
         _loc1_.dir = dir;
         _loc1_.status = status;
         _loc1_.buyTime = this.buyTime;
         _loc1_.form = this.form;
         _loc1_.hp = this.hp;
         _loc1_.res = this.res.clone();
         _loc1_.type = type;
         _loc1_.workCount = this.workCount;
         _loc1_.donateCount = this.donateCount;
         _loc1_.isUsed = this.isUsed;
         _loc1_.resNum = this.resNum;
         _loc1_.isFixed = isFixed;
         return _loc1_;
      }
   }
}

