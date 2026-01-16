package com.robot.app.worldMap
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ServerConfig;
   import com.robot.core.config.UpdateConfig;
   import com.robot.core.config.xml.SuperMapXMLInfo;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.MapHotInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class WorldMapWin extends Sprite
   {
      
      private var mapMC:MovieClip;
      
      private var app:ApplicationDomain;
      
      private var hotMCArray:Array = [];
      
      private var perHot:uint = 10;
      
      private var txt:TextField;
      
      private var shape:Shape;
      
      private var prevBtn:SimpleButton;
      
      private var nextBtn:SimpleButton;
      
      private var dir:int;
      
      private var myIcon:MovieClip;
      
      private var mapScrollRect:Rectangle;
      
      private var bgScrollRect:Rectangle;
      
      private var target:Number = 0;
      
      private var target2:Number = 0;
      
      private var isHited:Boolean = false;
      
      public function WorldMapWin()
      {
         super();
         this.mapScrollRect = new Rectangle(0,0,763,260);
         this.mapScrollRect.x = 820;
         this.bgScrollRect = new Rectangle(0,0,783,356);
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         LevelManager.appLevel.addChild(this);
         if(!this.mapMC)
         {
            _loc1_ = new MCLoader("resource/worldMap.swf",LevelManager.appLevel,1,"正在打开星际地图");
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
         this.app = param1.getApplicationDomain();
         this.mapMC = param1.getContent() as MovieClip;
         setTimeout(this.initMap,200);
         this.shape = new Shape();
         this.shape.graphics.beginFill(0);
         this.shape.graphics.drawRect(0,0,322,30);
         this.shape.graphics.endFill();
         this.shape.x = 508;
         this.shape.y = 398;
         this.mapMC.addChild(this.shape);
         this.txt = new TextField();
         this.mapMC.addChild(this.txt);
         this.txt.height = 30;
         this.txt.autoSize = TextFieldAutoSize.LEFT;
         this.txt.cacheAsBitmap = true;
         this.txt.x = this.shape.x;
         this.txt.y = this.shape.y;
         this.txt.mask = this.shape;
         this.txt.text = UpdateConfig.mapScrollArray.join("        ");
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.size = 14;
         _loc2_.color = 16777215;
         this.txt.setTextFormat(_loc2_);
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
         var _loc2_:* = 0;
         var _loc3_:String = null;
         addChild(this.mapMC);
         if(TasksManager.getTaskStatus(47) == TasksManager.COMPLETE)
         {
            this.mapMC["plantBtnMC"]["stones_mc"].visible = false;
         }
         if(TasksManager.getTaskStatus(19) == TasksManager.ALR_ACCEPT)
         {
            this.mapMC["plantBtnMC"]["task_19"].alpha = 1;
         }
         else
         {
            this.mapMC["plantBtnMC"]["task_19"].alpha = 0;
         }
         if(TasksManager.getTaskStatus(45) == TasksManager.ALR_ACCEPT)
         {
            this.mapMC["shipBtnMC"]["taskIcon_45"].alpha = 1;
         }
         else
         {
            this.mapMC["shipBtnMC"]["taskIcon_45"].alpha = 0;
         }
         var _loc4_:SimpleButton = this.mapMC["closeBtn"];
         _loc4_.addEventListener(MouseEvent.CLICK,this.close);
         MovieClip(this.mapMC["plantBtnMC"]).scrollRect = this.mapScrollRect;
         this.mapMC.addEventListener(Event.ENTER_FRAME,this.onMapEnter);
         var _loc5_:uint = uint(MainManager.serverID);
         this.mapMC["serverNameTxt"].text = _loc5_.toString() + ". " + ServerConfig.getNameByID(_loc5_);
         var _loc6_:MovieClip = this.mapMC["plantBtnMC"];
         var _loc7_:uint = uint(_loc6_.numChildren);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc1_ = _loc6_.getChildAt(_loc8_) as SimpleButton;
            if(Boolean(_loc1_))
            {
               _loc1_.addEventListener(MouseEvent.CLICK,this.changeMap);
               _loc2_ = uint(_loc1_.name.split("_")[1]);
               _loc3_ = MapConfig.getName(_loc2_) + "\r<font color=\'#ff0000\'>" + MapConfig.getDes(_loc2_) + "</font>";
               ToolTipManager.add(_loc1_,_loc3_);
            }
            _loc8_++;
         }
         _loc6_ = this.mapMC["shipBtnMC"];
         _loc7_ = uint(_loc6_.numChildren);
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc1_ = _loc6_.getChildAt(_loc8_) as SimpleButton;
            if(Boolean(_loc1_))
            {
               _loc1_.addEventListener(MouseEvent.CLICK,this.changeMap);
               _loc2_ = uint(_loc1_.name.split("_")[1]);
               _loc3_ = MapConfig.getName(_loc2_) + "\r<font color=\'#ff0000\'>" + MapConfig.getDes(_loc2_) + "</font>";
               ToolTipManager.add(_loc1_,_loc3_);
            }
            _loc8_++;
         }
         SocketConnection.addCmdListener(CommandID.MAP_HOT,this.onGetMapHot);
         SocketConnection.mainSocket.send(CommandID.MAP_HOT,[]);
         this.initMyPostion();
      }
      
      private function changeMap(param1:MouseEvent) : void
      {
         var _loc2_:String = (param1.currentTarget as SimpleButton).name;
         var _loc3_:uint = uint(_loc2_.split("_")[1]);
         MapManager.changeMap(_loc3_);
         this.close();
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
         this.showPlantHot(_loc11_);
      }
      
      private function showPlantHot(param1:MapHotInfo) : void
      {
         var _loc2_:SimpleButton = null;
         var _loc3_:* = 0;
         var _loc4_:* = null;
         var _loc5_:MovieClip = null;
         var _loc6_:* = 0;
         var _loc7_:Number = 0;
         var _loc8_:MovieClip = this.mapMC["plantBtnMC"];
         var _loc9_:uint = uint(_loc8_.numChildren);
         var _loc10_:Number = 0;
         while(_loc10_ < _loc9_)
         {
            _loc2_ = _loc8_.getChildAt(_loc10_) as SimpleButton;
            if(Boolean(_loc2_))
            {
               _loc3_ = uint(_loc2_.name.split("_")[1]);
               _loc5_ = _loc8_.getChildByName("hotMC_" + _loc3_) as MovieClip;
               _loc6_ = Math.ceil(uint(param1.infos.getValue(_loc3_)) / this.perHot);
               if(_loc6_ > 5)
               {
                  _loc6_ = 5;
               }
               _loc7_ = 0;
               while(_loc7_ < 5)
               {
                  if(_loc7_ < _loc6_)
                  {
                     _loc5_["mc_" + _loc7_].gotoAndStop(1);
                  }
                  else
                  {
                     _loc5_["mc_" + _loc7_].gotoAndStop(2);
                  }
                  _loc7_++;
               }
            }
            _loc10_++;
         }
      }
      
      private function close(param1:MouseEvent = null) : void
      {
         var _loc2_:MovieClip = null;
         this.isHited = false;
         DisplayUtil.removeForParent(this,false);
         for each(_loc2_ in this.hotMCArray)
         {
            DisplayUtil.removeForParent(_loc2_);
         }
         this.hotMCArray = [];
         if(Boolean(this.prevBtn))
         {
            this.prevBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            this.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            this.prevBtn.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
            this.nextBtn.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         MainManager.getStage().removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         if(_loc2_ == this.prevBtn)
         {
            this.dir = 1;
         }
         else
         {
            this.dir = -1;
         }
         var _loc3_:MovieClip = this.mapMC["plantBtnMC"];
         _loc3_.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      private function onEnter(param1:Event) : void
      {
         var _loc2_:MovieClip = this.mapMC["plantBtnMC"];
         _loc2_.x += 4 * this.dir;
         this.mapMC["spaceBg"].x += 1.2 * this.dir;
         if(_loc2_.x < -182)
         {
            _loc2_.x = -182;
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         }
         if(_loc2_.x > 136)
         {
            _loc2_.x = 136;
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         }
      }
      
      private function onUp(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.mapMC["plantBtnMC"];
         _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      private function onMapEnter(param1:Event) : void
      {
         var _loc2_:Number = 880;
         var _loc3_:Number = Number(MainManager.getStage().mouseX);
         var _loc4_:Number = (_loc3_ - 124) / 701;
         if(!(!this.mapMC["plantBtnMC"].hitTestPoint(MainManager.getStage().mouseX,MainManager.getStage().mouseY,true) || _loc3_ < 124 || _loc3_ > 825))
         {
            if(!this.isHited && Boolean(this.mapMC["plantBtnMC"].hitTestPoint(MainManager.getStage().mouseX,MainManager.getStage().mouseY,true)))
            {
               this.isHited = true;
            }
            this.target = _loc2_ * _loc4_;
            this.target2 = _loc2_ * _loc4_ / 3;
         }
         if(!this.isHited)
         {
            return;
         }
         if(Math.abs(this.target - this.mapScrollRect.x) < 2)
         {
            this.mapScrollRect.x = this.target;
         }
         else
         {
            this.mapScrollRect.x += (this.target - this.mapScrollRect.x) / 12;
         }
         MovieClip(this.mapMC["plantBtnMC"]).scrollRect = this.mapScrollRect;
         if(Math.abs(this.target2 - this.bgScrollRect.x) < 2)
         {
            this.bgScrollRect.x = this.target2;
         }
         else
         {
            this.bgScrollRect.x += (this.target2 - this.bgScrollRect.x) / 12;
         }
         MovieClip(this.mapMC["spaceBg"]).scrollRect = this.bgScrollRect;
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
               return;
            }
            this.myIcon.x = _loc3_.x;
            this.myIcon.y = _loc3_.y;
            this.mapMC["plantBtnMC"].addChild(this.myIcon);
         }
         else
         {
            DisplayUtil.removeForParent(this.myIcon,false);
         }
      }
   }
}

