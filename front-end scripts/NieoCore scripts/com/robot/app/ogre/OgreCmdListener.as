package com.robot.app.ogre
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class OgreCmdListener extends BaseBeanController
   {
      
      public function OgreCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.MAP_OGRE_LIST,this.onOgreList);
         finish();
      }
      
      private function onOgreList(param1:SocketEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Object = null;
         if(!MapManager.isInMap)
         {
            return;
         }
         var _loc4_:ByteArray = param1.data as ByteArray;
         var _loc5_:Array = [];
         var _loc6_:int = 0;
         while(_loc6_ < 9)
         {
            _loc2_ = _loc4_.readUnsignedInt();
            if(_loc2_ == 133)
            {
               if(!MainManager.actorModel.nono)
               {
                  return;
               }
            }
            if(Boolean(_loc2_))
            {
               OgreController.add(_loc6_,_loc2_);
               _loc5_.push({
                  "_id":_loc2_,
                  "_index":_loc6_
               });
            }
            else
            {
               OgreController.remove(_loc6_);
            }
            _loc6_++;
         }
         if(_loc5_.length > 0)
         {
            _loc3_ = _loc5_[Math.floor(Math.random() * _loc5_.length)];
            AutomaticFightManager.beginFight(_loc3_._index,_loc3_._id);
         }
      }
   }
}

