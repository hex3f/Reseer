package com.robot.app.mapProcess
{
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import org.taomee.manager.*;
   
   public class MapProcess_513 extends BaseMapProcess
   {
      
      private var npc:MovieClip;
      
      private var _shou_mc:MovieClip;
      
      private var _shou_btn:SimpleButton;
      
      private var _mov_mc:MovieClip;
      
      private var _kz_btn:SimpleButton;
      
      private var _pj_mc:MovieClip;
      
      private var _hj_mc:MovieClip;
      
      private var _f4_mc:MovieClip;
      
      private var _npc_lyman:MovieClip;
      
      private var _npc_pt:MovieClip;
      
      private var _npc_shawn:MovieClip;
      
      private var _npc_luoj:MovieClip;
      
      private var _nono_mc:MovieClip;
      
      public function MapProcess_513()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._npc_lyman = conLevel["npc_1"];
         this._npc_pt = conLevel["npc_2"];
         this._npc_shawn = conLevel["npc_3"];
         this._npc_luoj = conLevel["npc_4"];
         this._npc_lyman.visible = false;
         this._npc_pt.visible = false;
         this._npc_luoj.visible = false;
         this._npc_shawn.visible = false;
         this.npc = conLevel["npc"];
         this._mov_mc = animatorLevel["movieMC"];
         this._shou_mc = this._mov_mc["shou_mc"];
         this._f4_mc = this._mov_mc["f4_mc"];
         this._nono_mc = this._mov_mc["nono_mc"];
         this._f4_mc.visible = false;
         this._npc_lyman.buttonMode = true;
         this._npc_pt.buttonMode = true;
         this._npc_luoj.buttonMode = true;
         this._npc_shawn.buttonMode = true;
         this._shou_btn = btnLevel["shou_btn"];
         this._kz_btn = btnLevel["kz_btn"];
         ToolTipManager.add(this._shou_btn,"能量屏障器");
         ToolTipManager.add(this._kz_btn,"启动控制台");
         this._shou_btn.visible = false;
         this._kz_btn.visible = false;
         this._pj_mc = this._mov_mc["pj_mc"];
         this._hj_mc = conLevel["hj_mc"];
         this._pj_mc.visible = false;
         this._hj_mc.visible = false;
         this._hj_mc.buttonMode = true;
      }
      
      private function showFun() : void
      {
         this._npc_lyman.visible = true;
         this._npc_pt.visible = true;
         this._npc_luoj.visible = true;
         this._npc_shawn.visible = true;
         this._f4_mc.visible = true;
      }
      
      private function removeNpc() : void
      {
         this._npc_lyman.visible = false;
         this._npc_pt.visible = false;
         this._npc_luoj.visible = false;
         this._npc_shawn.visible = false;
         this._f4_mc.visible = false;
         this._pj_mc.visible = false;
         this._hj_mc.visible = false;
         this.npc.visible = false;
      }
      
      override public function destroy() : void
      {
         LevelManager.showMapLevel();
         this.npc = null;
      }
   }
}

