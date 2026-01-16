package org.taomee.net
{
   import org.taomee.ds.HashMap;
   
   public class CmdName
   {
      
      private static var _list:HashMap = new HashMap();
      
      public function CmdName()
      {
         super();
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:String = _list.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_;
         }
         return "---";
      }
      
      public static function addName(param1:uint, param2:String) : void
      {
         _list.add(param1,param2);
      }
   }
}

