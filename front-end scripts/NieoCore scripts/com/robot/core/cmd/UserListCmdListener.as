package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.aticon.FlyAction;
   import com.robot.core.aticon.WalkAction;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.manager.map.MapType;
   import com.robot.core.mode.PeopleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.teamPK.TeamPKManager;
   import com.robot.core.teamPK.shotActive.PKInteractiveAction;
   import com.robot.core.utils.Direction;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class UserListCmdListener extends BaseBeanController
   {
      
      public static var superList:Array = [];
      
      public function UserListCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.LIST_MAP_PLAYER,this.onUserList);
         finish();
      }
      
      private function onUserList(param1:SocketEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:PeopleModel = null;
         var _loc4_:ByteArray = param1.data as ByteArray;
         _loc4_.position = 0;
         var _loc5_:uint = _loc4_.readUnsignedInt();
         superList = [];
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc2_ = new UserInfo();
            UserInfo.setForPeoleInfo(_loc2_,_loc4_);
            _loc2_.serverID = MainManager.serverID;
            if(_loc2_.userID != MainManager.actorInfo.userID)
            {
               _loc3_ = new PeopleModel(_loc2_);
               if(_loc2_.actionType == 0)
               {
                  _loc3_.walk = new WalkAction();
               }
               else
               {
                  _loc3_.walk = new FlyAction(_loc3_);
               }
               MapManager.currentMap.addUser(_loc3_);
               if(MainManager.actorInfo.mapType == MapType.PK_TYPE)
               {
                  if(_loc2_.teamInfo.id != MainManager.actorInfo.mapID)
                  {
                     _loc3_.additiveInfo.info = TeamPKManager.AWAY;
                  }
                  else
                  {
                     _loc3_.additiveInfo.info = TeamPKManager.HOME;
                  }
                  _loc3_.interactiveAction = new PKInteractiveAction(_loc3_);
               }
            }
            else if(Boolean(MainManager.actorModel.nono))
            {
               MainManager.actorModel.nono.direction = Direction.DOWN;
            }
            if(_loc2_.teamInfo.coreCount >= 10 && _loc2_.teamInfo.isShow)
            {
               superList.push(_loc2_.userID);
            }
            _loc6_++;
         }
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.FILTER_SUPER_TEAM));
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.CREATED_MAP_USER));
      }
   }
}

