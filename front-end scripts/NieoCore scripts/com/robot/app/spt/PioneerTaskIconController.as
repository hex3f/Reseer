package com.robot.app.spt
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.SOManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.SharedObject;
   import org.taomee.manager.ToolTipManager;
   
   public class PioneerTaskIconController
   {
      
      private static var iconMc:MovieClip;
      
      private static var _so:SharedObject;
      
      private static var _panel:AppModel;
      
      public function PioneerTaskIconController()
      {
         super();
      }
      
      public static function createIcon() : void
      {
         PioneerTaskModel.setup();
         iconMc = UIManager.getMovieClip("SPT_Icon");
         ToolTipManager.add(iconMc,"赛尔先锋队任务");
         _so = SOManager.getUser_SPT();
         if(!_so.data.hasOwnProperty("isShow"))
         {
            _so.data["isShow"] = true;
            SOManager.flush(_so);
         }
         iconMc["mc"].visible = false;
         if(iconMc["mc"].visible == false)
         {
            iconMc["mc"].gotoAndStop(1);
         }
         TaskIconManager.addIcon(iconMc);
         iconMc["btn"].addEventListener(MouseEvent.CLICK,onClickHandler);
      }
      
      private static function onClickHandler(param1:MouseEvent) : void
      {
         if(!TasksManager.isComNoviceTask())
         {
            Alarm.show("你还没有做完新船员任务\r快去<font color=\'#ff0000\'>机械室</font>找茜茜吧");
         }
         else
         {
            show();
         }
      }
      
      private static function show() : void
      {
         _so.data["isShow"] = false;
         SOManager.flush(_so);
         iconMc["mc"].visible = false;
         iconMc["mc"].gotoAndStop(1);
         showPanel();
      }
      
      private static function showPanel() : void
      {
         if(!_panel)
         {
            PioneerTaskModel.setup();
            _panel = new AppModel(ClientConfig.getAppModule("SptPanel"),"正在打开");
            _panel.setup();
            _panel.init(PioneerTaskModel.infoA);
         }
         _panel.show();
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(iconMc);
      }
   }
}

