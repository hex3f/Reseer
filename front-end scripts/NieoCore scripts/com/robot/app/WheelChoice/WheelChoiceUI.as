package com.robot.app.WheelChoice
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.*;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.*;
   import flash.events.*;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.*;
   
   public class WheelChoiceUI extends Sprite
   {
      
      private var _mainUI:MovieClip;
      
      private var app:ApplicationDomain;
      
      private var _closeBtn:SimpleButton;
      
      private var _highLvArr:Array = [0,0,0];
      
      private var _surplusNumArr:Array = [0,0,0];
      
      public function WheelChoiceUI()
      {
         super();
      }
      
      public function setup(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this._mainUI = param1.getContent() as MovieClip;
         addChild(this._mainUI);
         LevelManager.appLevel.addChild(this);
         var _loc2_:int = 1;
         while(_loc2_ <= 3)
         {
            this._mainUI["btns_" + _loc2_].gotoAndStop(1);
            if(_loc2_ == 4)
            {
               break;
            }
            this._mainUI["btns_" + _loc2_].addEventListener(MouseEvent.CLICK,this.onClickTab);
            this._mainUI["btns_" + _loc2_].buttonMode = true;
            _loc2_++;
         }
         this._mainUI["mc"].gotoAndStop(1);
         this._closeBtn = this._mainUI["close"];
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClickClose);
      }
      
      private function onClickClose(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
      
      private function onClickTab(param1:MouseEvent) : void
      {
         var _loc2_:int = int(String(param1.currentTarget.name).split("_")[1]);
         this.tab = _loc2_;
      }
      
      private function set tab(param1:int) : void
      {
         this._mainUI["mc"].gotoAndStop(param1);
         var _loc2_:int = 1;
         while(_loc2_ <= 3)
         {
            if(_loc2_ == param1)
            {
               this._mainUI["btns_" + _loc2_].gotoAndStop(2);
            }
            else
            {
               this._mainUI["btns_" + _loc2_].gotoAndStop(1);
            }
            _loc2_++;
         }
         if(this._mainUI["mc"]["txt"] != null)
         {
            this._mainUI["mc"]["txt"].text = String(this._highLvArr[param1 - 1]);
         }
         if(this._mainUI["mc"]["numtxt"] != null)
         {
            this._mainUI["mc"]["numtxt"].text = String(this._surplusNumArr[param1 - 1]);
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeAllChild(this._mainUI);
            DisplayUtil.removeForParent(this._mainUI);
         }
         this._mainUI = null;
         this._closeBtn = null;
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         if(this._mainUI == null)
         {
            _loc1_ = new MCLoader(ClientConfig.getResPath("/appRes/1211/WheelChoice_UI.swf"),this,1,"正在打开命运之轮...");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.setup);
            _loc1_.doLoad();
         }
         else
         {
            DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(this._mainUI);
         }
      }
   }
}

