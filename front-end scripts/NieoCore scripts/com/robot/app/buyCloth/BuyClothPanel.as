package com.robot.app.buyCloth
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class BuyClothPanel extends Sprite
   {
      
      private var PATH:String = "resource/module/clothBook/clothBook.swf";
      
      private var app:ApplicationDomain;
      
      private var _mainUI:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      public function BuyClothPanel()
      {
         super();
         var _loc1_:MCLoader = new MCLoader(this.PATH,LevelManager.topLevel,1,"正在打开装备列表");
         _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         _loc1_.doLoad();
      }
      
      public function show() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeForParent(this._mainUI);
            this._mainUI = new (this.app.getDefinition("BookPanel") as Class)() as MovieClip;
            addChild(this._mainUI);
            (this._mainUI["buyPanel"] as MovieClip).gotoAndStop(1);
            _loc1_ = this._mainUI["buyPanel"] as MovieClip;
            _loc1_.gotoAndStop(1);
            LevelManager.appLevel.addChild(this);
            this._closeBtn = this._mainUI["closeBtn"];
            this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeHandler);
         }
      }
      
      public function destroy() : void
      {
         this.app = null;
         if(Boolean(this._mainUI))
         {
            this._closeBtn.removeEventListener(MouseEvent.CLICK,this.closeHandler);
            this._closeBtn = null;
            this._mainUI = null;
         }
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeForParent(this._mainUI);
         }
         this.app = param1.getApplicationDomain();
         this._mainUI = new (this.app.getDefinition("BookPanel") as Class)() as MovieClip;
         var _loc2_:MovieClip = this._mainUI["buyPanel"] as MovieClip;
         _loc2_.gotoAndStop(1);
         (_loc2_["coverMC"] as MovieClip).stop();
         addChild(this._mainUI);
         this.x = 94;
         this.y = 34;
         LevelManager.appLevel.addChild(this);
         LevelManager.closeMouseEvent();
         this._closeBtn = this._mainUI["closeBtn"];
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeHandler);
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
   }
}

