package com.robot.core.teamPK
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class TeamInfoPanel
   {
      
      private var _teaminfo_panel:MovieClip;
      
      private var _homeScore_txt:TextField;
      
      private var _awayScore_txt:TextField;
      
      private var _time_txt:TextField;
      
      public function TeamInfoPanel()
      {
         super();
      }
      
      public function setup() : void
      {
         this._teaminfo_panel = ShotBehaviorManager.getMovieClip("TeamPkInfoPanel");
         this._homeScore_txt = this._teaminfo_panel["homeScore_txt"];
         this._awayScore_txt = this._teaminfo_panel["awayScore_txt"];
         this._time_txt = this._teaminfo_panel["time_txt"];
         this._teaminfo_panel.x = (MainManager.getStage().stageWidth - this._teaminfo_panel.width) / 2;
         this._teaminfo_panel.y = 5;
         LevelManager.topLevel.addChild(this._teaminfo_panel);
      }
      
      public function setHomeScore(param1:uint) : void
      {
         this._homeScore_txt.text = String(param1);
      }
      
      public function setAwayScore(param1:uint) : void
      {
         this._awayScore_txt.text = String(param1);
      }
      
      public function setTime(param1:uint) : void
      {
         this._time_txt.text = String(param1) + "分钟";
      }
      
      public function destroy() : void
      {
         LevelManager.topLevel.removeChild(this._teaminfo_panel);
         this._teaminfo_panel = null;
         this._homeScore_txt = null;
         this._awayScore_txt = null;
         this._time_txt = null;
      }
   }
}

