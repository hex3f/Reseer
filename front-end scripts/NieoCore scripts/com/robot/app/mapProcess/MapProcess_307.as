package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.*;
   import flash.events.*;
   import flash.ui.*;
   import flash.utils.*;
   
   public class MapProcess_307 extends BaseMapProcess
   {
      
      private var line_0:MovieClip;
      
      private var line_1:MovieClip;
      
      private var line_2:MovieClip;
      
      private var plug_0:MovieClip;
      
      private var plug_1:MovieClip;
      
      private var plug_2:MovieClip;
      
      private var xiantou:MovieClip;
      
      private var clickLine:MovieClip;
      
      private var canConnected:Boolean = false;
      
      private var isClick:Boolean = false;
      
      private var checkArr:Array = [];
      
      private var rightArr:Array = [];
      
      private var count:uint = 0;
      
      private var plugArr:Array = [];
      
      private var dianliu:MovieClip;
      
      private var xita:MovieClip;
      
      public function MapProcess_307()
      {
         super();
      }
      
      override protected function init() : void
      {
         MazeController.setup();
         this.line_0 = conLevel["line_0"];
         this.line_1 = conLevel["line_1"];
         this.line_2 = conLevel["line_2"];
         this.line_0.buttonMode = true;
         this.line_1.buttonMode = true;
         this.line_2.buttonMode = true;
         this.line_0.mouseChildren = false;
         this.line_1.mouseChildren = false;
         this.line_2.mouseChildren = false;
         this.plug_0 = conLevel["plug_0"];
         this.plug_1 = conLevel["plug_1"];
         this.plug_2 = conLevel["plug_2"];
         this.plug_0.buttonMode = true;
         this.plug_1.buttonMode = true;
         this.plug_2.buttonMode = true;
         this.plug_0.mouseEnabled = false;
         this.plug_1.mouseEnabled = false;
         this.plug_2.mouseEnabled = false;
         this.plugArr = [this.plug_0,this.plug_1,this.plug_2];
         this.dianliu = conLevel["dianliu"];
         this.line_0.addEventListener(MouseEvent.CLICK,this.onClickLine);
         this.line_1.addEventListener(MouseEvent.CLICK,this.onClickLine);
         this.line_2.addEventListener(MouseEvent.CLICK,this.onClickLine);
         this.xiantou = conLevel["xiantou"];
         this.xiantou.visible = false;
         this.xiantou.mouseChildren = false;
         this.xiantou.addEventListener(Event.ENTER_FRAME,this.onXiantouEntFrame);
         this.xiantou.addEventListener(MouseEvent.CLICK,this.onXiantouClick);
         this.xita = conLevel["xita"];
         this.xita.visible = false;
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
         this.xiantou.removeEventListener(Event.ENTER_FRAME,this.onXiantouEntFrame);
         this.xiantou = null;
         Mouse.show();
         this.xita.removeEventListener(MouseEvent.CLICK,this.onFightXita);
      }
      
      private function onClickLine(param1:MouseEvent) : void
      {
         this.canConnected = true;
         this.clickLine = param1.currentTarget as MovieClip;
         this.xiantou.visible = true;
         Mouse.hide();
      }
      
      private function onXiantouClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc5_:uint = 0;
         var _loc4_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc4_ != null)
         {
            for each(_loc3_ in this.plugArr)
            {
               if(_loc3_ != null)
               {
                  if(_loc4_.hitTestObject(_loc3_))
                  {
                     _loc5_ = uint(_loc3_.name.split("_")[1]);
                     _loc2_ = _loc3_;
                     this.isClick = true;
                  }
               }
            }
         }
         if(!this.isClick)
         {
            Mouse.show();
            this.xiantou.visible = false;
            return;
         }
         if(this.canConnected)
         {
            this.clickLine.gotoAndStop(_loc5_ + 2);
            this.checkArr[_loc5_] = true;
            this.canConnected = false;
            ++this.count;
            this.clickLine.removeEventListener(MouseEvent.CLICK,this.onClickLine);
            this.clickLine.buttonMode = false;
            _loc2_.buttonMode = false;
            Mouse.show();
            this.xiantou.visible = false;
            this.isClick = false;
            if(this.clickLine.name.split("_")[1] == _loc2_.name.split("_")[1])
            {
               this.rightArr[_loc5_] = true;
            }
            else
            {
               this.rightArr[_loc5_] = false;
            }
         }
         if(this.count == 3)
         {
            this.check();
         }
      }
      
      private function check() : void
      {
         var timer:Timer = null;
         var i:Boolean = false;
         timer = null;
         for each(i in this.checkArr)
         {
            if(i == false)
            {
               return;
            }
         }
         if(this.rightArr[0] == true && this.rightArr[1] == true && this.rightArr[2] == true)
         {
            timer = new Timer(1000,1);
            timer.start();
            timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer.stop();
               timer = null;
            });
         }
         else
         {
            this.xiantou.removeEventListener(Event.ENTER_FRAME,this.onXiantouEntFrame);
            this.xita.buttonMode = true;
            this.xita.visible = true;
            this.xita.addEventListener(MouseEvent.CLICK,this.onFightXita);
         }
         this.dianliu.visible = false;
      }
      
      private function onXiantouEntFrame(param1:Event) : void
      {
         this.xiantou.x = MainManager.getStage().mouseX - 10;
         this.xiantou.y = MainManager.getStage().mouseY - 10;
      }
      
      private function onFightXita(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("西塔");
      }
   }
}

