package com.robot.core.aticon
{
   import com.robot.core.CommandID;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.IActionSprite;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   
   public class ChatAction
   {
      
      private static const MAX:int = 131;
      
      public function ChatAction()
      {
         super();
      }
      
      public function execute(param1:IActionSprite, param2:String, param3:uint = 0, param4:Boolean = true) : void
      {
         var _loc5_:ByteArray = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2 == "")
         {
            return;
         }
         if(param4)
         {
            _loc5_ = new ByteArray();
            _loc6_ = param2.length;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               if(_loc5_.length > MAX)
               {
                  break;
               }
               _loc5_.writeUTFBytes(param2.charAt(_loc7_));
               _loc7_++;
            }
            _loc5_.writeUTFBytes("0");
            SocketConnection.send(CommandID.CHAT,param3,_loc5_.length,_loc5_);
         }
         else
         {
            BasePeoleModel(param1).showBox(param2,5);
         }
      }
   }
}

