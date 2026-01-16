package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamChartsInfo
   {
      
      private var list:Array = [];
      
      public function TeamChartsInfo(param1:IDataInput)
      {
         super();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this.list.push(new TeamChartsItemInfo(param1));
            _loc3_++;
         }
      }
      
      public function get infoList() : Array
      {
         return this.list;
      }
   }
}

