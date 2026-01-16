package com.robot.core.info.item
{
   public class ClothData
   {
      
      private var xml:XML;
      
      public function ClothData(param1:XML)
      {
         super();
         this.xml = param1;
      }
      
      public function get price() : uint
      {
         return this.xml.@Price;
      }
      
      public function get type() : String
      {
         return this.xml.@type;
      }
      
      public function get id() : int
      {
         return int(this.xml.@ID);
      }
      
      public function get name() : String
      {
         return this.xml.@Name;
      }
      
      public function getUrl(param1:uint = 0) : String
      {
         if(param1 == 0 || param1 == 1)
         {
            return XML(this.xml.parent()).@url + this.id.toString() + ".swf";
         }
         return XML(this.xml.parent()).@url + this.id.toString() + "_" + param1 + ".swf";
      }
      
      public function getIconUrl(param1:uint = 0) : String
      {
         return this.getUrl(param1).replace(/swf\//,"icon/");
      }
      
      public function getPrevUrl(param1:uint = 0) : String
      {
         return this.getUrl(param1).replace(/swf\//,"prev/");
      }
      
      public function get actionDir() : int
      {
         if(String(this.xml.@actionDir) == "")
         {
            return -1;
         }
         return int(this.xml.@actionDir);
      }
      
      public function get repairPrice() : uint
      {
         return uint(this.xml.@RepairPrice);
      }
   }
}

