package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.AchieveXMLInfo;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.AchieveTitleAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class AchieveTitleCmdListener extends BaseBeanController
   {
      
      public function AchieveTitleCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_ACHIEVETITLE,this.onGetAchieveTitle);
         finish();
      }
      
      private function onGetAchieveTitle(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         AchieveTitleAlert.show(_loc3_,"获得称号" + TextFormatUtil.getRedTxt(AchieveXMLInfo.getTitle(_loc3_)) + ",请打开称号栏查看！");
      }
   }
}

