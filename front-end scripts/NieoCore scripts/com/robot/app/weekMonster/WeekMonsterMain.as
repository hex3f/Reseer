package com.robot.app.weekMonster
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class WeekMonsterMain
   {
      
      private static var _loader:MCLoader;
      
      private static var mainPanel:MovieClip;
      
      private static var closeBtn:SimpleButton;
      
      private static var app:ApplicationDomain;
      
      private static var starBtn:SimpleButton;
      
      private static var PATH:String = "resource/module/newMonster/weekMonster.swf";
      
      public function WeekMonsterMain()
      {
         super();
      }
      
      public static function loadMonster() : void
      {
         if(!mainPanel)
         {
            _loader = new MCLoader(PATH,LevelManager.topLevel,1,"正在加载本周新精灵");
            _loader.addEventListener(MCLoadEvent.SUCCESS,onComplete);
            _loader.doLoad();
         }
         else
         {
            DisplayUtil.align(mainPanel,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(mainPanel);
            closeBtn = mainPanel["exitBtn"];
            closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
         }
      }
      
      private static function onComplete(param1:MCLoadEvent) : void
      {
         app = param1.getApplicationDomain();
         _loader.removeEventListener(MCLoadEvent.SUCCESS,onComplete);
         mainPanel = new (app.getDefinition("mainPanel") as Class)() as MovieClip;
         DisplayUtil.align(mainPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mainPanel);
         closeBtn = mainPanel["exitBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function changeMap(param1:MouseEvent) : void
      {
         closeHandler(null);
         if(mainPanel.currentFrame == 1)
         {
            MapManager.changeMap(106);
         }
      }
      
      private static function changeMap2(param1:MouseEvent) : void
      {
         closeHandler(null);
         MapManager.changeMap(41);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mainPanel,false);
         LevelManager.openMouseEvent();
         closeBtn.removeEventListener(MouseEvent.CLICK,closeHandler);
         closeBtn = null;
      }
   }
}

