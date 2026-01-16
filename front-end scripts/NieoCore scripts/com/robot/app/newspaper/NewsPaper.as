package com.robot.app.newspaper
{
   import com.robot.app.task.books.TimesNewPanel;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.controller.SaveUserInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class NewsPaper extends BaseBeanController
   {
      
      public static var timeIcon:Sprite;
      
      private static var newsTipMC:MovieClip;
      
      public function NewsPaper()
      {
         super();
      }
      
      override public function start() : void
      {
         timeIcon = UIManager.getSprite("news_Icon");
         timeIcon.x = 24;
         timeIcon.y = 20;
         (timeIcon["ball"] as MovieClip).visible = false;
         (timeIcon["ball"] as MovieClip).stop();
         (timeIcon["ball"] as MovieClip).mouseEnabled = false;
         (timeIcon["ball"] as MovieClip).mouseChildren = false;
         var _loc1_:SimpleButton = timeIcon["newsBtn"] as SimpleButton;
         _loc1_.addEventListener(MouseEvent.CLICK,this.showNewsPanel);
         LevelManager.iconLevel.addChild(timeIcon);
         ToolTipManager.add(timeIcon,"航行日志");
         newsTipMC = timeIcon["newsTipMC"];
         newsTipMC.mouseChildren = false;
         newsTipMC.mouseEnabled = false;
         newsTipMC.visible = false;
         newsTipMC.stop();
         var _loc2_:Object = SaveUserInfo.getNewsVersion();
         if(_loc2_ && _loc2_.id == MainManager.actorInfo.userID && _loc2_.version == ClientConfig.newsVersion)
         {
            newsTipMC.visible = false;
         }
         else
         {
            newsTipMC.visible = true;
            newsTipMC.play();
         }
         finish();
      }
      
      private function showNewsPanel(param1:Event) : void
      {
         (timeIcon["ball"] as MovieClip).visible = false;
         newsTipMC.visible = false;
         newsTipMC.stop();
         SaveUserInfo.saveNewsSO();
         TimesNewPanel.loadPanel();
      }
   }
}

