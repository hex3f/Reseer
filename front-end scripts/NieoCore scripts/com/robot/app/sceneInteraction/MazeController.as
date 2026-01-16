package com.robot.app.sceneInteraction
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.temp.AresiaSpacePrize;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import org.taomee.effect.ColorFilter;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class MazeController
   {
      
      private static var _instance:MazeController;
      
      private const mapList:Array = [302,303,304,305,306,307,308,309,310,311,312,313];
      
      private var _bailuen:BailuenModel;
      
      private var _allowArr:Array;
      
      private var _allowLen:int = 0;
      
      private var _time:Timer;
      
      public function MazeController()
      {
         super();
         this._allowArr = MapManager.currentMap.allowData;
         this._allowLen = this._allowArr.length;
      }
      
      public static function setup() : void
      {
         if(_instance == null)
         {
            _instance = new MazeController();
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(_instance))
         {
            _instance._destroy();
            _instance = null;
         }
      }
      
      private function _destroy() : void
      {
         if(Boolean(this._bailuen))
         {
            this._bailuen.removeEventListener(BailuenModel.FIG,this.onBailuenFig);
            this._bailuen.destroy();
            this._bailuen = null;
         }
         if(Boolean(this._time))
         {
            if(this._time.running)
            {
               this._time.stop();
            }
            this._time.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._time.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            this._time = null;
         }
      }
      
      private function onBailuenInfo(param1:SocketEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:uint = _loc3_.readUnsignedInt();
         var _loc6_:uint = _loc3_.readUnsignedInt();
         if(_loc4_ == 1 || _loc4_ == 3)
         {
            if(_loc5_ == MapManager.getMapController().newMapID)
            {
               if(_loc6_ > 0)
               {
                  if(this._bailuen == null)
                  {
                     this._bailuen = new BailuenModel();
                     this._bailuen.show(this._allowArr[int(Math.random() * this._allowLen)],Boolean(_loc4_ == 1));
                     MapManager.currentMap.depthLevel.addChild(this._bailuen);
                     this._bailuen.addEventListener(BailuenModel.FIG,this.onBailuenFig);
                  }
               }
            }
         }
         else if(_loc4_ == 2)
         {
            if(_loc5_ == MapManager.getMapController().newMapID)
            {
               if(Boolean(this._bailuen))
               {
                  this._bailuen.destroy();
                  this._bailuen = null;
               }
            }
         }
         else if(_loc4_ == 4)
         {
            if(Boolean(this._bailuen))
            {
               this._bailuen.fight();
            }
         }
         if(Boolean(this._bailuen))
         {
            this._bailuen.hp = _loc6_;
            if(_loc6_ == 0)
            {
               _loc2_ = TaskIconManager.getIcon("Chests") as MovieClip;
               MapManager.currentMap.controlLevel.addChild(_loc2_);
               _loc2_.x = 450;
               _loc2_.y = 200;
               _loc2_.addEventListener(MouseEvent.CLICK,this.getChests);
               SocketConnection.addCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
            }
         }
      }
      
      private function getChests(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         SocketConnection.send(CommandID.PRIZE_OF_ATRESIASPACE,2);
         _loc2_.removeEventListener(MouseEvent.CLICK,this.getChests);
         DisplayUtil.removeForParent(_loc2_);
      }
      
      private function getPirze(param1:SocketEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         SocketConnection.removeCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
         var _loc7_:AresiaSpacePrize = param1.data as AresiaSpacePrize;
         var _loc8_:Array = _loc7_.monBallList;
         for each(_loc2_ in _loc8_)
         {
            _loc3_ = uint(_loc2_.itemID);
            _loc4_ = uint(_loc2_.itemCnt);
            _loc5_ = ItemXMLInfo.getName(_loc3_);
            _loc6_ = _loc4_ + "个<font color=\'#FF0000\'>" + _loc5_ + "</font>已经放入了你的储存箱！";
            if(_loc4_ != 0)
            {
               LevelManager.tipLevel.addChild(ItemInBagAlert.show(_loc3_,_loc6_));
            }
         }
      }
      
      private function onBailuenFig(param1:Event) : void
      {
         if(this._time == null)
         {
            this._time = new Timer(100,6);
            this._time.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._time.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         }
         this._time.reset();
         this._time.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this._time.currentCount % 2 == 0)
         {
            MapManager.currentMap.root.filters = [ColorFilter.setBrightness(30)];
         }
         else
         {
            MapManager.currentMap.root.filters = [ColorFilter.setInvert(),ColorFilter.setBrightness(30)];
         }
         MapManager.currentMap.root.x = 10 - Math.random() * 5;
         MapManager.currentMap.root.y = 10 - Math.random() * 5;
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         MapManager.currentMap.root.filters = [];
         MapManager.currentMap.root.x = 0;
         MapManager.currentMap.root.y = 0;
         if(Math.random() > 0.85)
         {
            LevelManager.topLevel.addChild(NpcTipDialog.show("你受伤过重，现在已经整备完毕，你可以重新开始你的历险了！",null,NpcTipDialog.CICI));
            MapManager.changeMap(MainManager.actorID);
         }
         else
         {
            _loc2_ = this.mapList.concat();
            _loc3_ = int(_loc2_.indexOf(MapManager.currentMap.id));
            if(_loc3_ != -1)
            {
               _loc2_.splice(_loc3_,1);
            }
            MapManager.changeMap(_loc2_[int(Math.random() * _loc2_.length)]);
         }
      }
   }
}

