package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.relation.OnLineInfo;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.taomee.events.SocketEvent;
   
   public class UserInfoManager
   {
      
      public function UserInfoManager()
      {
         super();
      }
      
      public static function getInfo(param1:uint, param2:Function) : void
      {
         var id:uint = param1;
         var event:Function = param2;
         if(id == 0)
         {
            event(new UserInfo());
            return;
         }
         SocketConnection.addCmdListener(CommandID.GET_SIM_USERINFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_SIM_USERINFO,arguments.callee);
            var _loc3_:UserInfo = new UserInfo();
            UserInfo.setForSimpleInfo(_loc3_,param1.data as IDataInput);
            event(_loc3_);
            if(RelationManager.isFriend(_loc3_.userID) || RelationManager.isBlack(_loc3_.userID))
            {
               RelationManager.upDateInfoForSimpleInfo(_loc3_);
            }
         });
         SocketConnection.send(CommandID.GET_SIM_USERINFO,id);
      }
      
      public static function upDateSimpleInfo(param1:UserInfo, param2:Function = null) : void
      {
         var info:UserInfo = param1;
         var event:Function = param2;
         if(info.userID == 0)
         {
            if(event != null)
            {
               event();
            }
            return;
         }
         SocketConnection.addCmdListener(CommandID.GET_SIM_USERINFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_SIM_USERINFO,arguments.callee);
            UserInfo.setForSimpleInfo(info,param1.data as IDataInput);
            if(event != null)
            {
               event();
            }
         });
         SocketConnection.send(CommandID.GET_SIM_USERINFO,info.userID);
      }
      
      public static function upDateMoreInfo(param1:UserInfo, param2:Function = null) : void
      {
         var info:UserInfo = param1;
         var event:Function = param2;
         if(info.userID == 0)
         {
            if(event != null)
            {
               event();
            }
            return;
         }
         SocketConnection.addCmdListener(CommandID.GET_MORE_USERINFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_MORE_USERINFO,arguments.callee);
            UserInfo.setForMoreInfo(info,param1.data as IDataInput);
            if(event != null)
            {
               event();
            }
         });
         SocketConnection.send(CommandID.GET_MORE_USERINFO,info.userID);
      }
      
      public static function seeOnLine(param1:Array, param2:Function) : void
      {
         var byd:ByteArray = null;
         var i:int = 0;
         var arr:Array = null;
         var ids:Array = param1;
         var event:Function = param2;
         arr = null;
         arr = [];
         var len:int = int(ids.length);
         if(len == 0)
         {
            event(arr);
            return;
         }
         byd = new ByteArray();
         i = 0;
         while(i < len)
         {
            byd.writeUnsignedInt(ids[i]);
            i++;
         }
         SocketConnection.addCmdListener(CommandID.SEE_ONLINE,function(param1:SocketEvent):void
         {
            var _loc3_:ByteArray = param1.data as ByteArray;
            var _loc4_:uint = _loc3_.readUnsignedInt();
            var _loc5_:int = 0;
            while(_loc5_ < _loc4_)
            {
               arr.push(new OnLineInfo(_loc3_));
               _loc5_++;
            }
            event(arr);
            SocketConnection.removeCmdListener(CommandID.SEE_ONLINE,arguments.callee);
         });
         SocketConnection.send(CommandID.SEE_ONLINE,len,byd);
      }
   }
}

