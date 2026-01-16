package others
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class LoginMSInfo
   {
      
      private static var _session:ByteArray;
      
      private var _roleCreate:uint;
      
      public function LoginMSInfo(param1:IDataInput)
      {
         super();
         if(param1 != null)
         {
            _session = new ByteArray();
            param1.readBytes(_session,0,16);
            this._roleCreate = param1.readUnsignedInt();
         }
      }
      
      public static function get session() : ByteArray
      {
         return _session;
      }
      
      public static function set session(param1:ByteArray) : void
      {
         _session = param1;
      }
      
      public function set roleCreate(param1:uint) : void
      {
         this._roleCreate = param1;
      }
      
      public function get roleCreate() : uint
      {
         return this._roleCreate;
      }
   }
}

