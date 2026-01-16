package com.robot.core.mode
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.loading.Loading;
   import com.robot.core.ui.loading.loadingstyle.ILoadingStyle;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.module.IModule;
   
   public class AppModel extends EventDispatcher
   {
      
      private static const SHOW:int = 1;
      
      private static const HIDE:int = 2;
      
      private var _state:int;
      
      private var _isLoading:Boolean = false;
      
      private var _url:String;
      
      private var _title:String;
      
      private var _mode:IModule;
      
      private var _data:Object;
      
      private var _event:EventDispatcher;
      
      private var _loader:MCLoader;
      
      private var _loadingView:ILoadingStyle;
      
      public function AppModel(param1:String, param2:String)
      {
         super();
         this._url = param1;
         this._title = param2;
      }
      
      public function get appLoader() : MCLoader
      {
         return this._loader;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get sharedEvents() : EventDispatcher
      {
         return this._event;
      }
      
      public function set loadingView(param1:ILoadingStyle) : void
      {
         this._loadingView = param1;
      }
      
      public function get content() : IModule
      {
         return this._mode;
      }
      
      public function setup() : void
      {
         if(Boolean(this._mode))
         {
            return;
         }
         if(this._isLoading)
         {
            return;
         }
         this._isLoading = true;
         this._loader = new MCLoader(this._url,LevelManager.appLevel,Loading.TITLE_AND_PERCENT,this._title);
         if(Boolean(this._loadingView))
         {
            this._loader.loadingView = this._loadingView;
            this._loadingView.setTitle(this._title);
         }
         this._loader.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         this._loader.addEventListener(MCLoadEvent.CLOSE,this.onClose);
         this._loader.doLoad();
         this._event = this._loader.sharedEvents;
      }
      
      public function init(param1:Object = null) : void
      {
         this._data = param1;
         if(Boolean(this._mode))
         {
            this._mode.init(param1);
         }
         this.setup();
      }
      
      public function show() : void
      {
         this._state = SHOW;
         if(Boolean(this._mode))
         {
            this._mode.show();
         }
         this.setup();
      }
      
      public function hide() : void
      {
         this._state = HIDE;
         if(Boolean(this._mode))
         {
            this._mode.hide();
         }
      }
      
      public function destroy() : void
      {
         ModuleManager.remove(this._url);
         if(Boolean(this._loader))
         {
            this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoad);
            this._loader.clear();
            this._loader = null;
         }
         if(Boolean(this._mode))
         {
            this._mode.destroy();
            this._mode = null;
         }
         this._data = null;
         this._event = null;
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         this._isLoading = false;
         this._mode = param1.getContent() as IModule;
         this._mode.setup();
         if(this._data != null)
         {
            this._mode.init(this._data);
         }
         if(this._state == SHOW)
         {
            this._mode.show();
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onClose(param1:MCLoadEvent) : void
      {
         this._isLoading = false;
         this.destroy();
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}

