package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.*;
   import com.robot.app.fightNote.*;
   import com.robot.app.task.UnbelievableSpriteScholar.*;
   import com.robot.app.task.process.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.aimat.*;
   import com.robot.core.event.*;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_34 extends BaseMapProcess
   {
      
      private var _currYin:MovieClip;
      
      private var _currIndex:int = 0;
      
      private var mcA:Array;
      
      private var hitA:Array;
      
      private var curNameIndex:Number;
      
      private var curMc:MovieClip;
      
      private var curPoint:Point;
      
      private var time:uint = 0;
      
      private var _yaModel:OgreModel;
      
      private var shitou:MovieClip;
      
      private var xiangzi:MovieClip;
      
      public function MapProcess_34()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:String = null;
         var _loc2_:MovieClip = null;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         conLevel["lidMc"].gotoAndPlay(60);
         ToolTipManager.add(conLevel["door_0"],"神秘通道");
         while(_loc4_ < 3)
         {
            conLevel["yin_" + _loc4_.toString()].gotoAndStop(1);
            conLevel["yin_" + _loc4_.toString()].visible = false;
            _loc4_++;
         }
         this._currYin = conLevel["yin_" + this._currIndex.toString()];
         conLevel["treeMc"].buttonMode = true;
         conLevel["treeMc"].addEventListener(MouseEvent.CLICK,this.onTreeHandler);
         DisplayUtil.removeForParent(conLevel["tengmanMC"]);
         DisplayUtil.removeForParent(conLevel["templeDoorMC"]);
         DisplayUtil.removeForParent(conLevel["huahuaguoMC"]);
         while(_loc5_ < 6)
         {
            _loc1_ = "matter_" + _loc5_;
            _loc2_ = MapManager.currentMap.depthLevel.getChildByName(_loc1_) as MovieClip;
            DisplayUtil.removeForParent(_loc2_);
            _loc2_ = null;
            _loc5_++;
         }
         var _loc6_:MovieClip = MapManager.currentMap.depthLevel.getChildByName("chosSuccseMC") as MovieClip;
         DisplayUtil.removeForParent(_loc6_);
         _loc6_ = null;
         var _loc7_:MovieClip = MapManager.currentMap.depthLevel.getChildByName("chosFalseMC") as MovieClip;
         DisplayUtil.removeForParent(_loc7_);
         _loc7_ = null;
         this.shitou = conLevel["shitou"] as MovieClip;
         this.shitou.visible = false;
         this.xiangzi = conLevel["xiangzi"] as MovieClip;
         this.xiangzi.alpha = 0;
         if(TasksManager.getTaskStatus(12) == TasksManager.COMPLETE)
         {
            this.check();
            animatorLevel.visible = false;
            _loc3_ = 1;
            while(_loc3_ < 5)
            {
               conLevel["mc" + _loc3_].visible = false;
               conLevel["hit" + _loc3_].gotoAndPlay(2);
               conLevel["treeMc"].gotoAndStop(4);
               _loc3_++;
            }
            return;
         }
         if(TasksManager.getTaskStatus(12) == TasksManager.ALR_ACCEPT)
         {
            this.configStone();
            return;
         }
         if(TasksManager.getTaskStatus(12) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(12,this.acHandler);
            return;
         }
      }
      
      private function acHandler(param1:Boolean) : void
      {
         if(param1)
         {
            this.configStone();
         }
      }
      
      private function configStone() : void
      {
         this.mcA = [1,2,3,4];
         this.hitA = [1,2,3,4];
         this.time = 0;
         var _loc1_:uint = 1;
         while(_loc1_ < 5)
         {
            conLevel["mc" + _loc1_].buttonMode = true;
            conLevel["mc" + _loc1_].addEventListener(MouseEvent.MOUSE_DOWN,this.onDownHandler);
            _loc1_++;
         }
      }
      
      private function onTreeHandler(param1:MouseEvent) : void
      {
         ++this.time;
         if(this.time > 3)
         {
            return;
         }
         conLevel["treeMc"].gotoAndStop(this.time + 1);
         if(this.time == 3)
         {
            conLevel["mc4"].gotoAndPlay(2);
         }
      }
      
      public function clickTengman() : void
      {
      }
      
      public function clickTempleDoor() : void
      {
         OpenTempleDoorController.show();
      }
      
      public function oreHandler() : void
      {
         var _loc1_:String = NpcTipDialog.IRIS;
         NpcTipDialog.show("神秘的精灵圣殿被奇怪的晶体藤蔓缠绕着无法开启，得到电能锯子的赛尔们，快来帮忙吧！采集到的藤结晶可以拿到动力室换取赛尔豆哦！",this.handler,_loc1_);
      }
      
      private function handler() : void
      {
         EnergyController.exploit();
      }
      
      private function onDownHandler(param1:MouseEvent) : void
      {
         this.curPoint = new Point();
         this.curNameIndex = Number((param1.currentTarget as MovieClip).name.slice(2,3));
         this.curMc = param1.currentTarget as MovieClip;
         this.curPoint.x = param1.currentTarget.x;
         this.curPoint.y = param1.currentTarget.y;
         this.curMc.startDrag();
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_UP,this.onUphandler);
      }
      
      private function onUphandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         this.curMc.stopDrag();
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUphandler);
         while(_loc3_ < this.hitA.length)
         {
            if(this.curMc.hitTestObject(conLevel["hit" + this.hitA[_loc3_]]))
            {
               conLevel["hit" + this.hitA[_loc3_]].gotoAndPlay(2);
               this.curMc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDownHandler);
               DisplayUtil.removeForParent(this.curMc);
               this.curMc = null;
               _loc2_ = int(this.hitA.indexOf(this.hitA[_loc3_]));
               this.hitA.splice(_loc2_,1);
               _loc2_ = int(this.mcA.indexOf(this.curNameIndex));
               this.mcA.splice(_loc2_,1);
               if(this.hitA.length == 0)
               {
                  if(TasksManager.getTaskStatus(12) != TasksManager.COMPLETE)
                  {
                     TasksManager.complete(12,1);
                  }
                  animatorLevel.visible = false;
                  this.check();
               }
               return;
            }
            _loc3_++;
         }
         this.curMc.x = this.curPoint.x;
         this.curMc.y = this.curPoint.y;
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         ToolTipManager.remove(conLevel["door_0"]);
         this.onMapDown();
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimatEnd);
         this._currYin.removeEventListener(Event.ENTER_FRAME,this.onYinEnter);
         this._currYin.stop();
         this._currYin = null;
         if(Boolean(this.mcA))
         {
            if(this.mcA.length > 0)
            {
               _loc1_ = 0;
               while(_loc1_ < this.mcA.length)
               {
                  conLevel["mc" + this.mcA[_loc1_]].removeEventListener(MouseEvent.MOUSE_DOWN,this.onDownHandler);
                  _loc1_++;
               }
            }
         }
         if(Boolean(this._yaModel))
         {
            this._yaModel.removeEventListener(RobotEvent.OGRE_CLICK,this.onYaClick);
            this._yaModel.destroy();
            this._yaModel = null;
         }
      }
      
      private function check() : void
      {
         if(TaskProcess_11.isCatch)
         {
            return;
         }
         if(TasksManager.getTaskStatus(11) != TasksManager.COMPLETE)
         {
            this._currYin.gotoAndPlay(2);
            this._currYin.visible = true;
            this._currYin.addEventListener(Event.ENTER_FRAME,this.onYinEnter);
            TaskProcess_11.start();
            AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimatEnd);
         }
      }
      
      private function onYinEnter(param1:Event) : void
      {
         if(this._currYin.currentFrame == this._currYin.totalFrames)
         {
            this._currYin.removeEventListener(Event.ENTER_FRAME,this.onYinEnter);
            this._currYin.gotoAndStop(1);
            this._currYin.visible = false;
            ++this._currIndex;
            if(this._currIndex >= 3)
            {
               this._currIndex = 0;
            }
            this._currYin = conLevel["yin_" + this._currIndex.toString()];
            this._currYin.addEventListener(Event.ENTER_FRAME,this.onYinEnter);
            this._currYin.gotoAndPlay(2);
            this._currYin.visible = true;
         }
      }
      
      private function onAimatEnd(param1:AimatEvent) : void
      {
         var _loc2_:AimatInfo = param1.info;
         if(_loc2_.userID == MainManager.actorID)
         {
            if(_loc2_.id == 10003)
            {
               if(Boolean(this._currYin))
               {
                  if(this._currYin.hitTestPoint(_loc2_.endPos.x,_loc2_.endPos.y))
                  {
                     this._currYin.removeEventListener(Event.ENTER_FRAME,this.onYinEnter);
                     this._currYin.gotoAndStop(1);
                     this._currYin.visible = false;
                     this._yaModel = new OgreModel(0);
                     this._yaModel.show(74,_loc2_.endPos);
                     this._yaModel.addEventListener(RobotEvent.OGRE_CLICK,this.onYaClick);
                  }
               }
            }
         }
      }
      
      private function onYaClick(param1:Event) : void
      {
         if(Point.distance(this._yaModel.pos,MainManager.actorModel.pos) < 40)
         {
            MainManager.actorModel.stop();
            FightInviteManager.fightWithBoss("果冻鸭");
            return;
         }
         MapManager.addEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapDown);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
         MainManager.actorModel.walkAction(this._yaModel.pos);
      }
      
      private function onWalkEnter(param1:Event) : void
      {
         if(Point.distance(this._yaModel.pos,MainManager.actorModel.pos) < 40)
         {
            this.onMapDown();
            MainManager.actorModel.stop();
            FightInviteManager.fightWithBoss("果冻鸭");
         }
      }
      
      private function onMapDown(param1:MapEvent = null) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapDown);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnter);
      }
      
      public function changeToHandler() : void
      {
         conLevel["lidMc"].addEventListener(Event.ENTER_FRAME,this.onEntHandler);
         conLevel["lidMc"].gotoAndPlay(60);
      }
      
      private function onEntHandler(param1:Event) : void
      {
         if(conLevel["lidMc"].currentFrame == 70)
         {
            conLevel["lidMc"].removeEventListener(Event.ENTER_FRAME,this.onEntHandler);
            MapManager.changeMap(33);
         }
      }
      
      public function onClickShitou() : void
      {
      }
      
      private function onClickXiangzi(param1:MouseEvent) : void
      {
         this.xiangzi.removeEventListener(MouseEvent.CLICK,this.onClickXiangzi);
         DisplayUtil.removeForParent(this.shitou);
         this.shitou = null;
         DisplayUtil.removeForParent(this.xiangzi);
         this.xiangzi = null;
         NpcTipDialog.show("恭喜你已经找到了遗迹宝箱，据这些机械残骸看来可能是属于机械精灵的，不过我们现在还缺少机械图纸，再去<font color=\'#ff0000\'>赫尔卡星</font>其他地方找找吧",null,NpcTipDialog.DOCTOR,-80);
         TasksManager.complete(28,0);
      }
   }
}

