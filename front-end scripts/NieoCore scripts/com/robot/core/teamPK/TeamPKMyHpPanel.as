package com.robot.core.teamPK
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class TeamPKMyHpPanel extends Sprite
   {
      
      private var _mySt_panel:MovieClip;
      
      private var _myNj_mc:MovieClip;
      
      private var _name_txt:TextField;
      
      private var _myNj_txt:TextField;
      
      public function TeamPKMyHpPanel()
      {
         super();
      }
      
      public function setup() : void
      {
         this._mySt_panel = ShotBehaviorManager.getMovieClip("TeamPKMyPanel");
         this._myNj_mc = this._mySt_panel["myNj_mc"];
         this._myNj_txt = this._mySt_panel["myNj_txt"];
         this._name_txt = this._mySt_panel["name_txt"];
         this._name_txt.text = MainManager.actorInfo.nick;
         this._myNj_mc.gotoAndStop(1);
         this._mySt_panel.x = 5;
         this._mySt_panel.y = 5;
      }
      
      public function init() : void
      {
         this._myNj_txt.text = String(TeamPKManager.myHp) + "/" + String(TeamPKManager.myMaxHp);
         var _loc1_:uint = 16 - Math.ceil(Math.floor(TeamPKManager.myHp / TeamPKManager.myMaxHp * 10) * 1.5);
         this._myNj_mc.gotoAndStop(_loc1_);
      }
      
      public function show() : void
      {
         LevelManager.topLevel.addChild(this._mySt_panel);
      }
      
      public function hide() : void
      {
         LevelManager.topLevel.removeChild(this._mySt_panel);
      }
      
      public function destroy() : void
      {
         this.hide();
         this._mySt_panel = null;
         this._myNj_mc = null;
         this._myNj_txt = null;
         this._name_txt = null;
      }
   }
}

