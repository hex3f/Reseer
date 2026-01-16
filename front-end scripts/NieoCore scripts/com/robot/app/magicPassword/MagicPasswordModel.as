package com.robot.app.magicPassword
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class MagicPasswordModel
   {
      
      private static var gift_a:Array;
      
      private static const MAX:int = 32;
      
      public function MagicPasswordModel()
      {
         super();
      }
      
      public static function send(param1:String) : void
      {
         SocketConnection.addCmdListener(CommandID.GET_GIFT_COMPLETE,onSendCompleteHandler);
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_.length > MAX)
            {
               break;
            }
            _loc2_.writeUTFBytes(param1.charAt(_loc4_));
            _loc4_++;
         }
         SocketConnection.send(CommandID.GET_GIFT_COMPLETE,_loc2_);
      }
      
      private static function onSendCompleteHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GET_GIFT_COMPLETE,onSendCompleteHandler);
         var _loc2_:GiftItemInfo = param1.data as GiftItemInfo;
         gift_a = _loc2_.giftList;
         if(gift_a.length > 0)
         {
            search(gift_a);
         }
      }
      
      public static function get list() : Array
      {
         return gift_a;
      }
      
      private static function search(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = ItemXMLInfo.getName(param1[_loc4_]);
            _loc3_ += _loc2_ + ",";
            _loc4_++;
         }
         Alarm.show("兑换成功," + _loc3_ + "已经放入你的储存箱,快去看看吧!");
      }
   }
}

