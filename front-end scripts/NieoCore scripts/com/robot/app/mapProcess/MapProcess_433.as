package com.robot.app.mapProcess
{
   import com.robot.app.panel.TopSelectPanel;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.utils.CommonUI;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_433 extends BaseMapProcess
   {
      
      private var _jxgNPC:MovieClip;
      
      private var _ListWarBtn:MovieClip;
      
      private var _ToWarBtn:MovieClip;
      
      private var _ToWarBtnBeyond:MovieClip;
      
      private var _bookMC:MovieClip;
      
      private var _isPlay:Boolean = false;
      
      private var _mode:uint;
      
      private var _adPanel:MovieClip;
      
      private var _panel:AppModel;
      
      public function MapProcess_433()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:Boolean = false;
         this._jxgNPC = this.depthLevel["jxgNPC"];
         this._jxgNPC.buttonMode = true;
         this._jxgNPC.addEventListener(MouseEvent.CLICK,this.onJHandler);
         this._ListWarBtn = this.conLevel["ListPetTopLevelWarBtn"];
         this._ListWarBtn.buttonMode = true;
         this._ListWarBtn.addEventListener(MouseEvent.CLICK,this.onListWarHandler);
         ToolTipManager.add(this._ListWarBtn,"巅峰之战第九季");
         this._ToWarBtn = this.conLevel["ToTopLevelWarMC"];
         this._ToWarBtn.buttonMode = true;
         this._ToWarBtn.addEventListener(MouseEvent.CLICK,this.onToWarBtnHandler);
         this._ToWarBtn.addEventListener(MouseEvent.ROLL_OVER,this.onBtnOverHandler);
         this._ToWarBtn.addEventListener(MouseEvent.ROLL_OUT,this.onBtnOutHandler);
         ToolTipManager.add(this._ToWarBtn,"巅峰之战积分赛");
         this._ToWarBtnBeyond = this.conLevel["ToTopLevelWarMC_beyond"];
         this._ToWarBtnBeyond.buttonMode = true;
         this._ToWarBtnBeyond.addEventListener(MouseEvent.CLICK,this.onToWarBtnHandler);
         this._ToWarBtnBeyond.addEventListener(MouseEvent.ROLL_OVER,this.onBtnOverHandler);
         this._ToWarBtnBeyond.addEventListener(MouseEvent.ROLL_OUT,this.onBtnOutHandler);
         ToolTipManager.add(this._ToWarBtnBeyond,"巅峰之战积分赛：\r突破模式");
         this._bookMC = topLevel["bookMC"];
         this._bookMC.addEventListener(MouseEvent.CLICK,this.onShowWarPanel);
         ToolTipManager.add(this._bookMC,"巅峰之战物品兑换手册");
      }
      
      private function onJHandler(param1:Event) : void
      {
      }
      
      private function onListWarHandler(param1:MouseEvent) : void
      {
         if(this._adPanel == null)
         {
            this._adPanel = MapLibManager.getMovieClip("ui_pet_top_ad");
            this._adPanel["close"].addEventListener(MouseEvent.CLICK,this.onAdCloseClick);
         }
         LevelManager.appLevel.addChild(this._adPanel);
         DisplayUtil.align(this._adPanel,null,AlignType.MIDDLE_CENTER);
      }
      
      private function onAdCloseClick(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._adPanel);
      }
      
      private function onBtnOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.gotoAndStop(2);
      }
      
      private function onBtnOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.gotoAndStop(1);
      }
      
      private function onShowWarPanel(param1:MouseEvent) : void
      {
         CommonUI.removeYellowArrow(this._bookMC);
         if(!this._panel)
         {
            this._panel = new AppModel(ClientConfig.getAppModule("FightExchangePanel"),"正在加载兑换手册....");
            this._panel.setup();
         }
         this._panel.show();
      }
      
      private function onToWarBtnHandler(param1:MouseEvent) : void
      {
         this._isPlay = false;
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_ == this._ToWarBtn)
         {
            this._mode = TopSelectPanel.NORMAL;
         }
         else
         {
            this._mode = TopSelectPanel.BEYOND;
         }
         this.showTopSelectPanel();
      }
      
      public function onPointClick(param1:MovieClip) : void
      {
         this._isPlay = true;
         var _loc2_:uint = uint(param1.name.split("_")[1]) % 2;
         if(_loc2_ == 0)
         {
            this._mode = TopSelectPanel.NORMAL;
         }
         else
         {
            this._mode = TopSelectPanel.BEYOND;
         }
         this.showTopSelectPanel();
      }
      
      private function showTopSelectPanel() : void
      {
         TopSelectPanel.show(function():void
         {
            TopSelectPanel.mode = _mode;
            TopSelectPanel.isPlay = _isPlay;
         });
      }
      
      override public function destroy() : void
      {
         this._jxgNPC.removeEventListener(MouseEvent.CLICK,this.onJHandler);
         ToolTipManager.remove(this._ListWarBtn);
         this._ListWarBtn.removeEventListener(MouseEvent.CLICK,this.onListWarHandler);
         ToolTipManager.remove(this._ToWarBtn);
         this._ToWarBtn.removeEventListener(MouseEvent.CLICK,this.onToWarBtnHandler);
         this._ToWarBtn.removeEventListener(MouseEvent.ROLL_OVER,this.onBtnOverHandler);
         this._ToWarBtn.removeEventListener(MouseEvent.ROLL_OUT,this.onBtnOutHandler);
         ToolTipManager.remove(this._ToWarBtnBeyond);
         this._ToWarBtnBeyond.removeEventListener(MouseEvent.CLICK,this.onToWarBtnHandler);
         this._ToWarBtnBeyond.removeEventListener(MouseEvent.ROLL_OVER,this.onBtnOverHandler);
         this._ToWarBtnBeyond.removeEventListener(MouseEvent.ROLL_OUT,this.onBtnOutHandler);
         ToolTipManager.remove(this._bookMC);
         this._bookMC.removeEventListener(MouseEvent.CLICK,this.onShowWarPanel);
         if(Boolean(this._adPanel))
         {
            this._adPanel["close"].addEventListener(MouseEvent.CLICK,this.onAdCloseClick);
         }
         if(Boolean(this._panel))
         {
            this._panel.destroy();
            this._panel = null;
         }
         TopSelectPanel.destroy();
         this._ToWarBtn = null;
         this._ToWarBtnBeyond = null;
         this._jxgNPC = null;
      }
   }
}

