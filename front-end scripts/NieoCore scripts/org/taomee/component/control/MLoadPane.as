package org.taomee.component.control
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import org.taomee.component.UIComponent;
   import org.taomee.component.event.LoadPaneEvent;
   import org.taomee.utils.DisplayUtil;
   
   [Event(name="onLoadContent",type="org.taomee.component.event.LoadPaneEvent")]
   public class MLoadPane extends UIComponent
   {
      
      public static const FIT_NONE:int = 0;
      
      public static const FIT_WIDTH:int = 1;
      
      public static const FIT_HEIGHT:int = 2;
      
      public static const FIT_ALL:int = 3;
      
      public static const CENTER:int = 0;
      
      public static const LEFT:int = 1;
      
      public static const RIGHT:int = 2;
      
      public static const MIDDLE:int = 0;
      
      public static const TOP:int = 1;
      
      public static const BOTTOM:int = 2;
      
      private var icon:*;
      
      private var oldH:Number;
      
      private var oldW:Number;
      
      private var loader:Loader;
      
      private var image:DisplayObject;
      
      private var _valign:int;
      
      private var _fitType:int;
      
      private var _halign:int;
      
      private var _offsetRect:Boolean = true;
      
      public function MLoadPane(param1:* = null, param2:int = 0, param3:int = 0, param4:int = 0)
      {
         super();
         this._fitType = param2;
         this._halign = param3;
         this._valign = param4;
         this.icon = param1;
         this.childMouseEnabled = false;
         this.getImageInstance(param1);
      }
      
      public function get content() : DisplayObject
      {
         return this.image;
      }
      
      override protected function revalidate() : void
      {
         super.revalidate();
         if(!this.image)
         {
            return;
         }
         this.adjustImageSize();
      }
      
      private function onLoadTitleIcon(param1:Event) : void
      {
         this.image = LoaderInfo(param1.target).content;
         containSprite.addChild(this.image);
         this.oldW = this.image.width;
         this.oldH = this.image.height;
         updateView();
         dispatchEvent(new LoadPaneEvent(LoadPaneEvent.ON_LOAD_CONTENT,this.image));
      }
      
      public function get valign() : uint
      {
         return this._valign;
      }
      
      public function set halign(param1:uint) : void
      {
         if(param1 != this.halign)
         {
            this._halign = param1;
            updateView();
         }
      }
      
      public function setContentScale(param1:Number = 1, param2:Number = 1) : void
      {
         this.image.scaleX = param1;
         this.image.scaleY = param2;
         if(this.image.scaleX != param1 || this.image.scaleY != param2)
         {
            updateView();
         }
      }
      
      private function loadImage(param1:String) : void
      {
         try
         {
            this.loader.close();
         }
         catch(e:Error)
         {
         }
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadTitleIcon);
         this.loader.load(new URLRequest(param1));
      }
      
      public function set fitType(param1:uint) : void
      {
         if(param1 != this.fitType)
         {
            this._fitType = param1;
            updateView();
         }
      }
      
      public function get halign() : uint
      {
         return this._halign;
      }
      
      public function set valign(param1:uint) : void
      {
         if(param1 != this.valign)
         {
            this._valign = param1;
            updateView();
         }
      }
      
      private function getImageInstance(param1:*) : void
      {
         DisplayUtil.removeAllChild(containSprite);
         if(param1 == null)
         {
            return;
         }
         if(param1 is String)
         {
            this.loadImage(param1);
         }
         else if(param1 is DisplayObject)
         {
            this.image = param1;
            this.oldW = this.image.width;
            this.oldH = this.image.height;
            containSprite.addChild(this.image);
            updateView();
            dispatchEvent(new LoadPaneEvent(LoadPaneEvent.ON_LOAD_CONTENT,this.image));
         }
      }
      
      public function get fitType() : uint
      {
         return this._fitType;
      }
      
      private function adjustImageSize() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Rectangle = null;
         switch(this.fitType)
         {
            case MLoadPane.FIT_HEIGHT:
               _loc1_ = _loc2_ = this.height / this.oldH;
               this.image.width = this.oldW * (this.height / this.oldH);
               this.image.height = this.height;
               break;
            case MLoadPane.FIT_WIDTH:
               _loc1_ = _loc2_ = this.width / this.oldW;
               this.image.height = this.oldH * (this.width / this.oldW);
               this.image.width = this.width;
               break;
            case MLoadPane.FIT_ALL:
               _loc1_ = this.width / this.oldW;
               _loc2_ = this.width / this.oldH;
               this.image.height = this.height;
               this.image.width = this.width;
               break;
            case MLoadPane.FIT_NONE:
            default:
               _loc1_ = _loc2_ = 1;
               this.image.height = this.oldH;
               this.image.width = this.oldW;
         }
         if(this._offsetRect)
         {
            _loc3_ = this.image.getRect(this.image);
         }
         else
         {
            _loc3_ = new Rectangle();
         }
         switch(this.halign)
         {
            case MLoadPane.LEFT:
               this.image.x = 0 - _loc3_.x * _loc1_;
               break;
            case MLoadPane.RIGHT:
               this.image.x = this.width - this.image.width - _loc3_.x * _loc1_;
               break;
            case MLoadPane.CENTER:
            default:
               this.image.x = (this.width - this.image.width) / 2 - _loc3_.x * _loc1_;
         }
         switch(this.valign)
         {
            case MLoadPane.TOP:
               this.image.y = 0 - _loc3_.y * _loc2_;
               break;
            case MLoadPane.BOTTOM:
               this.image.y = this.height - this.image.height - _loc3_.y * _loc2_;
               break;
            case MLoadPane.MIDDLE:
            default:
               this.image.y = (this.height - this.image.height) / 2 - _loc3_.y * _loc2_;
         }
      }
      
      public function set childMouseEnabled(param1:Boolean) : void
      {
         containSprite.mouseChildren = param1;
      }
      
      public function set offsetRect(param1:Boolean) : void
      {
         this._offsetRect = param1;
      }
      
      public function reLoad() : void
      {
         DisplayUtil.removeForParent(this.image);
         this.getImageInstance(this.icon + "?" + Math.random());
      }
      
      override public function destroy() : void
      {
         this.image = null;
         super.destroy();
      }
      
      public function setIcon(param1:*) : void
      {
         this.getImageInstance(param1);
      }
      
      public function unload() : void
      {
         DisplayUtil.removeForParent(this.image);
      }
   }
}

