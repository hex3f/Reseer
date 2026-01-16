package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.utils.Direction;
   import com.robot.core.utils.SolidDir;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.ui.Keyboard;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class FitmentModel extends SpriteModel
   {
      
      public var funID:uint;
      
      private var _info:FitmentInfo;
      
      protected var _dragEnabled:Boolean;
      
      private var _unit:IFunUnit;
      
      private var _content:Sprite;
      
      private var _enabledDir:Boolean = true;
      
      private var _enabedStatus:Boolean = true;
      
      public function FitmentModel()
      {
         super();
      }
      
      public function get info() : FitmentInfo
      {
         return this._info;
      }
      
      public function get dragEnabled() : Boolean
      {
         return this._dragEnabled;
      }
      
      public function set dragEnabled(param1:Boolean) : void
      {
         this._dragEnabled = param1;
         if(this._dragEnabled)
         {
            if(this._enabledDir)
            {
               addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            }
         }
         else
         {
            removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         }
      }
      
      public function get content() : Sprite
      {
         return this._content;
      }
      
      public function show(param1:FitmentInfo, param2:DisplayObjectContainer) : void
      {
         if(Boolean(this._info))
         {
            ResourceManager.cancel(ClientConfig.getFitmentItem(this._info.id),this.onLoadRes);
         }
         this._info = param1;
         this._enabedStatus = !ItemXMLInfo.getDisabledStatus(this._info.id);
         this._enabledDir = !ItemXMLInfo.getDisabledDir(this._info.id);
         param2.addChild(this);
         x = this._info.pos.x;
         y = this._info.pos.y;
         direction = Direction.indexToStr(this._info.dir);
         if(Boolean(this._unit))
         {
            this._unit.destroy();
            this._unit = null;
         }
         if(Boolean(this._content))
         {
            this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
            this._content.removeEventListener(MouseEvent.CLICK,this.onStatusClick);
            DisplayUtil.removeForParent(this._content);
            this._content = null;
         }
         ResourceManager.getResource(ClientConfig.getFitmentItem(this._info.id),this.onLoadRes);
      }
      
      public function hide() : void
      {
         this.dragEnabled = false;
         DisplayUtil.removeForParent(this);
      }
      
      override public function destroy() : void
      {
         this.hide();
         super.destroy();
         if(Boolean(this._info))
         {
            ResourceManager.cancel(ClientConfig.getFitmentItem(this._info.id),this.onLoadRes);
         }
         if(Boolean(this.funID))
         {
            ResourceManager.cancel(ClientConfig.getAppExtSwf(this.funID.toString()),this.onLoadUnit);
         }
         if(Boolean(this._unit))
         {
            this._unit.destroy();
            this._unit = null;
         }
         if(Boolean(this._content))
         {
            this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
            this._content.removeEventListener(MouseEvent.CLICK,this.onStatusClick);
            this._content = null;
         }
         this._info = null;
      }
      
      public function setSelect(param1:Boolean) : void
      {
         if(param1)
         {
            filters = [new GlowFilter(16711680)];
         }
         else
         {
            filters = [];
         }
      }
      
      private function changeDir() : void
      {
         if(this._content is MovieClip)
         {
            if(MovieClip(this._content).totalFrames == 1)
            {
               if(this._info.dir == SolidDir.DIR_LEFT)
               {
                  this._content.scaleX = -1;
               }
               else if(this._info.dir == SolidDir.DIR_RIGHT)
               {
                  this._content.scaleX = 1;
               }
            }
            else if(this._info.dir == SolidDir.DIR_LEFT)
            {
               MovieClip(this._content).gotoAndStop(1);
            }
            else if(this._info.dir == SolidDir.DIR_RIGHT)
            {
               MovieClip(this._content).gotoAndStop(2);
            }
            else if(this._info.dir == SolidDir.DIR_BUTTOM)
            {
               MovieClip(this._content).gotoAndStop(3);
            }
            else if(this._info.dir == SolidDir.DIR_TOP)
            {
               MovieClip(this._content).gotoAndStop(4);
            }
         }
         else if(this._info.dir == SolidDir.DIR_LEFT)
         {
            this._content.scaleX = -1;
         }
         else if(this._info.dir == SolidDir.DIR_RIGHT)
         {
            this._content.scaleX = 1;
         }
         MovieClipUtil.childStop(this._content,this._info.status + 1);
      }
      
      private function onLoadRes(param1:DisplayObject) : void
      {
         var _loc2_:Boolean = false;
         this._content = param1 as Sprite;
         this._content.addEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
         addChild(this._content);
         this.funID = ItemXMLInfo.getFunID(this._info.id);
         if(this.funID != 0)
         {
            _loc2_ = ItemXMLInfo.getFunIsCom(this._info.id);
            if(_loc2_)
            {
               this._content.buttonMode = true;
               ResourceManager.getResource(ClientConfig.getAppExtSwf(this.funID.toString()),this.onLoadUnit,"");
            }
            else if(MainManager.actorID == MainManager.actorInfo.mapID)
            {
               this._content.buttonMode = true;
               ResourceManager.getResource(ClientConfig.getAppExtSwf(this.funID.toString()),this.onLoadUnit,"");
            }
            else
            {
               this._content.mouseEnabled = false;
               this._content.mouseChildren = false;
            }
         }
         else
         {
            this._content.mouseEnabled = false;
         }
         this.changeDir();
         if(this._enabedStatus)
         {
            this._content.addEventListener(MouseEvent.CLICK,this.onStatusClick);
         }
      }
      
      private function onLoadUnit(param1:DisplayObject) : void
      {
         this._unit = param1 as IFunUnit;
         this._unit.setup(this._content);
         this._unit.init(this._info);
      }
      
      private function onADDStage(param1:Event) : void
      {
         this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
         DepthManager.swapDepth(this,y);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:* = 0;
         if(Boolean(this._content))
         {
            if(param1.keyCode == Keyboard.LEFT)
            {
               _loc2_ = SolidDir.DIR_LEFT;
            }
            else if(param1.keyCode == Keyboard.RIGHT)
            {
               _loc2_ = SolidDir.DIR_RIGHT;
            }
            else if(param1.keyCode == Keyboard.DOWN)
            {
               if(this._content is MovieClip)
               {
                  if(MovieClip(this._content).totalFrames >= 3)
                  {
                     _loc2_ = SolidDir.DIR_BUTTOM;
                  }
               }
            }
            else if(param1.keyCode == Keyboard.UP)
            {
               if(this._content is MovieClip)
               {
                  if(MovieClip(this._content).totalFrames >= 4)
                  {
                     _loc2_ = SolidDir.DIR_TOP;
                  }
               }
            }
            if(_loc2_ != this._info.dir)
            {
               this._info.dir = _loc2_;
               this.changeDir();
               FitmentManager.isChange = true;
            }
         }
      }
      
      private function onStatusClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Sprite = param1.currentTarget as Sprite;
         if(Boolean(_loc3_))
         {
            _loc2_ = _loc3_.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               if(_loc2_.totalFrames < 2)
               {
                  return;
               }
               if(_loc2_.currentFrame == 1)
               {
                  this._info.status = 1;
                  _loc2_.gotoAndStop(2);
               }
               else
               {
                  this._info.status = 0;
                  _loc2_.gotoAndStop(1);
               }
               if(MainManager.actorID == MainManager.actorInfo.mapID)
               {
                  FitmentManager.isChange = true;
                  FitmentManager.saveInfo();
               }
            }
         }
      }
   }
}

