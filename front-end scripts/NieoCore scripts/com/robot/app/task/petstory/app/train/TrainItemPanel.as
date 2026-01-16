package com.robot.app.task.petstory.app.train
{
   import com.robot.core.config.ClientConfig;
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
   
   public class TrainItemPanel
   {
      
      private const PATH:String = ClientConfig.getResPath("module/ext/app/train.swf");
      
      private var _closeBtn:SimpleButton;
      
      private var _app:ApplicationDomain;
      
      private var _mainUI:MovieClip;
      
      private var _loader:MCLoader;
      
      private var _gotoList:Array;
      
      public function TrainItemPanel()
      {
         super();
         this.loadPanel();
      }
      
      private function loadPanel() : void
      {
         if(!this._app)
         {
            this._loader = new MCLoader(this.PATH,LevelManager.topLevel,1,"正在加载训练房间面板");
            this._loader.addEventListener(MCLoadEvent.SUCCESS,this.onComplete);
            this._loader.doLoad();
         }
         else
         {
            this.showPanel();
         }
      }
      
      private function onComplete(param1:MCLoadEvent) : void
      {
         this._app = param1.getApplicationDomain();
         this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onComplete);
         this._mainUI = new (this._app.getDefinition("Train_UI") as Class)() as MovieClip;
         this._closeBtn = this._mainUI["closeBtn"];
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseBtn);
         this.showPanel();
      }
      
      private function showPanel() : void
      {
         DisplayUtil.align(this._mainUI,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(this._mainUI);
         LevelManager.closeMouseEvent();
         this.initMC();
      }
      
      private function initMC() : void
      {
         var _loc1_:Number = 0;
         while(_loc1_ <= 5)
         {
            (this._mainUI["btn_" + _loc1_] as SimpleButton).addEventListener(MouseEvent.CLICK,this.onMouseBtn);
            _loc1_++;
         }
         this.setRoomGrade();
      }
      
      private function setRoomGrade() : void
      {
         if(TrainData.trainGrade == 0)
         {
            this._gotoList = [488,489,490,491,492,493];
         }
         else if(TrainData.trainGrade == 1)
         {
            this._gotoList = [470,471,472,473,474,475];
         }
      }
      
      private function onMouseBtn(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint((param1.currentTarget as SimpleButton).name.slice(4));
         TrainData.roomId = this._gotoList[_loc2_];
         TrainData.times = 0;
         TrainData.totalTimes = 30;
         MapManager.changeMap(this._gotoList[_loc2_]);
         this.onCloseBtn(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._mainUI,false);
         LevelManager.openMouseEvent();
         this.destory();
      }
      
      private function destory() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseBtn);
         this._closeBtn = null;
         this._app = null;
         this._loader = null;
         this._mainUI = null;
      }
   }
}

