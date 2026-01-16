package org.taomee.tmf
{
   import flash.utils.Dictionary;
   
   public class TMF
   {
      
      private static var dataDic:Dictionary = new Dictionary();
      
      public function TMF()
      {
         super();
      }
      
      public static function getClass(param1:uint) : Class
      {
         if(dataDic[param1] == null)
         {
            return TmfByteArray;
         }
         return dataDic[param1];
      }
      
      public static function removeClass(param1:uint) : void
      {
         delete dataDic[param1];
      }
      
      public static function registerClass(param1:uint, param2:Class) : void
      {
         dataDic[param1] = param2;
      }
   }
}

