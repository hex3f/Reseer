package com.robot.core.info
{
   import com.robot.core.config.xml.AimatXMLInfo;
   import flash.geom.Point;
   
   public class AimatInfo
   {
      
      public var id:uint;
      
      public var userID:uint;
      
      public var startPos:Point;
      
      public var endPos:Point;
      
      public var speed:Number = 36;
      
      public function AimatInfo(param1:uint, param2:uint, param3:Point = null, param4:Point = null)
      {
         super();
         this.id = param1;
         this.userID = param2;
         this.startPos = param3;
         this.endPos = param4;
         this.speed = AimatXMLInfo.getSpeed(this.id);
      }
      
      public function clone() : AimatInfo
      {
         return new AimatInfo(this.id,this.userID,this.startPos,this.endPos);
      }
   }
}

