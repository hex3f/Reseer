package com.robot.core.teamPK
{
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.teamPK.TeamPKResultInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.manager.UserInfoManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class TeamPKResultPanel extends Sprite
   {
      
      private var _mainUI:MovieClip;
      
      private var _up_mc:MovieClip;
      
      private var _r_mc:MovieClip;
      
      private var _back_bar:MovieClip;
      
      private var _out_btn:SimpleButton;
      
      private var _taobao_mc:MovieClip;
      
      public function TeamPKResultPanel()
      {
         super();
      }
      
      public function setup(param1:TeamPKResultInfo) : void
      {
         TeamPKManager.removeIcon();
         this._mainUI = ShotBehaviorManager.getMovieClip("TeamPKResult_panel");
         this._up_mc = this._mainUI["up_mc"];
         this._r_mc = this._mainUI["r_mc"];
         this._back_bar = this._mainUI["back_bar"];
         this._out_btn = this._mainUI["out_btn"];
         this._taobao_mc = this._mainUI["taobao_mc"];
         if(param1.flag == 1)
         {
            this._taobao_mc.visible = false;
         }
         this.setSimpInfo(param1.killPlayer,param1.killBuilding,param1.freezTimes,param1.getBadge,param1.getExp,param1.getCoins);
         MainManager.actorInfo.fightBadge += param1.getBadge;
         this.setMcRe(param1.result);
         this.setMvp(param1.mvpUID);
         this._out_btn.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this._mainUI.x = (MainManager.getStage().stageWidth - this._mainUI.width) / 2;
         this._mainUI.y = (MainManager.getStage().stageHeight - this._mainUI.height) / 2;
         LevelManager.topLevel.addChild(this._mainUI);
         LevelManager.closeMouseEvent();
      }
      
      private function destroy() : void
      {
         LevelManager.topLevel.removeChild(this._mainUI);
         LevelManager.openMouseEvent();
         this._mainUI = null;
         this._up_mc = null;
         this._r_mc = null;
         this._back_bar = null;
         this._out_btn.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         this._out_btn = null;
         this._taobao_mc = null;
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.destroy();
         TeamPKManager.outTeamMap();
      }
      
      private function setSimpInfo(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int) : void
      {
         this._mainUI["killSeer_txt"].text = String(param1);
         this._mainUI["killBuilding_txt"].text = String(param2);
         this._mainUI["readyNum_txt"].text = String(param3);
         this._mainUI["score_txt"].text = String(param1 * 25 + param2 * 50);
         this._mainUI["zh_txt"].text = String(param4);
         this._mainUI["allScore_txt"].text = String(param5);
         this._mainUI["allMoney_txt"].text = String(param6);
         MainManager.actorInfo.coins += param6;
         if(TeamPKManager.TEAM == TeamPKManager.HOME)
         {
            this._r_mc.gotoAndStop(1);
         }
         else
         {
            this._r_mc.gotoAndStop(2);
         }
      }
      
      private function setMvp(param1:uint) : void
      {
         var name:String = null;
         var n:uint = param1;
         name = null;
         if(n == 0)
         {
            this._mainUI["name_txt"].text = "没有产生";
            this._mainUI["myNum_txt"].text = "";
            return;
         }
         UserInfoManager.getInfo(n,function(param1:UserInfo):void
         {
            name = param1.nick;
            _mainUI["name_txt"].text = name;
         });
         this._mainUI["myNum_txt"].text = "(" + String(n) + ")";
      }
      
      private function setMcRe(param1:uint) : void
      {
         if(TeamPKManager.TEAM == TeamPKManager.HOME)
         {
            if(param1 == 0)
            {
               this._up_mc.gotoAndStop(2);
               this._back_bar.gotoAndStop(2);
            }
            else if(param1 == 1)
            {
               this._up_mc.gotoAndStop(1);
               this._back_bar.gotoAndStop(1);
            }
            else if(param1 == 2)
            {
               this._up_mc.gotoAndStop(3);
               this._back_bar.gotoAndStop(2);
            }
         }
         else if(param1 == 0)
         {
            this._up_mc.gotoAndStop(1);
            this._back_bar.gotoAndStop(1);
         }
         else
         {
            this._up_mc.gotoAndStop(2);
            this._back_bar.gotoAndStop(2);
         }
      }
   }
}

