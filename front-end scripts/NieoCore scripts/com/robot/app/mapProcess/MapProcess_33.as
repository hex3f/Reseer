package com.robot.app.mapProcess
{
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.ui.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   
   public class MapProcess_33 extends BaseMapProcess
   {
      
      private var isShow:Boolean;
      
      private var powerMc:MovieClip;
      
      private var point:Point;
      
      public function MapProcess_33()
      {
         super();
      }
      
      override protected function init() : void
      {
         if(TasksManager.getTaskStatus(10) == TasksManager.COMPLETE)
         {
            this.isShow = false;
            conLevel["lightMc"].gotoAndStop(2);
            conLevel["maskMc"].gotoAndPlay(2);
            conLevel["iconMc"].gotoAndStop(5);
            this.configKey();
            return;
         }
         if(TasksManager.getTaskStatus(10) == TasksManager.UN_ACCEPT)
         {
            this.isShow = true;
            this.configLock();
            conLevel["iconMc"].gotoAndStop(1);
            TasksManager.accept(10);
            return;
         }
         if(TasksManager.getTaskStatus(10) == TasksManager.ALR_ACCEPT)
         {
            this.isShow = true;
            conLevel["maskMc"].gotoAndPlay(2);
            conLevel["iconMc"].gotoAndStop(1);
            this.configLock();
            this.configKey();
         }
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:DialogBox = new DialogBox();
         _loc2_.show("墙上的奇怪图案是一位赫星长老的留言。",0,-80,depthLevel["aliceMc"]);
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         if(this.isShow)
         {
            _loc1_ = 0;
            while(_loc1_ < 9)
            {
               conLevel["lockMc"]["mc" + _loc1_].removeEventListener(MouseEvent.CLICK,this.onClickHandler);
               _loc1_++;
            }
         }
      }
      
      private function configLock() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:int = 0;
         while(_loc2_ < 9)
         {
            _loc1_ = uint(uint(Math.random() * 4) + 1);
            conLevel["lockMc"]["mc" + _loc2_].buttonMode = true;
            conLevel["lockMc"]["mc" + _loc2_].gotoAndStop(_loc1_);
            conLevel["lockMc"]["mc" + _loc2_].addEventListener(MouseEvent.CLICK,this.onClickHandler);
            _loc2_++;
         }
      }
      
      private function onClickHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget.currentFrame == param1.currentTarget.totalFrames)
         {
            param1.currentTarget.gotoAndStop(1);
         }
         else
         {
            param1.currentTarget.gotoAndStop(param1.currentTarget.currentFrame + 1);
         }
         if(this.checkSuccess())
         {
            conLevel["iconMc"].gotoAndPlay(1);
            conLevel["maskMc"].gotoAndPlay(2);
            conLevel["lightMc"].gotoAndStop(2);
            conLevel["lockMc"].mouseChildren = false;
            this.configKey();
            TasksManager.complete(10,1);
         }
      }
      
      private function checkSuccess() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < 9)
         {
            if(conLevel["lockMc"]["mc" + _loc1_].currentFrame != 1)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      private function configKey() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 8)
         {
            conLevel["key" + _loc1_].buttonMode = true;
            conLevel["key" + _loc1_].addEventListener(MouseEvent.MOUSE_DOWN,this.onKeyDownHandler);
            _loc1_++;
         }
      }
      
      private function onKeyDownHandler(param1:MouseEvent) : void
      {
         this.powerMc = param1.currentTarget as MovieClip;
         this.point = new Point(this.powerMc.x,this.powerMc.y);
         if(conLevel.getChildIndex(conLevel["doorMc"]) > conLevel.getChildIndex(this.powerMc))
         {
            conLevel.swapChildren(conLevel["doorMc"],this.powerMc);
         }
         this.powerMc.startDrag();
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
      }
      
      private function onUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         this.powerMc.stopDrag();
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
         if(conLevel.getChildIndex(conLevel["doorMc"]) < conLevel.getChildIndex(this.powerMc))
         {
            conLevel.swapChildren(conLevel["doorMc"],this.powerMc);
         }
         if(this.powerMc.hitTestObject(conLevel["hitMc"]) && this.powerMc == conLevel["key0"])
         {
            _loc2_ = 0;
            while(_loc2_ < 8)
            {
               conLevel["key" + _loc2_].buttonMode = false;
               conLevel["key" + _loc2_].removeEventListener(MouseEvent.MOUSE_DOWN,this.onKeyDownHandler);
               _loc2_++;
            }
            conLevel["doorMc"].addEventListener(Event.ENTER_FRAME,this.onEnterHandler);
            conLevel["doorMc"].gotoAndPlay(2);
            this.powerMc.visible = false;
         }
         else
         {
            this.powerMc.x = this.point.x;
            this.powerMc.y = this.point.y;
         }
      }
      
      private function onEnterHandler(param1:Event) : void
      {
         if(conLevel["doorMc"].currentFrame == conLevel["doorMc"].totalFrames)
         {
            conLevel["doorMc"].removeEventListener(Event.ENTER_FRAME,this.onEnterHandler);
         }
      }
   }
}

