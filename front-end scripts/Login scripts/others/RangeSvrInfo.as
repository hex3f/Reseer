package others
{
   import flash.utils.IDataInput;
   
   public class RangeSvrInfo
   {
      
      private var onlineCnt:uint;
      
      private var serverList:Array;
      
      public function RangeSvrInfo(param1:IDataInput)
      {
         super();
         this.onlineCnt = param1.readUnsignedInt();
         this.serverList = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.onlineCnt)
         {
            this.serverList.push(new ServerInfo(param1));
            _loc2_++;
         }
      }
      
      public function get OnlineCnt() : uint
      {
         return this.onlineCnt;
      }
      
      public function get SvrList() : Array
      {
         return this.serverList;
      }
   }
}

