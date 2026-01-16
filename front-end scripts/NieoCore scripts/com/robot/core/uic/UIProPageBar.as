package com.robot.core.uic
{
   import flash.display.InteractiveObject;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.taomee.events.DynamicEvent;
   
   [Event(name="click",type="flash.events.MouseEvent")]
   public class UIProPageBar extends EventDispatcher
   {
      
      private static const PAGE_NO:int = 0;
      
      private static const PAGE_PRE:int = 1;
      
      private static const PAGE_NEXT:int = 2;
      
      private static const PAGE_ALL:int = 3;
      
      private var _preBtn:InteractiveObject;
      
      private var _nextBtn:InteractiveObject;
      
      private var _index:int = 0;
      
      private var _totalLength:int = 0;
      
      private var _showMax:int = 0;
      
      public function UIProPageBar(param1:InteractiveObject, param2:InteractiveObject, param3:int = 0)
      {
         super();
         this._showMax = param3;
         this._preBtn = param1;
         this._nextBtn = param2;
         this._preBtn.addEventListener(MouseEvent.CLICK,this.onPre);
         this._nextBtn.addEventListener(MouseEvent.CLICK,this.onNext);
         this.setBtnStutas(PAGE_NO);
      }
      
      public function set showMax(param1:int) : void
      {
         this._showMax = param1;
         this.init();
      }
      
      public function get showMax() : int
      {
         return this._showMax;
      }
      
      public function set totalLength(param1:int) : void
      {
         this._totalLength = param1;
         this.init();
      }
      
      public function get totalLength() : int
      {
         return this._totalLength;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
         if(this._index < 0)
         {
            this._index = 0;
         }
         else if(this._index > this._totalLength - this._showMax)
         {
            this._index = this._totalLength - this._showMax;
         }
         if(this._index > 0 && this._index < this._totalLength - this._showMax)
         {
            this.setBtnStutas(PAGE_ALL);
         }
         else if(this._index > 0)
         {
            this.setBtnStutas(PAGE_PRE);
         }
         else if(this._index < this._totalLength - this._showMax)
         {
            this.setBtnStutas(PAGE_NEXT);
         }
         dispatchEvent(new DynamicEvent(MouseEvent.CLICK,this._index));
      }
      
      public function destroy() : void
      {
         this._preBtn.removeEventListener(MouseEvent.CLICK,this.onPre);
         this._nextBtn.removeEventListener(MouseEvent.CLICK,this.onNext);
         this._preBtn = null;
         this._nextBtn = null;
      }
      
      public function preIndex(param1:int) : void
      {
         this._index -= param1;
         dispatchEvent(new DynamicEvent(MouseEvent.CLICK,this._index));
         if(this._index > 0)
         {
            if(this._index < this._totalLength - this._showMax)
            {
               this.setBtnStutas(PAGE_ALL);
            }
            else
            {
               this.setBtnStutas(PAGE_NEXT);
            }
         }
         else
         {
            this.setBtnStutas(PAGE_NEXT);
         }
      }
      
      public function nextIndex(param1:int) : void
      {
         this._index += param1;
         dispatchEvent(new DynamicEvent(MouseEvent.CLICK,this._index));
         if(this._index < this._totalLength - this._showMax)
         {
            if(this._index > 0)
            {
               this.setBtnStutas(PAGE_ALL);
            }
            else
            {
               this.setBtnStutas(PAGE_PRE);
            }
         }
         else
         {
            this.setBtnStutas(PAGE_PRE);
         }
      }
      
      private function init() : void
      {
         if(this._totalLength > this._showMax)
         {
            if(this._index > this._totalLength - this._showMax)
            {
               this._index = this._totalLength - this._showMax;
               this.setBtnStutas(PAGE_PRE);
            }
            else if(this._index > 0)
            {
               this.setBtnStutas(PAGE_ALL);
            }
            else
            {
               this.setBtnStutas(PAGE_NEXT);
            }
         }
         else
         {
            this._index = 0;
            this.setBtnStutas(PAGE_NO);
         }
      }
      
      private function setBtnStutas(param1:int) : void
      {
         switch(param1)
         {
            case PAGE_NO:
               this._preBtn.mouseEnabled = false;
               this._nextBtn.mouseEnabled = false;
               this._preBtn.alpha = 0.4;
               this._nextBtn.alpha = 0.4;
               break;
            case PAGE_PRE:
               this._preBtn.mouseEnabled = true;
               this._nextBtn.mouseEnabled = false;
               this._preBtn.alpha = 1;
               this._nextBtn.alpha = 0.4;
               break;
            case PAGE_NEXT:
               this._preBtn.mouseEnabled = false;
               this._nextBtn.mouseEnabled = true;
               this._preBtn.alpha = 0.4;
               this._nextBtn.alpha = 1;
               break;
            case PAGE_ALL:
               this._preBtn.mouseEnabled = true;
               this._nextBtn.mouseEnabled = true;
               this._preBtn.alpha = 1;
               this._nextBtn.alpha = 1;
         }
      }
      
      private function onPre(param1:MouseEvent) : void
      {
         this.preIndex(1);
      }
      
      private function onNext(param1:MouseEvent) : void
      {
         this.nextIndex(1);
      }
   }
}

