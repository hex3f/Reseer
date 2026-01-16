package others
{
   import flash.utils.IDataInput;
   
   public class ServerInfo
   {
      
      private var onlineID:uint;
      
      private var userCnt:uint;
      
      private var ip:String;
      
      private var port:uint;
      
      private var friends:uint;
      
      public function ServerInfo(param1:IDataInput)
      {
         super();
         this.onlineID = param1.readUnsignedInt();
         this.userCnt = param1.readUnsignedInt();
         this.ip = param1.readUTFBytes(16);
         this.port = param1.readUnsignedShort();
         this.friends = param1.readUnsignedInt();
      }
      
      public function get OnlineID() : uint
      {
         return this.onlineID;
      }
      
      public function get UserCnt() : uint
      {
         return this.userCnt;
      }
      
      public function get IP() : String
      {
         return this.ip;
      }
      
      public function get Port() : uint
      {
         return this.port;
      }
      
      public function get Friends() : uint
      {
         return this.friends;
      }
   }
}

