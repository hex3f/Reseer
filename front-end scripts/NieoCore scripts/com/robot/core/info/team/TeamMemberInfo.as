package com.robot.core.info.team
{
   import com.robot.core.info.UserInfo;
   import flash.utils.IDataInput;
   
   public class TeamMemberInfo extends UserInfo
   {
      
      public var priv:uint;
      
      public var contribute:uint;
      
      public function TeamMemberInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            userID = param1.readUnsignedInt();
            this.priv = param1.readUnsignedInt();
            this.contribute = param1.readUnsignedInt();
         }
      }
   }
}

