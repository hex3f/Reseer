package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class SystemMsgInfo
   {
      
      public var isNewYear:Boolean = false;
      
      public var npc:uint;
      
      public var msgTime:uint;
      
      private var msgLen:uint;
      
      public var msg:String;
      
      public var type:uint;
      
      public function SystemMsgInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this.type = param1.readShort();
            this.npc = param1.readShort();
            this.msgTime = param1.readUnsignedInt();
            this.msgLen = param1.readUnsignedInt();
            this.msg = param1.readUTFBytes(this.msgLen);
         }
      }
   }
}

