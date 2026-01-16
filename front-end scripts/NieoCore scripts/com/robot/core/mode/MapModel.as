package com.robot.core.mode
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.controller.MapController;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.UserEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.loading.Loading;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.taomee.algo.IMapModel;
   import org.taomee.utils.DisplayUtil;
   
   public class MapModel implements IMapModel
   {
      
      private var _id:uint;
      
      private var _width:int = 960;
      
      private var _height:int = 560;
      
      private var _gridSize:uint = 10;
      
      private var _gridX:uint;
      
      private var _gridY:uint;
      
      private var _gridTotal:uint;
      
      private var _data:Array;
      
      private var _depthLevel:DisplayObjectContainer;
      
      private var _typeLevel:DisplayObjectContainer;
      
      private var _topLevel:DisplayObjectContainer;
      
      private var _root:DisplayObjectContainer;
      
      private var _spaceLevel:Sprite;
      
      private var _backLevel:Bitmap;
      
      private var _controlLevel:DisplayObjectContainer;
      
      private var _btnLevel:DisplayObjectContainer;
      
      private var _animatorLevel:DisplayObjectContainer;
      
      private var _loader:MCLoader;
      
      private var _timeoutID:uint;
      
      private var _isCanClose:Boolean = true;
      
      private var _allowData:Array = new Array();
      
      private var isSwitching:Boolean = false;
      
      public function MapModel(param1:uint, param2:Boolean = true, param3:Boolean = true)
      {
         super();
         this._isCanClose = param2;
         this._id = param1;
         this.loadMap(param3);
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get root() : DisplayObjectContainer
      {
         return this._root;
      }
      
      public function get topLevel() : DisplayObjectContainer
      {
         return this._topLevel;
      }
      
      public function get typeLevel() : DisplayObjectContainer
      {
         return this._typeLevel;
      }
      
      public function get depthLevel() : DisplayObjectContainer
      {
         return this._depthLevel;
      }
      
      public function get backLevel() : Bitmap
      {
         return this._backLevel;
      }
      
      public function get spaceLevel() : DisplayObjectContainer
      {
         return this._spaceLevel;
      }
      
      public function get controlLevel() : DisplayObjectContainer
      {
         return this._controlLevel;
      }
      
      public function get btnLevel() : DisplayObjectContainer
      {
         return this._btnLevel;
      }
      
      public function get animatorLevel() : DisplayObjectContainer
      {
         return this._animatorLevel;
      }
      
      public function get width() : int
      {
         return this._spaceLevel.width;
      }
      
      public function get height() : int
      {
         return this._spaceLevel.height;
      }
      
      public function get gridSize() : uint
      {
         return this._gridSize;
      }
      
      public function get gridX() : uint
      {
         return this._gridX;
      }
      
      public function get gridY() : uint
      {
         return this._gridY;
      }
      
      public function get gridTotal() : uint
      {
         return this._gridTotal;
      }
      
      public function get data() : Array
      {
         return this._data;
      }
      
      public function get allowData() : Array
      {
         return this._allowData;
      }
      
      public function addUser(param1:BasePeoleModel) : void
      {
         var _loc2_:uint = param1.info.userID;
         if(!UserManager.contains(_loc2_))
         {
            UserManager.addUser(_loc2_,param1);
            this._depthLevel.addChild(param1);
         }
         if(!UserManager.isShow)
         {
            this.hideAllUser();
         }
      }
      
      public function hideAllUser() : void
      {
         var _loc1_:BasePeoleModel = null;
         var _loc2_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc2_)
         {
            this.hideUser(_loc1_);
         }
      }
      
      public function showAllUser() : void
      {
         var _loc1_:BasePeoleModel = null;
         var _loc2_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc2_)
         {
            this.showUser(_loc1_);
         }
      }
      
      public function hideUser(param1:BasePeoleModel) : void
      {
         if(param1.info.userID != MainManager.actorID)
         {
            DisplayUtil.removeForParent(param1,false);
            if(Boolean(param1.pet))
            {
               param1.pet.visible = false;
            }
            if(Boolean(param1.nono))
            {
               DisplayUtil.removeForParent(param1.nono as ActionSpriteModel,false);
            }
         }
      }
      
      public function showUser(param1:BasePeoleModel) : void
      {
         if(param1.info.userID != MainManager.actorID)
         {
            if(Boolean(param1.pet))
            {
               param1.pet.visible = true;
            }
            if(Boolean(param1.nono))
            {
               param1.addChildAt(param1.nono as ActionSpriteModel,0);
            }
            this._depthLevel.addChild(param1);
         }
      }
      
      public function removeUser(param1:uint) : void
      {
         var _loc2_:BasePeoleModel = UserManager.removeUser(param1);
         if(Boolean(_loc2_))
         {
            _loc2_.stop();
            if(this._depthLevel.contains(_loc2_))
            {
               this._depthLevel.removeChild(_loc2_);
            }
            UserManager.dispatchEvent(new UserEvent(UserEvent.REMOVED_FROM_MAP,_loc2_.info));
            _loc2_.destroy();
            _loc2_ = null;
         }
      }
      
      public function closeChange() : void
      {
         this._loader.clear();
         this._loader = null;
      }
      
      public function destroy() : void
      {
         var _loc1_:PeopleModel = null;
         var _loc2_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc2_)
         {
            _loc1_.stop();
            _loc1_.destroy();
            _loc1_ = null;
         }
         UserManager.clear();
         AimatController.destroy();
         this._data = null;
         this._loader.clear();
         this._loader = null;
         this._backLevel.bitmapData.dispose();
         this._backLevel = null;
         DisplayUtil.removeAllChild(this._depthLevel);
         this._depthLevel = null;
         DisplayUtil.removeAllChild(this._typeLevel);
         this._typeLevel = null;
         DisplayUtil.removeAllChild(this._topLevel);
         this._topLevel = null;
         DisplayUtil.removeAllChild(this._spaceLevel);
         this._spaceLevel = null;
         DisplayUtil.removeAllChild(this._controlLevel);
         this._controlLevel = null;
         DisplayUtil.removeAllChild(this._btnLevel);
         this._btnLevel = null;
         DisplayUtil.removeAllChild(this._root);
         this._root = null;
      }
      
      public function isBlock(param1:Point) : Boolean
      {
         var _loc2_:int = int(param1.x / this._gridSize);
         var _loc3_:int = int(param1.y / this._gridSize);
         if(_loc2_ < 0 || _loc2_ >= this._gridX || _loc3_ < 0 || _loc3_ >= this._gridY)
         {
            return false;
         }
         return this._data[_loc2_][_loc3_];
      }
      
      public function closeLoading() : void
      {
         if(Boolean(this._loader))
         {
            this._loader.closeLoading();
         }
      }
      
      public function makeMapArray() : void
      {
         var _loc1_:* = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Point = new Point();
         var _loc5_:BitmapData = new BitmapData(this.width,this.height,true,0);
         _loc5_.draw(this._typeLevel);
         this._data = new Array(this._gridX);
         _loc1_ = uint(int(this._gridSize / 2));
         _loc2_ = 0;
         while(_loc2_ < this._gridX)
         {
            this._data[_loc2_] = new Array(this._gridY);
            _loc3_ = 0;
            while(_loc3_ < this._gridY)
            {
               if(Boolean(_loc5_.getPixel32(_loc2_ * this._gridSize + _loc1_,_loc3_ * this._gridSize + _loc1_)))
               {
                  this._data[_loc2_][_loc3_] = false;
               }
               else
               {
                  this._data[_loc2_][_loc3_] = true;
                  this._allowData.push(new Point(_loc2_ * this._gridSize,_loc3_ * this._gridSize));
               }
               _loc3_++;
            }
            _loc2_++;
         }
         _loc4_ = null;
         _loc5_.dispose();
         _loc5_ = null;
      }
      
      private function loadMap(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         param1 = true;
         if(this._loader == null)
         {
            if(MainManager.actorInfo.mapID <= 9 && this._id > 9 && this._id < 100)
            {
               if(param1)
               {
                  _loc2_ = Loading.TITLE_AND_PERCENT;
               }
               else
               {
                  _loc2_ = Loading.NO_ALL;
               }
               this._loader = new MCLoader("",LevelManager.topLevel,_loc2_,"加载地图",false);
            }
            else
            {
               if(param1)
               {
                  _loc2_ = Loading.TITLE_AND_PERCENT;
               }
               else
               {
                  _loc2_ = Loading.NO_ALL;
               }
               this._loader = new MCLoader("",LevelManager.topLevel,_loc2_,"加载地图",false);
            }
         }
         this._loader.setIsShowClose(this._isCanClose);
         this._loader.addEventListener(MCLoadEvent.SUCCESS,this.onMapComplete);
         this._loader.addEventListener(MCLoadEvent.ERROR,this.onMapError);
         this._loader.addEventListener(MCLoadEvent.CLOSE,this.onMapClose);
         this._loader.doLoad(ClientConfig.getMapPath(MapManager.getResMapID(this._id)));
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_LOADER_OPEN));
      }
      
      private function onMapComplete(param1:MCLoadEvent) : void
      {
         var _loc2_:DisplayObject = null;
         this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onMapComplete);
         this._loader.removeEventListener(MCLoadEvent.ERROR,this.onMapError);
         this._loader.removeEventListener(MCLoadEvent.CLOSE,this.onMapClose);
         MapLibManager.setup(param1.getLoader());
         this._root = param1.getContent().root as DisplayObjectContainer;
         this._depthLevel = this._root["depth_mc"];
         this._typeLevel = this._root["type_mc"];
         this._topLevel = this._root["top_mc"];
         this._controlLevel = this._root["control_mc"];
         this._btnLevel = this._root["buttonLevel"];
         this._animatorLevel = this._root["animator_mc"];
         var _loc3_:Sprite = this._root["rect_mc"];
         if(Boolean(_loc3_))
         {
            this._spaceLevel = _loc3_;
            this._spaceLevel.alpha = 0;
         }
         else
         {
            this._spaceLevel = this.creatRect();
         }
         this._backLevel = this.creatBitmap(this._root["bg_mc"]);
         this._root.addChildAt(this._backLevel,0);
         this._root.addChildAt(this._spaceLevel,1);
         if(Boolean(this._animatorLevel))
         {
            this._animatorLevel.mouseEnabled = false;
            this._animatorLevel.mouseChildren = false;
         }
         if(MapController.isReMap)
         {
            _loc2_ = this._topLevel["title_mc"];
            if(Boolean(_loc2_))
            {
               DisplayUtil.removeForParent(_loc2_);
            }
         }
         this._spaceLevel.mouseChildren = false;
         this._depthLevel.mouseEnabled = false;
         this._controlLevel.mouseEnabled = false;
         this._btnLevel.mouseEnabled = false;
         this._typeLevel.mouseChildren = false;
         this._typeLevel.mouseEnabled = false;
         this._topLevel.mouseEnabled = false;
         this._gridX = int(this.width / this._gridSize);
         this._gridY = int(this.height / this._gridSize);
         this._gridTotal = this._gridX * this._gridY;
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_LOADER_COMPLETE));
         this.initFindPath();
      }
      
      private function onMapClose(param1:MCLoadEvent) : void
      {
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_LOADER_CLOSE));
      }
      
      private function onMapError(param1:MCLoadEvent) : void
      {
         this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onMapComplete);
         this._loader.removeEventListener(MCLoadEvent.ERROR,this.onMapError);
         this._loader.removeEventListener(MCLoadEvent.CLOSE,this.onMapClose);
         this._loader.clear();
         this._loader = null;
         MapManager.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
      }
      
      private function initFindPath() : void
      {
         this._timeoutID = setTimeout(this.onMakMap,200);
      }
      
      private function onMakMap() : void
      {
         if(this._timeoutID != 0)
         {
            clearTimeout(this._timeoutID);
         }
         this.makeMapArray();
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_INIT));
      }
      
      private function creatRect() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(0,0);
         _loc1_.graphics.drawRect(0,0,this._width,this._height);
         _loc1_.graphics.endFill();
         return _loc1_;
      }
      
      private function creatBitmap(param1:DisplayObjectContainer) : Bitmap
      {
         var _loc2_:Bitmap = new Bitmap();
         var _loc3_:BitmapData = new BitmapData(this.width,this.height);
         _loc3_.draw(param1);
         _loc2_.bitmapData = _loc3_;
         DisplayUtil.removeForParent(param1);
         return _loc2_;
      }
   }
}

