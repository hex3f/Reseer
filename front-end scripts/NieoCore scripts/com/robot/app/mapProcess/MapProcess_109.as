package com.robot.app.mapProcess
{
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.aimat.*;
   import com.robot.core.event.*;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.ColorTransform;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_109 extends BaseMapProcess
   {
      
      private var superStone:MovieClip;
      
      private var weightLessHouse:MovieClip;
      
      private var oreGather:MovieClip;
      
      private var suitAlarm:MovieClip;
      
      private var nonoSuit:MovieClip;
      
      private var sinNum:Number = 0;
      
      private var stoneNum:uint = 0;
      
      private var stoneList:Array = [];
      
      private var oldSpeed:Number;
      
      public function MapProcess_109()
      {
         super();
      }
      
      private function createStone() : void
      {
         var _loc1_:Stone = null;
         var _loc5_:uint = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         _loc1_ = null;
         while(this.stoneNum > 20 || this.stoneNum < 15)
         {
            this.stoneNum = Math.floor(Math.random() * 20);
         }
         while(_loc5_ < this.stoneNum)
         {
            _loc2_ = this.getGaussian(40 * (_loc5_ + 1),50);
            _loc3_ = this.getGaussian(20 * (_loc5_ + 1),100);
            _loc4_ = Math.random();
            while(_loc4_ < 0.7)
            {
               _loc4_ = Math.random();
            }
            _loc1_ = new Stone(Math.ceil(Math.random() * 5));
            _loc1_.x = _loc2_;
            _loc1_.y = _loc3_;
            _loc1_.scaleX = _loc4_;
            _loc1_.scaleY = _loc4_;
            conLevel.addChild(_loc1_);
            _loc1_.addEventListener(Stone.CLEAR,this.onClear);
            this.stoneList.push(_loc1_);
            _loc5_++;
         }
      }
      
      private function onClear(param1:Event) : void
      {
         var _loc2_:Stone = param1.currentTarget as Stone;
         _loc2_.removeEventListener(Stone.CLEAR,this.onClear);
         var _loc3_:int = int(this.stoneList.indexOf(_loc2_));
         if(_loc3_ != -1)
         {
            this.stoneList.splice(_loc3_,1);
         }
      }
      
      override protected function init() : void
      {
         var array:Array = null;
         this.oldSpeed = MainManager.actorModel.speed;
         MainManager.actorModel.speed = this.oldSpeed / 2;
         this.createStone();
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimat);
         this.suitAlarm = MapLibManager.getMovieClip("suitAlarm");
         this.superStone = this.conLevel["superStone"];
         this.weightLessHouse = this.conLevel["weightLessHouse"];
         this.oreGather = this.conLevel["oreGather"];
         array = MainManager.actorInfo.clothIDs;
         if(!ArrayUtil.arrayContainsValue(array,100054) && !ArrayUtil.arrayContainsValue(array,100110) && !ArrayUtil.arrayContainsValue(array,100158) && !ArrayUtil.arrayContainsValue(array,100167))
         {
            LevelManager.appLevel.addChild(this.suitAlarm);
            DisplayUtil.align(this.suitAlarm,null,AlignType.MIDDLE_CENTER);
            this.suitAlarm["closeBtn"].addEventListener(MouseEvent.CLICK,function():void
            {
               MapManager.changeMap(107);
            });
            return;
         }
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_END,this.onWalkEnd);
      }
      
      override public function destroy() : void
      {
         var _loc1_:Stone = null;
         MainManager.actorModel.speed = this.oldSpeed;
         LevelManager.openMouseEvent();
         if(!MainManager.actorModel.nono)
         {
            MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
         }
         for each(_loc1_ in this.stoneList)
         {
            _loc1_.removeEventListener(Stone.CLEAR,this.onClear);
         }
         if(Boolean(this.suitAlarm))
         {
            DisplayUtil.removeForParent(this.suitAlarm);
         }
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimat);
         SocketConnection.removeCmdListener(CommandID.NO_GRAVITY_SHIP,this.onSocketSuccessHandler);
         this.stoneList = [];
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         if(Boolean(this.nonoSuit))
         {
            if(this.nonoSuit.hasEventListener(Event.ENTER_FRAME))
            {
               this.nonoSuit.removeEventListener(Event.ENTER_FRAME,this.onNonoSuitFrameHandler);
            }
         }
         if(this.weightLessHouse.hasEventListener(Event.ENTER_FRAME))
         {
            this.weightLessHouse.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler("*"));
         }
      }
      
      private function onAimat(param1:AimatEvent) : void
      {
         var _loc2_:Stone = null;
         var _loc3_:AimatInfo = param1.info;
         if(_loc3_.userID != MainManager.actorID)
         {
            return;
         }
         for each(_loc2_ in this.stoneList)
         {
            if(_loc2_.hitTestPoint(_loc3_.endPos.x,_loc3_.endPos.y,true))
            {
               _loc2_.play();
               break;
            }
         }
      }
      
      public function onSuperStoneClickHandler() : void
      {
         if(!MainManager.actorInfo.superNono)
         {
            Alarm.show("你必须要带上超能NoNo哦！");
            return;
         }
         if(!MainManager.actorModel.nono)
         {
            Alarm.show("你必须要带上超能NoNo哦！");
            return;
         }
         MainManager.actorModel.hideNono();
         LevelManager.closeMouseEvent();
         this.superStone.gotoAndStop(2);
         setTimeout(this.superStonePlay,300);
      }
      
      private function superStonePlay() : void
      {
         var _loc1_:MovieClip = null;
         var _loc3_:uint = 0;
         var _loc2_:uint = uint(this.superStone.numChildren);
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this.superStone.getChildAt(_loc3_) as MovieClip;
            if(Boolean(_loc1_))
            {
               if(_loc1_.name == "colorMC")
               {
                  DisplayUtil.FillColor(_loc1_,MainManager.actorInfo.nonoColor);
               }
               if(_loc1_.name == "stoneMC")
               {
                  _loc1_.addEventListener(Event.ENTER_FRAME,this.sendToServer);
               }
            }
            _loc3_++;
         }
      }
      
      private function sendToServer(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.totalFrames == _loc2_.currentFrame)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.sendToServer);
            DisplayUtil.removeForParent(this.superStone);
            MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
            Stone.send(1);
            LevelManager.openMouseEvent();
         }
      }
      
      public function onWeightLessHouseClickHandler() : void
      {
         SocketConnection.addCmdListener(CommandID.NO_GRAVITY_SHIP,this.onSocketSuccessHandler);
         SocketConnection.send(CommandID.NO_GRAVITY_SHIP);
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         this.sinNum += 0.1;
         MainManager.actorModel.y += Math.sin(this.sinNum) * 20;
         MainManager.actorModel.x += Math.sin(this.sinNum) * 20;
      }
      
      private function onWalkEnd(param1:RobotEvent) : void
      {
         this.sinNum = 0;
      }
      
      private function onSocketSuccessHandler(param1:SocketEvent) : void
      {
         MainManager.actorModel.hideNono();
         LevelManager.closeMouseEvent();
         if(MainManager.actorInfo.superNono)
         {
            this.weightLessHouse.gotoAndPlay(3);
            this.weightLessHouse.addEventListener(Event.ENTER_FRAME,this.onFrameHandler("superNono"));
         }
         else
         {
            this.weightLessHouse.gotoAndPlay(2);
            this.weightLessHouse.addEventListener(Event.ENTER_FRAME,this.onFrameHandler("normalNono"));
         }
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         NonoManager.info.power = _loc3_ / 1000;
         NonoManager.info.mate = _loc4_ / 1000;
      }
      
      private function onFrameHandler(param1:String) : Function
      {
         var mcName:String = param1;
         var func:Function = function(param1:Event):void
         {
            var _loc2_:ColorTransform = null;
            if(Boolean(weightLessHouse.getChildByName(mcName)))
            {
               nonoSuit = (weightLessHouse.getChildByName(mcName) as MovieClip).getChildByName("nonoSuit") as MovieClip;
               _loc2_ = nonoSuit.transform.colorTransform;
               _loc2_.color = MainManager.actorInfo.nonoColor;
               nonoSuit.transform.colorTransform = _loc2_;
               nonoSuit.addEventListener(Event.ENTER_FRAME,onNonoSuitFrameHandler);
            }
         };
         return func;
      }
      
      private function onNonoSuitFrameHandler(param1:Event) : void
      {
         if(this.nonoSuit.currentFrame == this.nonoSuit.totalFrames)
         {
            this.nonoSuit.removeEventListener(Event.ENTER_FRAME,this.onNonoSuitFrameHandler);
            this.weightLessHouse.gotoAndStop(1);
            this.weightLessHouse.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler("*"));
            MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
            if(this.nonoSuit.parent.name == "superNono")
            {
               NpcTipDialog.show("O(∩_∩)O  NoNo精神满满，主人，你也要加油哦！！！",null,NpcTipDialog.NONO);
            }
            else
            {
               NpcTipDialog.show("O(∩_∩)O  NoNo精神满满，主人，你也要加油哦！！！",null,NpcTipDialog.NONO_2);
            }
            LevelManager.openMouseEvent();
         }
      }
      
      public function getGaussian(param1:Number = 0, param2:Number = 1) : Number
      {
         var _loc3_:Number = Math.random();
         var _loc4_:Number = Math.random();
         return Math.sqrt(-2 * Math.log(_loc3_)) * Math.cos(2 * Math.PI * _loc4_) * param2 + param1;
      }
   }
}

import com.robot.core.*;
import com.robot.core.config.xml.*;
import com.robot.core.info.task.*;
import com.robot.core.manager.*;
import com.robot.core.manager.map.*;
import com.robot.core.net.*;
import com.robot.core.ui.alert.*;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.*;
import org.taomee.events.SocketEvent;
import org.taomee.utils.*;

class Stone extends Sprite
{
   
   public static const CLEAR:String = "clear";
   
   private var mc:MovieClip;
   
   private var isHited:Boolean = false;
   
   private var sub:MovieClip;
   
   public function Stone(param1:uint)
   {
      super();
      this.mc = MapLibManager.getMovieClip("stone" + param1);
      this.mc["mc"].gotoAndStop(1);
      this.mc.cacheAsBitmap = true;
      addChild(this.mc);
      this.mc["light"].gotoAndStop(1);
      this.sub = this.mc["mc"];
      this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
      this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
   }
   
   public static function send(param1:uint) : void
   {
      var type:uint = param1;
      SocketConnection.addCmdListener(CommandID.HIT_STONE,function(param1:SocketEvent):void
      {
         var _loc3_:Object = null;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         SocketConnection.removeCmdListener(CommandID.HIT_STONE,arguments.callee);
         var _loc8_:BossMonsterInfo = param1.data as BossMonsterInfo;
         for each(_loc3_ in _loc8_.monBallList)
         {
            _loc4_ = uint(_loc3_["itemCnt"]);
            _loc5_ = uint(_loc3_["itemID"]);
            _loc6_ = ItemXMLInfo.getName(_loc5_);
            if(_loc5_ < 10)
            {
               _loc7_ = "恭喜你得到了" + _loc4_ + "个<font color=\'#FF0000\'>" + _loc6_ + "</font>";
               LevelManager.tipLevel.addChild(Alarm.show(_loc7_));
            }
            else
            {
               _loc7_ = _loc4_ + "个<font color=\'#FF0000\'>" + _loc6_ + "</font>已经放入了你的储存箱！";
               LevelManager.tipLevel.addChild(ItemInBagAlert.show(_loc5_,_loc7_));
            }
         }
      });
      SocketConnection.send(CommandID.HIT_STONE,type);
   }
   
   private function onOver(param1:MouseEvent) : void
   {
      this.mc["light"].gotoAndPlay(2);
   }
   
   private function onOut(param1:MouseEvent) : void
   {
      this.mc["light"].gotoAndStop(1);
   }
   
   public function play() : void
   {
      if(!this.isHited)
      {
         this.isHited = true;
         this.sub.gotoAndPlay(2);
         this.mc["light"].visible = false;
         this.sub.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
   }
   
   private function onEnter(param1:Event) : void
   {
      if(this.sub.currentFrame == this.sub.totalFrames)
      {
         this.sub.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         DisplayUtil.removeForParent(this);
         dispatchEvent(new Event(CLEAR));
         send(0);
      }
   }
}
