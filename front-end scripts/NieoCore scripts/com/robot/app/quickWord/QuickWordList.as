package com.robot.app.quickWord
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   
   public class QuickWordList extends Sprite
   {
      
      private var parentList:QuickWordList;
      
      private var subList:QuickWordList;
      
      private var perHeight:Number;
      
      private var checkTimer:Timer;
      
      private var _totalHeight:Number;
      
      public function QuickWordList(param1:XML, param2:QuickWordList = null)
      {
         super();
         this.checkTimer = new Timer(2000,1);
         this.checkTimer.addEventListener(TimerEvent.TIMER,this.checkIsHit);
         this.parentList = param2;
         var _loc3_:XMLList = param1.elements("menu");
         if(_loc3_.length() > 0)
         {
            this.listMC(_loc3_);
         }
      }
      
      public function destroy() : void
      {
         if(!this.parentList)
         {
            dispatchEvent(new Event(Event.CLOSE));
         }
         if(Boolean(this.subList))
         {
            this.subList.destroy();
         }
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
         this.checkTimer.stop();
         this.checkTimer.removeEventListener(TimerEvent.TIMER,this.checkIsHit);
         this.checkTimer = null;
         this.parentList = null;
         this.subList = null;
      }
      
      private function listMC(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:MovieClip = null;
         _loc2_ = null;
         _loc3_ = null;
         var _loc4_:TextField = null;
         var _loc5_:int = 0;
         var _loc6_:Number = 0;
         var _loc7_:Array = [];
         for each(_loc2_ in param1)
         {
            _loc3_ = UIManager.getMovieClip("quickWordListMC");
            _loc3_.gotoAndStop(1);
            this.perHeight = _loc3_.height + 1;
            _loc3_.mouseChildren = false;
            this._totalHeight = this.perHeight * param1.length();
            _loc4_ = _loc3_["txt"];
            _loc4_.autoSize = TextFieldAutoSize.CENTER;
            _loc4_.text = _loc2_.@title;
            _loc6_ = Math.max(_loc6_,_loc4_.width);
            _loc3_.xml = _loc2_;
            _loc3_.y = this._totalHeight - this.perHeight * (_loc5_ + 1);
            _loc3_.buttonMode = true;
            if(_loc2_.children().length() == 0)
            {
               _loc3_["dotMC"].visible = false;
               _loc3_.addEventListener(MouseEvent.CLICK,this.clickHandler);
            }
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.overHandler);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.outHandler);
            _loc7_.push(_loc3_);
            _loc5_++;
         }
         this.formatMC(_loc7_,_loc6_);
      }
      
      private function formatMC(param1:Array, param2:Number) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         param2 = Math.max(100,param2);
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc3_["bgMC"];
            _loc5_ = _loc3_["dotMC"];
            _loc4_.width = param2 + _loc5_.width + 12;
            _loc3_["txt"].x = (_loc4_.width - _loc3_["txt"].width) / 2;
            _loc5_.x = _loc4_.width - _loc5_.width - 6;
            this.addChild(_loc3_);
         }
      }
      
      public function resetPosition() : void
      {
         if(!this.parentList)
         {
            return;
         }
         var _loc1_:Point = this.localToGlobal(new Point());
         var _loc2_:Number = _loc1_.y + this.height - this.getFirst().totalHeight;
         if(_loc2_ > 0)
         {
            this.y -= this.perHeight;
            this.resetPosition();
         }
      }
      
      public function get totalHeight() : Number
      {
         var _loc1_:Point = this.localToGlobal(new Point());
         return _loc1_.y + this._totalHeight;
      }
      
      public function getFirst() : QuickWordList
      {
         var _loc1_:QuickWordList = this;
         while(Boolean(_loc1_.parentList))
         {
            _loc1_ = _loc1_.parentList;
         }
         return _loc1_;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].gotoAndStop(2);
         _loc2_["dotMC"].gotoAndStop(2);
         if(Boolean(this.subList))
         {
            this.subList.destroy();
         }
         this.subList = null;
         var _loc3_:DisplayObject = param1.currentTarget as DisplayObject;
         _loc2_ = param1.currentTarget as MovieClip;
         var _loc4_:XMLList = XML(_loc2_.xml).elements("menu");
         if(_loc4_.length() > 0)
         {
            this.subList = new QuickWordList(_loc2_.xml,this);
            this.subList.x = this.width;
            this.subList.y = _loc3_.y;
            this.addChild(this.subList);
            this.subList.resetPosition();
         }
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].gotoAndStop(1);
         _loc2_["dotMC"].gotoAndStop(1);
         if(Boolean(this.checkTimer))
         {
            this.checkTimer.stop();
            this.checkTimer.start();
         }
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         this.getFirst().destroy();
         MainManager.actorModel.chatAction(_loc2_["txt"].text);
      }
      
      private function checkIsHit(param1:TimerEvent) : void
      {
         var _loc2_:QuickWordList = this.getFirst();
         if(!_loc2_.hitTestPoint(MainManager.getStage().mouseX,MainManager.getStage().mouseY,true))
         {
            _loc2_.destroy();
         }
      }
   }
}

