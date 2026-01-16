package com.robot.core.mode
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.NpcTaskInfo;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcInfo;
   import com.robot.core.ui.DialogBox;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   [Event(name="npcClick",type="com.robot.core.event.NpcEvent")]
   [Event(name="taskWithoutDes",type="com.robot.core.event.NpcEvent")]
   public class NpcModel extends BasePeoleModel
   {
      
      private var _taskInfo:NpcTaskInfo;
      
      private var _npc:Sprite;
      
      private var clickPoint:Point;
      
      private var _npcHit:Sprite;
      
      private var questionMark:MovieClip;
      
      private var excalMark:MovieClip;
      
      private var _type:String;
      
      private var _id:uint;
      
      private var dialogList:Array;
      
      public var des:String;
      
      private var timer:Timer;
      
      private var _npcInfo:NpcInfo;
      
      private var diaUint:uint = 0;
      
      private var posList:Array;
      
      private var npcTimer:Timer;
      
      public function NpcModel(param1:NpcInfo, param2:Sprite)
      {
         var _loc3_:Number = 0;
         this.dialogList = [];
         this.posList = [new Point(280,291),new Point(420,340),new Point(611,427),new Point(200,500)];
         this._npcInfo = param1;
         this._id = this._npcInfo.npcId;
         this._type = this._npcInfo.type;
         this._npc = param2;
         this._npcHit = this._npc;
         this.des = this._npcInfo.dialogList[0];
         this.dialogList = this._npcInfo.bubbingList;
         this.questionMark = AssetsManager.getMovieClip("lib_question_mark");
         this.excalMark = AssetsManager.getMovieClip("lib_excalmatory_mark");
         this.setNpcTaskIDs(this._npcInfo.startIDs,this._npcInfo.endIDs,this._npcInfo.proIDs);
         var _loc4_:UserInfo = new UserInfo();
         _loc4_.nick = this._npcInfo.npcName;
         if(this._id == 90001)
         {
            _loc4_.direction = 2;
         }
         else
         {
            _loc4_.direction = 3;
         }
         if(this._npcInfo.clothIds.length == 0)
         {
            MapManager.currentMap.depthLevel.addChild(this._npc);
            this._npc.x = this._npcInfo.point.x;
            this._npc.y = this._npcInfo.point.y;
            DepthManager.swapDepthAll(MapManager.currentMap.depthLevel);
         }
         else
         {
            for each(_loc3_ in this._npcInfo.clothIds)
            {
               _loc4_.clothes.push(new PeopleItemInfo(_loc3_));
            }
            _loc4_.color = this._npcInfo.color;
         }
         this._npc.buttonMode = true;
         super(_loc4_);
         this.initNpc();
         this._npc.addEventListener(MouseEvent.CLICK,this.clickNpc);
         this.initDialog();
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      private function initDialog() : void
      {
         var _loc1_:DialogBox = null;
         this.timer = new Timer(9000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         if(this.dialogList.length > 0)
         {
            this.timer.start();
            if(this.diaUint == this.dialogList.length - 1)
            {
               this.diaUint = 0;
            }
            else
            {
               ++this.diaUint;
            }
            if(this.dialogList[this.diaUint] == "")
            {
               return;
            }
            _loc1_ = new DialogBox();
            _loc1_.show(this.dialogList[this.diaUint],0,-100,this._npc);
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this.diaUint == this.dialogList.length - 1)
         {
            this.diaUint = 0;
         }
         else
         {
            ++this.diaUint;
         }
         if(this.dialogList[this.diaUint] == "")
         {
            return;
         }
         var _loc2_:DialogBox = new DialogBox();
         _loc2_.show(this.dialogList[this.diaUint],0,-100,this._npc);
      }
      
      public function refreshTask() : void
      {
         DisplayUtil.removeForParent(this.questionMark,false);
         DisplayUtil.removeForParent(this.excalMark,false);
         if(Boolean(this._taskInfo))
         {
            this._taskInfo.refresh();
         }
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      override public function get name() : String
      {
         return this._npcInfo.npcName;
      }
      
      private function clickNpc(param1:MouseEvent) : void
      {
         if(this.npcInfo.npcId >= 90002)
         {
            MainManager.actorModel.walkAction(this.pos);
            MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
         }
         else
         {
            this.clickPoint = this._npcHit.localToGlobal(new Point(this._npcInfo.offSetPoint.x,this._npcInfo.offSetPoint.y));
            MainManager.actorModel.walkAction(this.clickPoint);
            this._npcHit.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onWalkEnter(param1:RobotEvent) : void
      {
         if(Point.distance(pos,MainManager.actorModel.pos) < 60)
         {
            if(Boolean(this.npcTimer))
            {
               this.npcTimer.reset();
               this.npcTimer.start();
            }
            MainManager.actorModel.stop();
            MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
            MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapClick);
            this.dispatchEvent(new NpcEvent(NpcEvent.NPC_CLICK,this));
         }
      }
      
      private function onMapClick(param1:MapEvent) : void
      {
         if(Boolean(this.npcTimer))
         {
            this.npcTimer.reset();
            this.npcTimer.start();
         }
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
         MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapClick);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Point = MainManager.actorModel.sprite.localToGlobal(new Point());
         if(Point.distance(_loc2_,this.clickPoint) < 15)
         {
            MainManager.actorModel.skeleton.stop();
            this._npcHit.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            if(TasksManager.getTaskStatus(25) == TasksManager.ALR_ACCEPT && this._id == 1)
            {
               NpcTaskManager.dispatchEvent(new Event("50001"));
            }
            if(this._taskInfo.completeList.length > 0)
            {
               EventManager.dispatchEvent(new NpcEvent(NpcEvent.COMPLETE_TASK,this));
            }
            else
            {
               EventManager.dispatchEvent(new NpcEvent(NpcEvent.SHOW_TASK_LIST,this));
            }
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this._taskInfo))
         {
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_BLUE_QUESTION,this.showBlueQuestion);
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_YELLOW_EXCAL,this.showYellowExcal);
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_YELLOW_QUESTION,this.showYellowQuestion);
            this._taskInfo.destroy();
         }
         this._taskInfo = null;
         this._npcHit.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._npc = null;
         this._npcHit = null;
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
         if(Boolean(this.npcTimer))
         {
            this.npcTimer.stop();
            this.npcTimer.removeEventListener(TimerEvent.TIMER,this.onNpcTimer);
         }
         this.npcTimer = null;
         this._taskInfo = null;
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
         MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapClick);
      }
      
      private function showBlueQuestion(param1:Event) : void
      {
         var _loc2_:Number = this.npc.height;
         if(_loc2_ > 110)
         {
            _loc2_ = 120;
         }
         this.questionMark.y = -_loc2_;
         this.npc.addChild(this.questionMark);
         this.questionMark.gotoAndStop(1);
      }
      
      private function showYellowExcal(param1:Event) : void
      {
         if(this._taskInfo.isRelateTask)
         {
            return;
         }
         var _loc2_:Number = this.npc.height;
         if(_loc2_ > 110)
         {
            _loc2_ = 120;
         }
         this.excalMark.y = -_loc2_;
         this.npc.addChild(this.excalMark);
      }
      
      private function showYellowQuestion(param1:Event) : void
      {
         var _loc2_:Number = this.npc.height;
         if(_loc2_ > 110)
         {
            _loc2_ = 120;
         }
         this.questionMark.y = -_loc2_;
         this.npc.addChild(this.questionMark);
         this.questionMark.gotoAndStop(2);
      }
      
      public function get npc() : Sprite
      {
         return this._npc;
      }
      
      public function hide() : void
      {
         if(Boolean(this._npc))
         {
            this._npc.visible = false;
         }
      }
      
      public function show() : void
      {
         if(Boolean(this._npc))
         {
            this._npc.visible = true;
         }
      }
      
      public function setNpcTaskIDs(param1:Array, param2:Array, param3:Array) : void
      {
         if(Boolean(this._taskInfo))
         {
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_BLUE_QUESTION,this.showBlueQuestion);
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_YELLOW_EXCAL,this.showYellowExcal);
            this._taskInfo.removeEventListener(NpcTaskInfo.SHOW_YELLOW_QUESTION,this.showYellowQuestion);
            this._taskInfo.destroy();
         }
         DisplayUtil.removeForParent(this.questionMark,false);
         DisplayUtil.removeForParent(this.excalMark,false);
         this._taskInfo = new NpcTaskInfo(param1,param2,param3,this);
         this._taskInfo.addEventListener(NpcTaskInfo.SHOW_BLUE_QUESTION,this.showBlueQuestion);
         this._taskInfo.addEventListener(NpcTaskInfo.SHOW_YELLOW_EXCAL,this.showYellowExcal);
         this._taskInfo.addEventListener(NpcTaskInfo.SHOW_YELLOW_QUESTION,this.showYellowQuestion);
         this._taskInfo.checkTaskStatus();
      }
      
      public function get taskInfo() : NpcTaskInfo
      {
         return this._taskInfo;
      }
      
      private function initNpc() : void
      {
         if(this.id != NPC.IRIS && this.id < 90000)
         {
            return;
         }
         clickBtn.mouseChildren = clickBtn.mouseEnabled = false;
         var _loc1_:MovieClip = AssetsManager.getMovieClip("npc_shadow_mc");
         _loc1_.y += 15;
         addChildAt(_loc1_,0);
         this.mouseEnabled = true;
         this._npc = this;
         this._npcHit = this;
         this.buttonMode = true;
         _skeletonSys.getBodyMC().filters = [new GlowFilter(3355443,1,4,4)];
         _skeletonSys.getBodyMC().scaleX = _skeletonSys.getBodyMC().scaleY = 1.4;
         DisplayUtil.removeForParent(_skeletonSys.getSkeletonMC()["clickBtn"]);
         var _loc2_:TextField = _nameTxt;
         _loc2_.y += 15;
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.size = 14;
         _loc3_.color = 26367;
         _loc2_.setTextFormat(_loc3_);
         _loc2_.filters = [new GlowFilter(16777215,1,3,3,5)];
         this.pos = new Point(704,405);
         if(this.id < 90000)
         {
            this.npcTimer = new Timer(3000,0);
            this.npcTimer.addEventListener(TimerEvent.TIMER,this.onNpcTimer);
            this.npcTimer.start();
         }
         MapManager.currentMap.depthLevel.addChild(this);
         this.pos = this._npcInfo.point;
      }
      
      private function onNpcTimer(param1:TimerEvent) : void
      {
         var _loc2_:Point = this.posList[Math.floor(Math.random() * this.posList.length)];
         while(_loc2_.x == this.pos.x && _loc2_.y == this.pos.y)
         {
            _loc2_ = this.posList[Math.floor(Math.random() * this.posList.length)];
         }
         _walk.execute_point(this,_loc2_,false);
      }
      
      override protected function onWalkEnd(param1:Event) : void
      {
         _skeletonSys.stop();
         this.npcTimer.reset();
         this.npcTimer.start();
      }
      
      public function get npcInfo() : NpcInfo
      {
         return this._npcInfo;
      }
   }
}

