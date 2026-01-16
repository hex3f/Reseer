package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.config.xml.AimatXMLInfo;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class AimatCmdListener extends BaseBeanController
   {
      
      public function AimatCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.AIMAT,this.onAimat);
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onPlayEnd);
         finish();
      }
      
      private function onAimat(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:Object = new Object();
         _loc4_.itemID = _loc2_.readUnsignedInt();
         _loc4_.type = _loc2_.readUnsignedInt();
         _loc4_.pos = new Point(_loc2_.readUnsignedInt(),_loc2_.readUnsignedInt());
         UserManager.dispatchAction(_loc3_,PeopleActionEvent.AIMAT,_loc4_);
      }
      
      private function onPlayEnd(param1:AimatEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:Array = null;
         var _loc4_:AimatInfo = param1.info;
         for each(_loc2_ in UserManager.getUserModelList())
         {
            if(_loc2_.hitTestPoint(_loc4_.endPos.x,_loc4_.endPos.y,true))
            {
               _loc3_ = AimatXMLInfo.getCloths(_loc4_.id);
               SocketConnection.send(CommandID.TRANSFORM_USER,_loc2_.info.userID,uint(_loc3_[0]));
               break;
            }
         }
      }
   }
}

