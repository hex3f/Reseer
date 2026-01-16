package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.panel.NatureChoosePanel;
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.NatureXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import org.taomee.events.SocketEvent;
   
   public class PetPropClass_300136
   {
      
      private var _info:PetInfo;
      
      private var _nature:uint;
      
      public function PetPropClass_300136(param1:PetPropInfo)
      {
         var info:PetPropInfo = param1;
         super();
         this._info = info.petInfo;
         NatureChoosePanel.show(PetXMLInfo.getName(this._info.id),function(param1:uint):void
         {
            _nature = param1;
            SocketConnection.addCmdListener(CommandID.PET_RESET_NATURE,onReset);
            SocketConnection.send(CommandID.PET_RESET_NATURE,_info.catchTime,_nature,1);
         });
      }
      
      private function onReset(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_RESET_NATURE,this.onReset);
         Alarm.show("<font color=\'#ff0000\'>" + PetXMLInfo.getName(this._info.id) + "</font>的性格已经成功转换为<font color=\'#ff0000\'>" + NatureXMLInfo.getName(this._nature) + "！</font>");
         PetManager.upDate();
      }
   }
}

