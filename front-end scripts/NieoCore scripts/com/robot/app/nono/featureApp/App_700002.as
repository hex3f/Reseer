package com.robot.app.nono.featureApp
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class App_700002
   {
      
      private var _panel:AppModel;
      
      public function App_700002(param1:uint)
      {
         super();
         this.check();
      }
      
      private function formatTimeAuto(param1:Number) : String
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 >= 86400)
         {
            _loc2_ = Math.floor(param1 / 86400);
            _loc3_ = Math.floor(param1 % 86400 / 3600);
            return _loc2_ + "天" + (_loc3_ > 0 ? _loc3_ + "小时" : "");
         }
         if(param1 >= 3600)
         {
            _loc3_ = Math.floor(param1 / 3600);
            _loc4_ = Math.floor(param1 % 3600 / 60);
            return _loc3_ + "小时" + (_loc4_ > 0 ? _loc4_ + "分" : "");
         }
         if(param1 >= 60)
         {
            _loc4_ = Math.floor(param1 / 60);
            _loc5_ = param1 % 60;
            return _loc4_ + "分" + (_loc5_ > 0 ? _loc5_ + "秒" : "");
         }
         return param1 + "秒";
      }
      
      private function check() : void
      {
         if(SocketConnection.hasCmdListener(CommandID.PET_HATCH_GET))
         {
            return;
         }
         SocketConnection.addCmdListener(CommandID.PET_HATCH_GET,function(param1:SocketEvent):void
         {
            var data:ByteArray = null;
            var falg:Boolean = false;
            var leftTime:uint = 0;
            var captmTime:uint = 0;
            var petID:uint = 0;
            var e:SocketEvent = param1;
            petID = 0;
            SocketConnection.removeCmdListener(CommandID.PET_HATCH_GET,arguments.callee);
            data = e.data as ByteArray;
            falg = Boolean(data.readUnsignedInt());
            leftTime = data.readUnsignedInt();
            petID = data.readUnsignedInt();
            captmTime = data.readUnsignedInt();
            if(falg)
            {
               if(leftTime == 0)
               {
                  if(PetManager.length < 6)
                  {
                     PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
                     {
                        PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
                        PetInBagAlert.show(petID,TextFormatUtil.getRedTxt(PetXMLInfo.getName(petID)) + "已经放入你的背包中。");
                     });
                     PetManager.setIn(captmTime,1);
                  }
                  else
                  {
                     PetManager.addStorage(petID,captmTime);
                     PetInStorageAlert.show(petID,TextFormatUtil.getRedTxt(PetXMLInfo.getName(petID)) + "已经放入你的仓库中。");
                  }
               }
               else
               {
                  Alarm.show("分子转化仪中有正在转化的精元,剩余时间:" + formatTimeAuto(leftTime));
               }
            }
            else
            {
               if(_panel == null)
               {
                  _panel = ModuleManager.getModule(ClientConfig.getAppModule("MoleculePanel"),"正在打开分子转化仪面板");
                  _panel.setup();
               }
               _panel.show();
            }
         });
         SocketConnection.send(CommandID.PET_HATCH_GET);
      }
   }
}

