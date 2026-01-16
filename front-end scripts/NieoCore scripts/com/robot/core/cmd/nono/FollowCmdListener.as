package com.robot.core.cmd.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.aticon.PeculiarAction;
   import com.robot.core.aticon.WalkAction;
   import com.robot.core.event.NonoEvent;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class FollowCmdListener extends BaseBeanController
   {
      
      public function FollowCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_FOLLOW_OR_HOOM,this.onChanged);
         finish();
      }
      
      private function onChanged(param1:SocketEvent) : void
      {
         var _loc2_:NonoInfo = null;
         var _loc3_:BasePeoleModel = null;
         var _loc4_:ByteArray = param1.data as ByteArray;
         var _loc5_:uint = _loc4_.readUnsignedInt();
         var _loc6_:uint = _loc4_.readUnsignedInt();
         var _loc7_:Boolean = Boolean(_loc4_.readUnsignedInt());
         if(Boolean(NonoManager.info))
         {
            if(NonoManager.info.userID == _loc5_)
            {
               NonoManager.info.state[1] = _loc7_;
            }
         }
         if(_loc7_)
         {
            _loc2_ = new NonoInfo();
            _loc2_.userID = _loc5_;
            _loc2_.superStage = _loc6_;
            _loc2_.nick = _loc4_.readUTFBytes(16);
            _loc2_.color = _loc4_.readUnsignedInt();
            _loc2_.power = _loc4_.readUnsignedInt() / 1000;
            if(MainManager.actorID == _loc5_)
            {
               if(Boolean(NonoManager.info))
               {
                  NonoManager.info.power = _loc2_.power;
                  _loc2_ = NonoManager.info;
               }
               else
               {
                  _loc2_.superNono = MainManager.actorInfo.superNono;
                  NonoManager.info = _loc2_;
               }
            }
            else
            {
               _loc3_ = UserManager.getUserModel(_loc5_);
               if(Boolean(_loc3_))
               {
                  _loc2_.superNono = _loc3_.info.superNono;
               }
            }
            UserManager.dispatchAction(_loc5_,PeopleActionEvent.NONO_FOLLOW,_loc2_);
            NonoManager.dispatchEvent(new NonoEvent(NonoEvent.FOLLOW,_loc2_));
         }
         else
         {
            UserManager.dispatchAction(_loc5_,PeopleActionEvent.NONO_HOOM,_loc7_);
            NonoManager.dispatchEvent(new NonoEvent(NonoEvent.HOOM,null));
            if(MainManager.actorInfo.actionType != 0)
            {
               MainManager.actorModel.walk = new WalkAction();
               MainManager.actorModel.clickMc.y = -50;
               MainManager.actorInfo.nonoState[1] = false;
               new PeculiarAction().standUp(MainManager.actorModel.skeleton as EmptySkeletonStrategy);
               MainManager.actorInfo.actionType = 0;
            }
         }
      }
   }
}

