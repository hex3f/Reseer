package com.robot.core.info
{
   import flash.utils.IDataInput;
   import org.taomee.ds.HashMap;
   
   public class MapHotInfo
   {
      
      private var _infos:HashMap;
      
      public function MapHotInfo(param1:IDataInput)
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         super();
         this._infos = new HashMap();
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc5_:Number = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = param1.readUnsignedInt();
            _loc3_ = param1.readUnsignedInt();
            this._infos.add(_loc2_,_loc3_);
            _loc5_++;
         }
      }
      
      public function get infos() : HashMap
      {
         return this._infos;
      }
   }
}

