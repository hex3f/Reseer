package com.robot.core.info.item
{
   import com.robot.core.config.xml.DoodleXMLInfo;
   import flash.utils.IDataInput;
   
   public class DoodleInfo
   {
      
      public var userID:uint;
      
      public var id:uint;
      
      public var color:uint;
      
      public var texture:uint;
      
      public var URL:String;
      
      public var preURL:String;
      
      public var price:uint;
      
      public var coins:uint;
      
      public function DoodleInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this.userID = param1.readUnsignedInt();
            this.color = param1.readUnsignedInt();
            this.texture = param1.readUnsignedInt();
            this.coins = param1.readUnsignedInt();
            this.URL = DoodleXMLInfo.getSwfURL(this.texture);
            this.preURL = DoodleXMLInfo.getPrevURL(this.texture);
         }
      }
   }
}

