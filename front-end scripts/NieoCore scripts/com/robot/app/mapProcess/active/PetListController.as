package com.robot.app.mapProcess.active
{
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.info.*;
   import com.robot.core.manager.*;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import flash.display.SimpleButton;
   import flash.events.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   
   public class PetListController
   {
      
      private var hotBtn:SimpleButton;
      
      private var scoreBtn:SimpleButton;
      
      private var scorePanel:AppModel;
      
      private var hotPanel:AppModel;
      
      public function PetListController(param1:SimpleButton, param2:SimpleButton)
      {
         var scoreBtn:SimpleButton = param1;
         var hotBtn:SimpleButton = param2;
         super();
         this.scoreBtn = scoreBtn;
         this.hotBtn = hotBtn;
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,arguments.callee);
            var _loc3_:Date = (param1.data as SystemTimeInfo).date;
            if(_loc3_.getFullYear() == 2010)
            {
               addPanelEvent();
            }
            else
            {
               addNormalEvent();
            }
         });
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private function addNormalEvent() : void
      {
         ToolTipManager.add(this.scoreBtn,"精灵战绩榜");
         ToolTipManager.add(this.hotBtn,"精灵人气榜");
         this.scoreBtn.addEventListener(MouseEvent.CLICK,this.showTip);
         this.hotBtn.addEventListener(MouseEvent.CLICK,this.showTip);
      }
      
      private function showTip(param1:MouseEvent) : void
      {
         Alarm.show("精灵战绩和人气榜将在1月1日开始公布");
      }
      
      private function addPanelEvent() : void
      {
         this.scoreBtn.addEventListener(MouseEvent.CLICK,this.showScore);
         this.hotBtn.addEventListener(MouseEvent.CLICK,this.showHot);
      }
      
      public function destroy() : void
      {
         ToolTipManager.remove(this.scoreBtn);
         ToolTipManager.remove(this.hotBtn);
         this.scoreBtn.removeEventListener(MouseEvent.CLICK,this.showTip);
         this.hotBtn.removeEventListener(MouseEvent.CLICK,this.showTip);
         this.scoreBtn.removeEventListener(MouseEvent.CLICK,this.showScore);
         this.hotBtn.removeEventListener(MouseEvent.CLICK,this.showHot);
         if(Boolean(this.scorePanel))
         {
            this.scorePanel.destroy();
            this.scorePanel = null;
         }
         if(Boolean(this.hotPanel))
         {
            this.hotPanel.destroy();
            this.hotPanel = null;
         }
      }
      
      private function showScore(param1:MouseEvent) : void
      {
         if(!this.scorePanel)
         {
            this.scorePanel = ModuleManager.getModule(ClientConfig.getAppModule("IcePetScroeList"),"正在打开精灵战绩榜");
            this.scorePanel.setup();
         }
         this.scorePanel.show();
      }
      
      private function showHot(param1:MouseEvent) : void
      {
         if(!this.hotPanel)
         {
            this.hotPanel = ModuleManager.getModule(ClientConfig.getAppModule("IcePetHotList"),"正在打开精灵人气榜");
            this.hotPanel.setup();
         }
         this.hotPanel.show();
      }
   }
}

