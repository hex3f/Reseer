package com.robot.app.spt
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.AppModel;
   import flash.display.MovieClip;
   
   public class SptChannelController
   {
      
      private static var _sptApp:AppModel;
      
      private static var _m_2:MovieClip;
      
      private static var _id:uint;
      
      public function SptChannelController()
      {
         super();
      }
      
      public static function changeMap(param1:uint) : void
      {
         MainManager.actorModel.visible = false;
         LevelManager.closeMouseEvent();
         if(Boolean(_sptApp))
         {
            _sptApp.destroy();
         }
         _id = param1;
         _m_2.gotoAndPlay(2);
         _m_2.addFrameScript(_m_2.totalFrames - 1,end2);
      }
      
      private static function end2() : void
      {
         LevelManager.openMouseEvent();
         _m_2.gotoAndStop(_m_2.totalFrames - 1);
         _m_2.addFrameScript(_m_2.totalFrames - 1,null);
         MapManager.changeMap(_id);
         MainManager.actorModel.visible = true;
      }
      
      public static function initMC(param1:MovieClip) : void
      {
         _m_2 = param1;
      }
      
      public static function show() : void
      {
         showSptPanel();
      }
      
      private static function showSptPanel() : void
      {
         if(!_sptApp)
         {
            _sptApp = new AppModel(ClientConfig.getAppModule("SptChannelPanel"),"正在打开SPT通道");
            _sptApp.setup();
         }
         _sptApp.init(PioneerTaskModel.infoA);
         _sptApp.show();
      }
   }
}

