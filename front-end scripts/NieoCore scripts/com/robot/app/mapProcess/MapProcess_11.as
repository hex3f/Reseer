package com.robot.app.mapProcess
{
   import com.robot.app.task.SeerInstructor.*;
   import com.robot.core.animate.*;
   import com.robot.core.event.*;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.ActorModel;
   import com.robot.core.mode.PetModel;
   import com.robot.core.ui.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import gs.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_11 extends BaseMapProcess
   {
      
      private var balkMC:MovieClip;
      
      private var clickMC:MovieClip;
      
      private var catchTimer:Timer;
      
      private var isCacthing:Boolean = false;
      
      private var isFlower:Boolean = false;
      
      private var _plantMc:MovieClip;
      
      public function MapProcess_11()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:DialogBox = null;
         UserManager.addActionListener(MainManager.actorID,this.onAction);
         this.balkMC = typeLevel["balkMC"];
         this.clickMC = conLevel["clickMC"];
         this.clickMC.addEventListener(MouseEvent.CLICK,this.showTip);
         if(Boolean(MainManager.actorModel.nono))
         {
            if(MainManager.actorInfo.superNono)
            {
               DisplayUtil.removeForParent(this.balkMC);
               DisplayUtil.removeForParent(this.clickMC);
               MapManager.currentMap.makeMapArray();
            }
         }
         var _loc2_:Array = MainManager.actorInfo.clothIDs;
         if(_loc2_.indexOf(100011) != -1)
         {
            DisplayUtil.removeForParent(this.balkMC);
            DisplayUtil.removeForParent(this.clickMC);
            MapManager.currentMap.makeMapArray();
         }
         NewInstructorContoller.chekWaste();
         this.catchTimer = new Timer(5 * 1000,1);
         this.catchTimer.addEventListener(TimerEvent.TIMER,this.onCatchTimer);
         if(TasksManager.getTaskStatus(403) == TasksManager.COMPLETE)
         {
            this.isFlower = true;
            conLevel["flowerMC"].gotoAndStop("live");
         }
         else
         {
            _loc1_ = new DialogBox();
            _loc1_.show("好想要新鲜空气和阳光啊",0,-20,conLevel["flowerMC"]);
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:ActorModel = MainManager.actorModel;
         _loc1_.removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         this.clickMC.removeEventListener(MouseEvent.CLICK,this.showTip);
         UserManager.removeActionListener(MainManager.actorID,this.onAction);
         this.balkMC = null;
         this.catchTimer.stop();
         this.catchTimer.removeEventListener(TimerEvent.TIMER,this.onCatchTimer);
         this.catchTimer = null;
      }
      
      private function onAction(param1:PeopleActionEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:PeopleItemInfo = null;
         switch(param1.actionType)
         {
            case PeopleActionEvent.CLOTH_CHANGE:
               _loc2_ = param1.data as Array;
               _loc3_ = [];
               for each(_loc4_ in _loc2_)
               {
                  _loc3_.push(_loc4_.id);
               }
               if(_loc3_.indexOf(100011) != -1)
               {
                  DisplayUtil.removeForParent(this.balkMC);
                  DisplayUtil.removeForParent(this.clickMC);
                  MapManager.currentMap.makeMapArray();
                  break;
               }
               typeLevel.addChild(this.balkMC);
               conLevel.addChild(this.clickMC);
               if(this.clickMC.hitTestPoint(MainManager.actorModel.pos.x,MainManager.actorModel.pos.y,true))
               {
                  MainManager.actorModel.walkAction(new Point(608,245));
               }
               MapManager.currentMap.makeMapArray();
         }
      }
      
      public function onPlantClickHandler(param1:MouseEvent) : void
      {
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MapManager.addEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapDown);
         MainManager.actorModel.walkAction(new Point(450,230));
      }
      
      private function onWalk(param1:Event) : void
      {
         if(Math.abs(Point.distance(new Point(450,230),MainManager.actorModel.pos)) < 30)
         {
            this.onMapDown(null);
            MainManager.actorModel.stop();
            MapManager.changeMap(13);
         }
      }
      
      private function onMapDown(param1:MapEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,this.onMapDown);
      }
      
      private function showTip(param1:MouseEvent) : void
      {
         Alarm.show("你必须穿上" + TextFormatUtil.getRedTxt("履带") + "才能进入沼泽哦！\n" + "(你可以在" + TextFormatUtil.getRedTxt("机械室") + "的" + TextFormatUtil.getRedTxt("赛尔工厂") + "中购买到)");
      }
      
      public function clearWaste() : void
      {
         NewInstructorContoller.setWaste();
      }
      
      public function hitFlower() : void
      {
         var _loc1_:String = null;
         var _loc2_:uint = 0;
         if(this.isCacthing || this.isFlower)
         {
            return;
         }
         if(TasksManager.getTaskStatus(403) == TasksManager.UN_ACCEPT)
         {
            _loc1_ = "你还没有领取" + TextFormatUtil.getRedTxt("小医生布布") + "任务呢，" + "快点击右上角的" + TextFormatUtil.getRedTxt("精灵训练营") + "按钮看看吧！";
            Alarm.show(_loc1_);
            return;
         }
         var _loc3_:ActorModel = MainManager.actorModel;
         var _loc4_:PetModel = _loc3_.pet;
         if(Boolean(_loc4_))
         {
            _loc2_ = uint(_loc4_.info.petID);
            if(this.check(_loc2_))
            {
               _loc3_.addEventListener(RobotEvent.WALK_START,this.onWalkStart);
               this.catchTimer.stop();
               this.catchTimer.reset();
               this.catchTimer.start();
               this.isCacthing = true;
               if(_loc2_ == 1 || _loc2_ == 301)
               {
                  conLevel["effectMC"].gotoAndStop("one");
                  topLevel["movie"].gotoAndStop("one");
               }
               else if(_loc2_ == 2 || _loc2_ == 302)
               {
                  conLevel["effectMC"].gotoAndStop("two");
                  topLevel["movie"].gotoAndStop("two");
               }
               else if(_loc2_ == 3 || _loc2_ == 303)
               {
                  conLevel["effectMC"].gotoAndStop("three");
                  topLevel["movie"].gotoAndStop("three");
               }
               TweenLite.to(topLevel["movie"],1,{
                  "x":(MainManager.getStageWidth() - topLevel["movie"].width) / 2,
                  "onComplete":this.onComp
               });
               PetManager.showCurrent();
            }
            else
            {
               Alarm.show("你必须带上<font color=\'#ff0000\'>布布种子、布布草、布布花、黄金布布、蒙娜布布、丽莎布布</font>的其中一个才能给克洛斯花补充活力哦！");
               conLevel["effectMC"].gotoAndStop(1);
            }
         }
         else
         {
            Alarm.show("你必须带上<font color=\'#ff0000\'>布布种子、布布草、布布花、黄金布布、蒙娜布布、丽莎布布</font>的其中一个才能给克洛斯花补充活力哦！");
            conLevel["effectMC"].gotoAndStop(1);
         }
      }
      
      private function check(param1:uint) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc2_:Array = [1,2,3,301,302,303];
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_] == param1)
            {
               return true;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function onComp() : void
      {
         setTimeout(this.closeFlower,2000);
      }
      
      private function closeFlower() : void
      {
         try
         {
            topLevel["movie"].x = 1075;
         }
         catch(e:Error)
         {
         }
      }
      
      private function onCatchTimer(param1:TimerEvent) : void
      {
         this.isCacthing = false;
         TasksManager.complete(403,0,this.onSuccess);
      }
      
      private function onSuccess(param1:Boolean) : void
      {
         this.isFlower = param1;
         if(this.isFlower)
         {
            conLevel["flowerMC"].gotoAndStop("live");
            conLevel["effectMC"].gotoAndStop(1);
            PetManager.showCurrent();
         }
         else
         {
            Alarm.show("这次补充活力似乎没有起到效果，再试试吧！");
         }
      }
      
      private function onWalkStart(param1:RobotEvent) : void
      {
         if(this.isCacthing)
         {
            Alarm.show("随便走动是无法为克洛斯花补充能量的哦！");
            this.isCacthing = false;
            this.catchTimer.stop();
            conLevel["effectMC"].gotoAndStop(1);
            PetManager.showCurrent();
         }
      }
   }
}

