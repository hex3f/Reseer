package com.robot.core.skeleton
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.ISkeletonSprite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class ChangeClothAction
   {
      
      private static const B_S:Number = 0.2;
      
      private static const S_S:Number = 1;
      
      public static const GLOW_1:Array = [new GlowFilter(16777215,1,10,10,0.8),new GlowFilter(16776960,1,B_S,B_S,S_S)];
      
      public static const GLOW_2:Array = [new GlowFilter(16777215,1,10,10,0.8),new GlowFilter(16711680,1,B_S,B_S,S_S)];
      
      protected var clothID:int = 0;
      
      protected var clothLevel:uint = 0;
      
      protected var people:ISkeletonSprite;
      
      protected var clothSWF:MovieClip;
      
      protected var isLoaded:Boolean = false;
      
      protected var offsetPoint:Point;
      
      protected var container:Sprite;
      
      protected var type:String;
      
      protected var model:uint;
      
      private var _curUrlType:uint = 0;
      
      private var _clothURL:String = "";
      
      public function ChangeClothAction(param1:ISkeletonSprite, param2:Sprite, param3:String, param4:uint)
      {
         super();
         this.model = param4;
         this.type = param3;
         this.people = param1;
         this.container = param2;
         this.takeOffCloth();
      }
      
      public function changeCloth(param1:PeopleItemInfo, param2:uint = 0) : void
      {
         if(ClothInfo.getItemInfo(param1.id).type == "bg")
         {
            return;
         }
         this._curUrlType = param2;
         this.clothID = param1.id;
         this.clothLevel = param1.level;
         this.beginLoad();
      }
      
      public function changeClothByPath(param1:int, param2:String) : void
      {
         this.clothID = param1;
         this.beginLoad(param2);
      }
      
      public function addChildCloth(param1:MovieClip, param2:Sprite) : void
      {
         this.clothSWF = param1;
         this.container = param2;
         this.clothSWF.cacheAsBitmap = true;
         if(Boolean(this.people))
         {
            this.clothSWF.gotoAndStop(this.people.direction);
         }
         if(Boolean(param2))
         {
            param2.addChild(this.clothSWF);
         }
         this.isLoaded = true;
      }
      
      public function takeOffCloth() : void
      {
         if(this.type == SkeletonClothPreview.FLAG_CLOTH)
         {
            return;
         }
         if(Boolean(this.clothSWF))
         {
            DisplayUtil.removeForParent(this.clothSWF);
            ToolTipManager.remove(this.clothSWF);
            this.clothSWF = null;
            this.isLoaded = false;
            this.clothID = 0;
         }
         if(this.type == ClothPreview.FLAG_HEAD)
         {
            this.changeCloth(new PeopleItemInfo(ClothInfo.DEFAULT_HEAD));
         }
         else if(this.type == ClothPreview.FLAG_WAIST)
         {
            this.changeCloth(new PeopleItemInfo(ClothInfo.DEFAULT_WAIST));
         }
         else if(this.type == ClothPreview.FLAG_FOOT)
         {
            this.changeCloth(new PeopleItemInfo(ClothInfo.DEFAULT_FOOT));
         }
      }
      
      public function changeDir(param1:String) : void
      {
         if(this.isLoaded)
         {
            this.clothSWF.gotoAndStop(param1);
         }
      }
      
      public function specialAction(param1:BasePeoleModel, param2:uint, param3:Boolean = true) : void
      {
         var peopleMode:BasePeoleModel = param1;
         var id:uint = param2;
         var isCheckID:Boolean = param3;
         if(Boolean(this.clothSWF))
         {
            this.clothSWF.gotoAndStop(BasePeoleModel.SPECIAL_ACTION);
         }
         if(id == this.clothID && isCheckID)
         {
            this.clothSWF.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = null;
               var _loc3_:MovieClip = clothSWF.getChildByName("bodyMC") as MovieClip;
               if(Boolean(_loc3_))
               {
                  _loc2_ = _loc3_["colorMC"];
                  DisplayUtil.FillColor(_loc2_,peopleMode.info.color);
                  clothSWF.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
         }
      }
      
      public function goStart() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(this.clothSWF))
         {
            _loc1_ = this.clothSWF.getChildAt(0) as MovieClip;
            if(Boolean(_loc1_))
            {
               _loc1_.gotoAndPlay(2);
            }
         }
      }
      
      public function goOver() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(this.clothSWF))
         {
            _loc1_ = this.clothSWF.getChildAt(0) as MovieClip;
            if(Boolean(_loc1_))
            {
               _loc1_.gotoAndStop(1);
            }
         }
      }
      
      public function goEnterFrame() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(this.clothSWF))
         {
            _loc1_ = this.clothSWF.getChildAt(0) as MovieClip;
            if(Boolean(_loc1_))
            {
               if(_loc1_.currentFrame == 1)
               {
                  _loc1_.gotoAndPlay(2);
               }
            }
         }
      }
      
      protected function beginLoad(param1:String = "") : void
      {
         var _loc2_:Array = null;
         if(this._clothURL != "")
         {
            ResourceManager.cancel(this._clothURL,this.onLoadCloth);
         }
         if(param1 == "")
         {
            switch(this.model)
            {
               case ClothPreview.MODEL_PEOPLE:
                  this._clothURL = ClothInfo.getItemInfo(this.clothID).getUrl(this.clothLevel);
                  break;
               case ClothPreview.MODEL_SHOW:
                  this._clothURL = ClothInfo.getItemInfo(this.clothID).getPrevUrl(this.clothLevel);
                  break;
               default:
                  this._clothURL = ClothInfo.getItemInfo(this.clothID).getUrl(this.clothLevel);
            }
         }
         else
         {
            this._clothURL = param1;
         }
         if(this._curUrlType != 0)
         {
            _loc2_ = this._clothURL.split(".");
            this._clothURL = _loc2_[0] + "_" + this._curUrlType.toString() + ".swf";
         }
         ResourceManager.getResource(this._clothURL,this.onLoadCloth);
      }
      
      private function onLoadCloth(param1:DisplayObject) : void
      {
         if(Boolean(this.clothSWF))
         {
            this.clothSWF.removeEventListener(MouseEvent.CLICK,this.unloadCloth);
            ToolTipManager.remove(this.clothSWF);
            DisplayUtil.removeForParent(this.clothSWF);
         }
         this.clothSWF = param1 as MovieClip;
         ToolTipManager.add(this.clothSWF,ItemXMLInfo.getName(this.clothID));
         this.clothSWF.cacheAsBitmap = true;
         this.clothSWF.mouseChildren = false;
         this.clothSWF.addEventListener(MouseEvent.CLICK,this.unloadCloth);
         this.clothSWF.addEventListener(MouseEvent.MOUSE_OVER,this.onClothOver);
         this.clothSWF.addEventListener(MouseEvent.MOUSE_OUT,this.onClothOut);
         if(Boolean(this.people))
         {
            this.clothSWF.gotoAndStop(this.people.direction);
         }
         if(Boolean(this.container))
         {
            this.container.addChild(this.clothSWF);
            if(!this.container.parent.mouseEnabled)
            {
               this.clothSWF.removeEventListener(MouseEvent.CLICK,this.unloadCloth);
            }
         }
         this.isLoaded = true;
      }
      
      protected function unloadCloth(param1:MouseEvent) : void
      {
      }
      
      protected function onClothOver(param1:MouseEvent) : void
      {
         (param1.currentTarget as DisplayObject).filters = [new GlowFilter()];
      }
      
      protected function onClothOut(param1:MouseEvent) : void
      {
         (param1.currentTarget as DisplayObject).filters = [];
      }
      
      public function destroy() : void
      {
         if(Boolean(this.clothSWF))
         {
            DisplayUtil.removeForParent(this.clothSWF);
            ToolTipManager.remove(this.clothSWF);
            this.clothSWF = null;
            this.isLoaded = false;
            this.clothID = 0;
         }
      }
      
      public function getClothLevel() : uint
      {
         return this.clothLevel;
      }
      
      public function getClothID() : int
      {
         var _loc1_:* = 0;
         if(this.clothID == ClothInfo.DEFAULT_FOOT || this.clothID == ClothInfo.DEFAULT_HEAD || this.clothID == ClothInfo.DEFAULT_WAIST)
         {
            _loc1_ = 0;
         }
         else
         {
            _loc1_ = uint(this.clothID);
         }
         return _loc1_;
      }
   }
}

