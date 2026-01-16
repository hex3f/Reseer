package com.robot.app.worldMap
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.ServerConfig;
   import com.robot.core.config.UpdateConfig;
   import com.robot.core.config.xml.GalaxyXMLInfo;
   import com.robot.core.config.xml.SuperMapXMLInfo;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.MapHotInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.mapTip.MapTip;
   import com.robot.core.ui.mapTip.MapTipInfo;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.clearInterval;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import gs.easing.Cubic;
   import org.taomee.effect.ColorFilter;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class WorldMapPanel extends Sprite
   {
      
      private const GALAXY_NAME:String = "galaxy";
      
      private var hotMCArray:Array = [];
      
      private var mapMC:MovieClip;
      
      private var app:ApplicationDomain;
      
      private var perHot:uint = 10;
      
      private var myIcon:MovieClip;
      
      private var txt:TextField;
      
      private var galaxyMC:MovieClip;
      
      private var galaxyArray:Array = [];
      
      private var backBtn:SimpleButton;
      
      private var infoTxt:TextField;
      
      private var intervalId:uint;
      
      private var subPanel:AppModel;
      
      public function WorldMapPanel()
      {
         super();
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         LevelManager.appLevel.addChild(this);
         if(!this.mapMC)
         {
            _loc1_ = new MCLoader("resource/worldMap.swf",LevelManager.appLevel,1,"正在打开星系地图");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
            _loc1_.addEventListener(MCLoadEvent.CLOSE,this.onCloseLoad);
            _loc1_.doLoad();
         }
         else
         {
            setTimeout(this.initMap,200);
         }
      }
      
      private function onCloseLoad(param1:MCLoadEvent) : void
      {
         this.close();
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         var _loc2_:Shape = null;
         _loc2_ = null;
         this.app = param1.getApplicationDomain();
         this.mapMC = param1.getContent() as MovieClip;
         setTimeout(this.initMap,200);
         _loc2_ = new Shape();
         _loc2_.graphics.beginFill(0);
         _loc2_.graphics.drawRect(0,0,320,30);
         _loc2_.graphics.endFill();
         _loc2_.x = 508;
         _loc2_.y = 398;
         this.mapMC.addChild(_loc2_);
         this.txt = new TextField();
         this.mapMC.addChild(this.txt);
         this.txt.height = 30;
         this.txt.autoSize = TextFieldAutoSize.LEFT;
         this.txt.cacheAsBitmap = true;
         this.txt.x = _loc2_.x;
         this.txt.y = _loc2_.y;
         this.txt.mask = _loc2_;
         this.txt.text = UpdateConfig.mapScrollArray.join("        ");
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.size = 14;
         _loc3_.color = 16777215;
         this.txt.setTextFormat(_loc3_);
         this.txt.addEventListener(Event.ENTER_FRAME,this.onTxtEnterFrame);
      }
      
      private function onTxtEnterFrame(param1:Event) : void
      {
         this.txt.x -= 1;
         if(this.txt.x < -(this.txt.textWidth + 20))
         {
            this.txt.x = 830;
         }
      }
      
      private function initMap() : void
      {
         var _loc1_:SimpleButton = null;
         var _loc2_:String = null;
         var _loc3_:* = 0;
         addChild(this.mapMC);
         this.backBtn = this.mapMC["backBtn"];
         if(!this.subPanel)
         {
            this.backBtn.visible = false;
         }
         else
         {
            this.subPanel.content["getHot"]();
         }
         this.backBtn.addEventListener(MouseEvent.CLICK,this.backHandler);
         var _loc4_:SimpleButton = this.mapMC["closeBtn"];
         _loc4_.addEventListener(MouseEvent.CLICK,this.close);
         this.initGalaxy();
         var _loc5_:MovieClip = this.mapMC["shipBtnMC"];
         var _loc6_:uint = uint(_loc5_.numChildren);
         var _loc7_:Number = 0;
         while(_loc7_ < _loc6_)
         {
            _loc1_ = _loc5_.getChildAt(_loc7_) as SimpleButton;
            if(Boolean(_loc1_))
            {
               _loc1_.addEventListener(MouseEvent.CLICK,this.changeMap);
               _loc3_ = uint(_loc1_.name.split("_")[1]);
               _loc2_ = MapConfig.getName(_loc3_) + "\r<font color=\'#ff0000\'>" + MapConfig.getDes(_loc3_) + "</font>";
               _loc1_.addEventListener(MouseEvent.MOUSE_OVER,this.onMosOver);
               _loc1_.addEventListener(MouseEvent.MOUSE_OUT,this.onMosOut);
            }
            _loc7_++;
         }
         SocketConnection.addCmdListener(CommandID.MAP_HOT,this.onGetMapHot);
         SocketConnection.mainSocket.send(CommandID.MAP_HOT,[]);
         var _loc8_:uint = uint(MainManager.serverID);
         this.mapMC["serverNameTxt"].text = _loc8_.toString() + ". " + ServerConfig.getNameByID(_loc8_);
         if(TasksManager.getTaskStatus(45) == TasksManager.ALR_ACCEPT)
         {
            this.mapMC["shipBtnMC"]["taskIcon_45"].alpha = 1;
         }
         else
         {
            this.mapMC["shipBtnMC"]["taskIcon_45"].alpha = 0;
         }
         this.initMyPostion();
      }
      
      private function backHandler(param1:MouseEvent) : void
      {
         this.backBtn.visible = false;
         if(Boolean(this.subPanel))
         {
            this.subPanel.destroy();
            this.subPanel = null;
         }
         this.galaxyMC.mouseChildren = true;
         TweenLite.to(this.galaxyMC,1,{
            "alpha":1,
            "x":94,
            "y":95
         });
      }
      
      private function onMosOver(param1:MouseEvent) : void
      {
         var id:uint = 0;
         var evt:MouseEvent = param1;
         id = 0;
         var btn:SimpleButton = evt.currentTarget as SimpleButton;
         id = uint(btn.name.split("_")[1]);
         this.intervalId = setTimeout(function():void
         {
            MapTip.show(new MapTipInfo(id));
         },500);
      }
      
      private function onMosOut(param1:MouseEvent) : void
      {
         clearInterval(this.intervalId);
         MapTip.hide();
      }
      
      private function onGetMapHot(param1:SocketEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:SimpleButton = null;
         var _loc5_:* = 0;
         var _loc6_:* = undefined;
         var _loc7_:MovieClip = null;
         var _loc8_:MovieClip = null;
         var _loc9_:* = 0;
         var _loc10_:Number = 0;
         SocketConnection.removeCmdListener(CommandID.MAP_HOT,this.onGetMapHot);
         var _loc11_:MapHotInfo = param1.data as MapHotInfo;
         for each(_loc2_ in _loc11_.infos.getKeys())
         {
            _loc3_ = this.mapMC["shipBtnMC"];
            _loc4_ = _loc3_.getChildByName("btn_" + _loc2_) as SimpleButton;
            if(Boolean(_loc4_) && _loc2_ != 102)
            {
               _loc5_ = Math.ceil(uint(_loc11_.infos.getValue(_loc2_)) / this.perHot);
               if(_loc5_ > 5)
               {
                  _loc5_ = 5;
               }
               _loc2_ = 0;
               while(_loc2_ < _loc5_)
               {
                  _loc6_ = this.app.getDefinition("ShipHotMC");
                  _loc7_ = new _loc6_() as MovieClip;
                  _loc7_.filters = [new DropShadowFilter(2,45,0,1,3,3)];
                  _loc7_.mouseEnabled = false;
                  _loc7_.x = _loc4_.x + 4;
                  _loc7_.y = _loc4_.y + _loc4_.height - 8 - _loc7_.height * _loc2_;
                  _loc3_.addChild(_loc7_);
                  this.hotMCArray.push(_loc7_);
                  _loc2_++;
               }
            }
            if(_loc2_ == 102)
            {
               if(Boolean(_loc4_))
               {
                  _loc8_ = _loc3_.getChildByName("hotMC_" + _loc2_) as MovieClip;
                  _loc9_ = Math.ceil(uint(_loc11_.infos.getValue(_loc2_)) / this.perHot);
                  if(_loc9_ > 5)
                  {
                     _loc9_ = 5;
                  }
                  _loc10_ = 0;
                  while(_loc10_ < 5)
                  {
                     if(_loc10_ < _loc9_)
                     {
                        _loc8_["mc_" + _loc10_].gotoAndStop(1);
                     }
                     else
                     {
                        _loc8_["mc_" + _loc10_].gotoAndStop(2);
                     }
                     _loc10_++;
                  }
               }
            }
         }
      }
      
      private function changeMap(param1:MouseEvent) : void
      {
         var _loc2_:String = (param1.currentTarget as SimpleButton).name;
         var _loc3_:uint = uint(_loc2_.split("_")[1]);
         MapManager.changeMap(_loc3_);
         this.close();
      }
      
      private function close(param1:MouseEvent = null) : void
      {
         var _loc2_:MovieClip = null;
         this.galaxyArray = [];
         DisplayUtil.removeForParent(this,false);
         for each(_loc2_ in this.hotMCArray)
         {
            DisplayUtil.removeForParent(_loc2_);
         }
         this.hotMCArray = [];
      }
      
      private function initGalaxy() : void
      {
         var _loc1_:InteractiveObject = null;
         var _loc2_:* = 0;
         this.galaxyMC = this.mapMC["galaxyMC"];
         var _loc3_:uint = uint(this.galaxyMC.numChildren);
         var _loc4_:Number = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = this.galaxyMC.getChildAt(_loc4_) as InteractiveObject;
            if(Boolean(_loc1_))
            {
               if(_loc1_.name.substring(0,6) == this.GALAXY_NAME)
               {
                  _loc2_ = uint(_loc1_.name.split("_")[1]);
                  this.galaxyArray.push(_loc1_);
                  _loc1_.cacheAsBitmap = true;
                  _loc1_.filters = [ColorFilter.setBrightness(-20)];
                  _loc1_.addEventListener(MouseEvent.ROLL_OVER,this.onOverGalaxy);
                  _loc1_.addEventListener(MouseEvent.ROLL_OUT,this.onOutGalaxy);
                  _loc1_.addEventListener(MouseEvent.CLICK,this.onClickGalaxy);
                  ToolTipManager.add(_loc1_,GalaxyXMLInfo.getName(_loc2_));
               }
            }
            _loc4_++;
         }
         if(Boolean(this.subPanel))
         {
            this.subPanel.show();
         }
      }
      
      private function onOverGalaxy(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.filters = [ColorFilter.setBrightness(30)];
      }
      
      private function onOutGalaxy(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.filters = [ColorFilter.setBrightness(-20)];
      }
      
      private function onClickGalaxy(param1:MouseEvent) : void
      {
         var mc:InteractiveObject = null;
         var event:MouseEvent = param1;
         mc = null;
         var i:InteractiveObject = null;
         var p:Point = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         this.galaxyMC.mouseChildren = false;
         this.backBtn.visible = true;
         mc = event.target as InteractiveObject;
         for each(i in this.galaxyArray)
         {
            i.mouseEnabled = true;
         }
         p = mc.localToGlobal(new Point());
         dx = 498 - p.x;
         dy = 269 - p.y;
         TweenLite.to(this.galaxyMC,1,{
            "x":this.galaxyMC.x + dx,
            "y":this.galaxyMC.y + dy,
            "ease":Cubic.easeOut,
            "onComplete":function():void
            {
               loadGalaxy(uint(mc.name.split("_")[1]));
               TweenLite.to(galaxyMC,1,{"alpha":0.2});
            }
         });
      }
      
      private function loadGalaxy(param1:uint) : void
      {
         this.subPanel = new AppModel(ClientConfig.getAppModule("subMap/Galaxy_" + param1),"正在进入" + GalaxyXMLInfo.getName(param1));
         this.subPanel.init(this.mapMC);
         this.subPanel.setup();
         this.subPanel.show();
      }
      
      private function initMyPostion() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:SimpleButton = null;
         if(!this.myIcon)
         {
            _loc1_ = this.app.getDefinition("my_icon");
            this.myIcon = new _loc1_() as MovieClip;
            this.myIcon.mouseChildren = false;
            this.myIcon.mouseEnabled = false;
            DisplayUtil.FillColor(this.myIcon["mc"]["colorMC"],MainManager.actorInfo.color);
         }
         var _loc3_:Point = SuperMapXMLInfo.getWorldMapPos(MapConfig.getSuperMapID(MainManager.actorInfo.mapID));
         if(Boolean(_loc3_))
         {
            if(_loc3_.x == 0 && _loc3_.y == 0)
            {
               _loc2_ = this.mapMC["shipBtnMC"].getChildByName("btn_" + MainManager.actorInfo.mapID) as SimpleButton;
               if(Boolean(_loc2_))
               {
                  this.myIcon.x = _loc2_.x;
                  this.myIcon.y = _loc2_.y;
                  this.mapMC["shipBtnMC"].addChild(this.myIcon);
               }
               else
               {
                  DisplayUtil.removeForParent(this.myIcon,false);
               }
            }
            else
            {
               DisplayUtil.removeForParent(this.myIcon,false);
            }
         }
         else
         {
            DisplayUtil.removeForParent(this.myIcon,false);
         }
      }
   }
}

