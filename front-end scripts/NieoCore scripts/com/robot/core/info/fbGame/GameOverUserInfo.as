package com.robot.core.info.fbGame
{
   import flash.geom.Point;
   import flash.utils.IDataInput;
   
   public class GameOverUserInfo
   {
      
      public var id:uint;
      
      public var pos:Point;
      
      public function GameOverUserInfo(param1:IDataInput)
      {
         super();
         this.id = param1.readUnsignedInt();
         this.pos = new Point(param1.readUnsignedInt(),param1.readUnsignedInt());
      }
   }
}

