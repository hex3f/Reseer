package com.robot.core.info.mail
{
   import flash.utils.IDataInput;
   
   public class SingleMailInfo
   {
      
      private var _id:uint;
      
      public var template:uint;
      
      public var time:uint;
      
      public var fromID:uint;
      
      public var fromNick:String;
      
      private var _flag:uint;
      
      public var content:String;
      
      public function SingleMailInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this._id = param1.readUnsignedInt();
            this.template = param1.readUnsignedInt();
            this.time = param1.readUnsignedInt();
            this.fromID = param1.readUnsignedInt();
            this.fromNick = param1.readUTFBytes(16);
            this._flag = param1.readUnsignedInt();
         }
      }
      
      public function get readed() : Boolean
      {
         return this._flag == 1;
      }
      
      public function set readed(param1:Boolean) : void
      {
         if(param1)
         {
            this._flag = 1;
         }
         else
         {
            this._flag = 0;
         }
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get date() : Date
      {
         var _loc1_:Date = new Date();
         _loc1_.setTime(this.time * 1000);
         return _loc1_;
      }
   }
}

