package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.FortressItemXMLInfo;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.team.ArmInfo;
   import com.robot.core.manager.ArmManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.teamInstallation.TeamInfoController;
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
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class ArmModel extends SpriteModel
   {
      
      public var funID:uint;
      
      private var _info:ArmInfo;
      
      protected var _dragEnabled:Boolean;
      
      private var _unit:IFunUnit;
      
      private var _content:Sprite;
      
      private var _resURL:String = "";
      
      private var _markMc:MovieClip;
      
      public function ArmModel()
      {
         super();
      }
      
      public function get info() : ArmInfo
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
            addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            removeEventListener(MouseEvent.CLICK,this.onPanelClick);
         }
         else
         {
            removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            if(!this.funID)
            {
               addEventListener(MouseEvent.CLICK,this.onPanelClick);
            }
         }
      }
      
      public function get content() : Sprite
      {
         return this._content;
      }
      
      public function show(param1:ArmInfo, param2:DisplayObjectContainer) : void
      {
         if(this._resURL != "")
         {
            ResourceManager.cancel(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
         }
         this._info = param1;
         if(this._info.form == 0)
         {
            this._resURL = this._info.styleID.toString();
         }
         else
         {
            buttonMode = true;
            if(this._info.form == 1)
            {
               if(this._info.resNum == 0)
               {
                  this._resURL = this._info.styleID.toString() + "_" + this._info.form.toString();
               }
               else
               {
                  this._resURL = this._info.styleID.toString() + "_b";
               }
            }
            else
            {
               this._resURL = this._info.styleID.toString() + "_" + this._info.form.toString();
            }
         }
         param2.addChild(this);
         x = this._info.pos.x;
         y = this._info.pos.y;
         direction = Direction.indexToStr(this._info.dir);
         this.changeUI(this._resURL);
      }
      
      public function checkIsUp() : Boolean
      {
         var _loc1_:* = 0;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = true;
         if(this._info.form >= uint(FortressItemXMLInfo.getMaxLevel(this._info.id)))
         {
            return false;
         }
         if(this._info.id == 3 && this._info.form == 2)
         {
            return false;
         }
         if(this._info.isUsed)
         {
            if(this._info.form == 1)
            {
               _loc1_ = uint(this._info.res.getValues()[0]);
               if(_loc1_ < 5000)
               {
                  _loc7_ = false;
               }
            }
            else
            {
               _loc2_ = this._info.res.getValues();
               _loc3_ = FortressItemXMLInfo.getResMaxs(this._info.id,this._info.form);
               _loc6_ = 0;
               while(_loc6_ < 4)
               {
                  _loc4_ += _loc2_[_loc6_];
                  _loc5_ += _loc3_[_loc6_];
                  _loc6_++;
               }
               if(_loc4_ < _loc5_)
               {
                  _loc7_ = false;
               }
            }
         }
         else
         {
            _loc7_ = false;
         }
         return _loc7_;
      }
      
      public function showUpMark() : void
      {
         var _loc1_:Rectangle = null;
         if(MapManager.currentMap.id == MainManager.actorInfo.teamInfo.id)
         {
            this._markMc = TaskIconManager.getIcon("EquipUpMarkMc") as MovieClip;
            this._markMc.scaleX = this._markMc.scaleY = 0.6;
            this._markMc.gotoAndPlay(1);
            _loc1_ = this.getRect(this._content);
            this._markMc.y = _loc1_.y - this._markMc.height;
            this._markMc.x = -this._markMc.width / 2;
            addChild(this._markMc);
         }
      }
      
      public function hideUpMark() : void
      {
         if(Boolean(this._markMc))
         {
            if(DisplayUtil.hasParent(this._markMc))
            {
               this.removeChild(this._markMc);
               this._markMc = null;
            }
         }
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
         if(this._resURL != "")
         {
            ResourceManager.cancel(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
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
            this._content = null;
         }
         TeamInfoController.destroy();
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
      
      public function setBufForInfo(param1:ArmInfo) : void
      {
         this._info.pos = param1.pos;
         this._info.dir = param1.dir;
         this._info.status = param1.status;
         x = this._info.pos.x;
         y = this._info.pos.y;
         direction = Direction.indexToStr(this._info.dir);
         this.changeDir();
      }
      
      public function setFormUpDate(param1:uint) : void
      {
         if(this._info.form >= param1)
         {
            return;
         }
         this._info.form = param1;
         if(Boolean(this._resURL))
         {
            ResourceManager.cancel(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
         }
         this.changeUI(this._info.styleID.toString() + "_" + this._info.form.toString());
      }
      
      public function setWork(param1:uint, param2:uint) : void
      {
         if(this._info.form != 1)
         {
            return;
         }
         if(this._info.resNum != 0)
         {
            return;
         }
         this._info.workCount = param1;
         this._info.resNum = param2;
         if(Boolean(this._resURL))
         {
            ResourceManager.cancel(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
         }
         this.changeUI(this._info.styleID.toString() + "_b");
      }
      
      public function changeUI(param1:String) : void
      {
         if(Boolean(this._unit))
         {
            this._unit.destroy();
            this._unit = null;
         }
         if(Boolean(this._content))
         {
            this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
            DisplayUtil.removeForParent(this._content);
            this._content = null;
         }
         this._resURL = param1;
         ResourceManager.getResource(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
      }
      
      private function changeDir() : void
      {
         if(this._content is MovieClip)
         {
            if(MovieClip(this._content).totalFrames == 1)
            {
               if(this._info.dir == SolidDir.DIR_LEFT)
               {
                  this._content.scaleX = 1;
               }
               else if(this._info.dir == SolidDir.DIR_RIGHT)
               {
                  this._content.scaleX = -1;
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
            this._content.scaleX = 1;
         }
         else if(this._info.dir == SolidDir.DIR_RIGHT)
         {
            this._content.scaleX = -1;
         }
      }
      
      private function onLoadRes(param1:DisplayObject) : void
      {
         var _loc2_:Boolean = false;
         this._content = param1 as Sprite;
         this._content.addEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
         addChild(this._content);
         if(this.checkIsUp())
         {
            this.showUpMark();
         }
         if(this._info.buyTime == 0)
         {
            this.funID = ItemXMLInfo.getFunID(this._info.id);
         }
         else
         {
            this.funID = FortressItemXMLInfo.getFunID(this._info.id);
         }
         if(this.funID != 0)
         {
            if(this._info.buyTime == 0)
            {
               _loc2_ = ItemXMLInfo.getFunIsCom(this._info.id);
            }
            else
            {
               _loc2_ = FortressItemXMLInfo.getFunIsCom(this._info.id);
            }
            if(_loc2_)
            {
               this._content.buttonMode = true;
               ResourceManager.getResource(ClientConfig.getAppExtSwf(this.funID.toString()),this.onLoadUnit,"");
            }
            else if(MainManager.actorInfo.teamInfo.id == MainManager.actorInfo.mapID)
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
         if(MainManager.actorInfo.teamInfo.id == MainManager.actorInfo.mapID)
         {
            if(!this.funID)
            {
               addEventListener(MouseEvent.CLICK,this.onPanelClick);
            }
         }
         else
         {
            mouseEnabled = false;
            buttonMode = false;
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
               ArmManager.setIsChange(this._info);
            }
         }
      }
      
      private function onPanelClick(param1:MouseEvent) : void
      {
         TeamInfoController.start(this._info);
      }
   }
}

