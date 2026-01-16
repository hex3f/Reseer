package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class VipCmdListener extends BaseBeanController
   {
      
      public static const BE_VIP:String = "beVip";
      
      public static const FIRST_VIP:String = "firstVip";
      
      public function VipCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.VIP_CO,this.onChange);
         finish();
      }
      
      private function onAlert(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:String = _loc2_.readUTF();
         Alarm.show(_loc3_);
      }
      
      private function onChange(param1:SocketEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:NonoInfo = null;
         var _loc4_:ByteArray = param1.data as ByteArray;
         var _loc5_:uint = _loc4_.readUnsignedInt();
         var _loc6_:uint = _loc4_.readUnsignedInt();
         var _loc7_:uint = _loc4_.readUnsignedInt();
         var _loc8_:uint = _loc4_.readUnsignedInt();
         if(MainManager.actorID == _loc5_)
         {
            MainManager.actorInfo.autoCharge = _loc7_;
            MainManager.actorInfo.vipEndTime = _loc8_;
            MainManager.actorInfo.vip = _loc6_;
            if(_loc6_ == 1)
            {
               EventManager.dispatchEvent(new Event(FIRST_VIP));
            }
            else if(_loc6_ == 2)
            {
               MainManager.actorInfo.viped = 1;
               MainManager.actorInfo.superNono = true;
               EventManager.dispatchEvent(new Event(BE_VIP));
            }
            else if(_loc6_ == 0)
            {
               if(MainManager.actorInfo.superNono)
               {
                  MainManager.actorInfo.superNono = false;
                  if(Boolean(NonoManager.info))
                  {
                     NonoManager.info.superNono = false;
                     MainManager.actorModel.hideNono();
                     MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
                  }
               }
            }
         }
         else if(_loc6_ == 2)
         {
            _loc2_ = UserManager.getUserModel(_loc5_);
            if(Boolean(_loc2_))
            {
               _loc2_.info.superNono = true;
               if(Boolean(_loc2_.nono))
               {
                  _loc3_ = _loc2_.nono.info;
                  _loc3_.superNono = true;
                  _loc2_.hideNono();
                  _loc2_.showNono(_loc3_);
               }
            }
         }
      }
   }
}

