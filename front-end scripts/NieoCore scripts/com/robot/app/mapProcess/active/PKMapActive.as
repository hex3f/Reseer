package com.robot.app.mapProcess.active
{
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.MovieClip;
   import flash.utils.*;
   import gs.*;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class PKMapActive
   {
      
      private const NONE:uint = 0;
      
      private const ATTACK:uint = 1;
      
      private const STONE:uint = 2;
      
      private var estradeMC:MovieClip;
      
      private var flag:uint;
      
      private var attackMC:MovieClip;
      
      private var stoneMC:MovieClip;
      
      private var timerMap:HashMap;
      
      public function PKMapActive()
      {
         super();
         SocketConnection.addCmdListener(CommandID.TEAM_PK_ACTIVE,this.onPKActive);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_ACTIVE_NOTE_GET_ITEM,this.onNoteGetItem);
         this.estradeMC = MapManager.currentMap.depthLevel["estradeMC"];
         this.estradeMC.mouseEnabled = this.estradeMC.mouseChildren = false;
         this.attackMC = MapLibManager.getMovieClip("attack_mc");
         this.stoneMC = MapLibManager.getMovieClip("stone_mc");
         this.stoneMC.y = -40;
         this.attackMC.y = -40;
         this.stoneMC.mouseChildren = this.stoneMC.mouseEnabled = false;
         this.attackMC.mouseChildren = this.attackMC.mouseEnabled = false;
         MapManager.currentMap.controlLevel["clickMC"].mouseEnabled = false;
         this.timerMap = new HashMap();
      }
      
      public function clickHandler() : void
      {
         if(this.flag == this.ATTACK)
         {
            SocketConnection.send(CommandID.TEAM_PK_ACTIVE_GET_ATTACK);
         }
         else
         {
            SocketConnection.send(CommandID.TEAM_PK_ACTIVE_GET_STONE);
         }
      }
      
      private function onPKActive(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         this.flag = _loc2_.readUnsignedInt();
         this.update();
      }
      
      private function update() : void
      {
         if(this.flag != this.NONE)
         {
            this.estradeMC["lightMC"].gotoAndPlay(2);
            MapManager.currentMap.controlLevel["clickMC"].mouseEnabled = true;
         }
         else
         {
            MapManager.currentMap.controlLevel["clickMC"].mouseEnabled = false;
         }
         DisplayUtil.removeForParent(this.attackMC,false);
         DisplayUtil.removeForParent(this.stoneMC,false);
         if(this.flag == this.ATTACK)
         {
            this.estradeMC.addChild(this.attackMC);
            this.attackMC.gotoAndPlay(2);
         }
         else if(this.flag == this.STONE)
         {
            this.estradeMC.addChild(this.stoneMC);
            this.stoneMC.gotoAndPlay(2);
         }
      }
      
      private function onNoteGetItem(param1:SocketEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:TimerExt = null;
         var _loc4_:String = null;
         var _loc5_:ByteArray = param1.data as ByteArray;
         var _loc6_:uint = _loc5_.readUnsignedInt();
         var _loc7_:uint = _loc5_.readUnsignedInt();
         var _loc8_:uint = _loc5_.readUnsignedInt();
         if(_loc7_ != this.NONE)
         {
            MapManager.currentMap.controlLevel["clickMC"].mouseEnabled = false;
         }
         DisplayUtil.removeForParent(this.attackMC,false);
         DisplayUtil.removeForParent(this.stoneMC,false);
         if(_loc7_ == this.ATTACK)
         {
            _loc2_ = UserManager.getUserModel(_loc6_);
            if(Boolean(_loc2_))
            {
               TweenLite.to(_loc2_.skeleton.getSkeletonMC(),2,{
                  "scaleX":1.5,
                  "scaleY":1.5
               });
               if(!this.timerMap.containsKey(_loc2_))
               {
                  _loc3_ = new TimerExt(_loc2_);
                  this.timerMap.add(_loc2_,_loc3_);
               }
               else
               {
                  _loc3_ = this.timerMap.getValue(_loc2_);
               }
               _loc3_.start(_loc8_);
            }
         }
         else if(_loc7_ == this.STONE && _loc6_ == MainManager.actorID)
         {
            _loc4_ = ItemXMLInfo.getName(400035);
            ItemInBagAlert.show(400035,TextFormatUtil.getRedTxt(_loc4_) + "已经放入了你的储存箱");
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:TimerExt = null;
         for each(_loc1_ in this.timerMap.getValues())
         {
            _loc1_.destroy();
         }
         this.timerMap.clear();
         this.timerMap = null;
         SocketConnection.removeCmdListener(CommandID.TEAM_PK_ACTIVE,this.onPKActive);
         SocketConnection.removeCmdListener(CommandID.TEAM_PK_ACTIVE_NOTE_GET_ITEM,this.onNoteGetItem);
      }
   }
}

import com.robot.core.manager.AssetsManager;
import com.robot.core.mode.BasePeoleModel;
import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.utils.Timer;
import gs.TweenLite;
import org.taomee.utils.DisplayUtil;

class TimerExt
{
   
   private var p:BasePeoleModel;
   
   private var timer:Timer;
   
   private var flashMC:MovieClip;
   
   public function TimerExt(param1:BasePeoleModel)
   {
      super();
      this.p = param1;
      this.flashMC = AssetsManager.getMovieClip("pk_flash_mc");
   }
   
   public function start(param1:uint) : void
   {
      if(Boolean(this.p))
      {
         this.p.addChild(this.flashMC);
      }
      if(Boolean(this.timer))
      {
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
      }
      this.timer = new Timer(param1 * 1000,1);
      this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      this.timer.start();
   }
   
   public function destroy() : void
   {
      if(Boolean(this.p))
      {
         try
         {
            TweenLite.to(this.p.skeleton.getSkeletonMC(),2,{
               "scaleX":1,
               "scaleY":1
            });
         }
         catch(e:Error)
         {
         }
      }
      if(Boolean(this.timer))
      {
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
      }
      DisplayUtil.removeForParent(this.flashMC,false);
   }
   
   private function onTimer(param1:TimerEvent) : void
   {
      if(Boolean(this.p))
      {
         try
         {
            TweenLite.to(this.p.skeleton.getSkeletonMC(),2,{
               "scaleX":1,
               "scaleY":1
            });
         }
         catch(e:Error)
         {
         }
         DisplayUtil.removeForParent(this.flashMC,false);
      }
   }
}
