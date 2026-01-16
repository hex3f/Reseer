package org.taomee.tmf
{
   import flash.utils.IDataInput;
   import org.taomee.net.SocketVersion;
   
   public class HeadInfo
   {
      
      private var _version:String;
      
      private var _userID:uint;
      
      private var _error:uint;
      
      private var _cmdID:uint;
      
      private var _result:int;
      
      public function HeadInfo(param1:IDataInput, param2:String)
      {
         super();
         this._version = param1.readUTFBytes(1);
         this._cmdID = param1.readUnsignedInt();
         this._userID = param1.readUnsignedInt();
         this._result = param1.readInt();
         this._version = param2;
         if(this._version == SocketVersion.SV_2)
         {
            this._error = param1.readUnsignedInt();
         }
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get error() : uint
      {
         return this._error;
      }
      
      public function get cmdID() : uint
      {
         return this._cmdID;
      }
      
      public function get result() : int
      {
         return this._result;
      }
      
      public function get version() : String
      {
         return this._version;
      }
   }
}

