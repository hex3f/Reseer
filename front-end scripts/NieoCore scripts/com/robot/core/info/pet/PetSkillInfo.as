package com.robot.core.info.pet
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import flash.utils.IDataInput;
   
   public class PetSkillInfo
   {
      
      private var _id:uint;
      
      public var pp:uint;
      
      public function PetSkillInfo(param1:IDataInput = null)
      {
         super();
         if(param1 != null)
         {
            this._id = param1.readUnsignedInt();
            this.pp = param1.readUnsignedInt();
         }
      }
      
      public function set id(param1:uint) : void
      {
         this._id = param1;
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return SkillXMLInfo.getName(this.id);
      }
      
      public function get maxPP() : uint
      {
         return SkillXMLInfo.getPP(this.id);
      }
      
      public function get damage() : uint
      {
         return SkillXMLInfo.getDamage(this.id);
      }
   }
}

