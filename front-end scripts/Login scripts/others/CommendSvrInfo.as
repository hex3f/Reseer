package others
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class CommendSvrInfo
   {
      
      private var _onlineCnt:uint;
      
      private var _onlineID:uint;
      
      private var _userCnt:uint;
      
      private var _ip:String;
      
      private var _port:uint;
      
      private var _friends:uint;
      
      private var _maxOnlineID:uint;
      
      private var _isVIP:uint;
      
      private var _friendCnt:uint;
      
      private var _friendID:uint;
      
      private var _stamp:uint;
      
      private var svrList:Array;
      
      private var friendList:Array;
      
      private var _friendListByte:ByteArray;
      
      private var _friendData:IDataInput;
      
      public function CommendSvrInfo(param1:IDataInput)
      {
         super();
         this._maxOnlineID = param1.readUnsignedInt();
         this._isVIP = param1.readUnsignedInt();
         this._onlineCnt = param1.readUnsignedInt();
         this.svrList = new Array();
         this.friendList = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this._onlineCnt)
         {
            this.svrList.push(new ServerInfo(param1));
            _loc2_++;
         }
         this._friendData = param1;
      }
      
      public function get friendData() : IDataInput
      {
         return this._friendData;
      }
      
      public function get SvrList() : Array
      {
         return this.svrList;
      }
      
      public function get FriendList() : Array
      {
         return this.friendList;
      }
      
      public function get OnlineCnt() : uint
      {
         return this._onlineCnt;
      }
      
      public function get MaxOnlineID() : uint
      {
         return this._maxOnlineID;
      }
      
      public function get IsVIP() : uint
      {
         return this._isVIP;
      }
      
      public function get FriendCnt() : uint
      {
         return this._friendCnt;
      }
   }
}

