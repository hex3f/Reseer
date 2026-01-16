package com.robot.app.mapProcess
{
   import com.robot.app.WheelChoice.WheelChoicePanelController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.CommonUI;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MapProcess_405 extends BaseMapProcess
   {
      
      private var panel:AppModel;
      
      private var _panel:AppModel;
      
      private var _moveMC:MovieClip;
      
      private var exMc:MovieClip;
      
      private var _roayleApp:AppModel;
      
      private var expanel:AppModel;
      
      private var _signUpPanel:AppModel;
      
      public function MapProcess_405()
      {
         super();
      }
      
      override protected function init() : void
      {
      }
      
      public function onPetRoayleBtn() : void
      {
         CommonUI.removeYellowArrow(topLevel);
         SocketConnection.send(1022,86053849);
         if(!this._roayleApp)
         {
            this._roayleApp = new AppModel(ClientConfig.getAppModule("PetRoyalePanel"),"加载面板资源");
            this._roayleApp.setup();
         }
         this._roayleApp.show();
      }
      
      private function destroyPetRoayle() : void
      {
         if(Boolean(this._roayleApp))
         {
            this._roayleApp.destroy();
            this._roayleApp = null;
         }
      }
      
      private function onClickExchangeHandler(param1:MouseEvent) : void
      {
         if(!this.expanel)
         {
            this.expanel = new AppModel(ClientConfig.getAppModule("YuanDanExchangePanel"),"正在打开");
            this.expanel.setup();
         }
         this.expanel.show();
      }
      
      public function onSignUpClick() : void
      {
         SocketConnection.send(1022,86053851);
         if(Boolean(MainManager.actorModel.nono))
         {
         }
         if(!this._signUpPanel)
         {
            this._signUpPanel = new AppModel(ClientConfig.getAppModule("ElementSignUpPanel"),"加载报名面板");
            this._signUpPanel.setup();
         }
         this._signUpPanel.show();
      }
      
      private function destroySignUpMC() : void
      {
         if(Boolean(this._signUpPanel))
         {
            this._signUpPanel.destroy();
         }
      }
      
      public function onEnterHandler() : void
      {
         AnimateManager.playMcAnimate(this._moveMC,0,"",function():void
         {
            MapManager.changeMap(108);
         });
      }
      
      public function onFightLadder() : void
      {
         if(!this.panel)
         {
            this.panel = new AppModel(ClientConfig.getAppModule("LadderChoicePanel"),"正在打开战斗阶梯面板");
            this.panel.setup();
         }
         this.panel.show();
      }
      
      public function onFateFightHandler() : void
      {
         WheelChoicePanelController.show();
      }
      
      override public function destroy() : void
      {
         if(Boolean(this.panel))
         {
            this.panel.destroy();
            this.panel = null;
         }
         if(Boolean(this._panel))
         {
            this._panel.destroy();
            this._panel = null;
         }
         this.destroySignUpMC();
         this.destroyPetRoayle();
      }
   }
}

