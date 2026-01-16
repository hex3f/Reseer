package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.info.transform.TransformInfo;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.TransformSkeleton;
   import org.taomee.events.SocketEvent;
   
   public class TransformCmdListener extends BaseBeanController
   {
      
      public function TransformCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.PEOPLE_TRANSFROM,this.onTransform);
         finish();
      }
      
      private function onTransform(param1:SocketEvent) : void
      {
         var _loc2_:TransformSkeleton = null;
         var _loc3_:TransformInfo = param1.data as TransformInfo;
         var _loc4_:BasePeoleModel = UserManager.getUserModel(_loc3_.userID);
         if(Boolean(_loc4_))
         {
            _loc4_.stop();
            _loc4_.info.changeShape = _loc3_.suitID;
            if(_loc3_.suitID == 0)
            {
               _loc2_ = _loc4_.skeleton as TransformSkeleton;
               if(Boolean(_loc2_))
               {
                  _loc2_.untransform();
               }
            }
            else
            {
               _loc4_.skeleton = new TransformSkeleton();
            }
         }
      }
   }
}

