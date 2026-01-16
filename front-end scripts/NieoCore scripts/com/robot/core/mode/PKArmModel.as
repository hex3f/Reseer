package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.FortressItemXMLInfo;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.effect.shotBehavior.IShotBehavior;
   import com.robot.core.info.teamPK.TeamPkBuildingInfo;
   import com.robot.core.manager.*;
   import com.robot.core.mode.spriteInteractive.ISpriteInteractiveAction;
   import com.robot.core.mode.spriteModelAdditive.SpriteBloodBar;
   import com.robot.core.teamPK.TeamPKManager;
   import com.robot.core.teamPK.shotActive.PKInteractiveAction;
   import com.robot.core.utils.Direction;
   import com.robot.core.utils.SolidDir;
   import com.robot.core.utils.SolidType;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class PKArmModel extends SpriteModel
   {
      
      public static const BE_DESTROY:String = "beDestroy";
      
      private var _isMirror:Boolean = false;
      
      private var _info:TeamPkBuildingInfo;
      
      private var _resURL:String = "";
      
      private var _content:Sprite;
      
      public var container:Sprite;
      
      private var mirrorBuf:Boolean = false;
      
      private var bmp:Bitmap;
      
      private var _shotBehavior:IShotBehavior;
      
      private var redcls:Array = [AssetsManager.getClass("red_build_2"),AssetsManager.getClass("red_build_3"),AssetsManager.getClass("red_build_4")];
      
      private var bluecls:Array = [AssetsManager.getClass("blue_build_2"),AssetsManager.getClass("blue_build_3"),AssetsManager.getClass("blue_build_4")];
      
      private var colorType:uint;
      
      public var isFreeze:Boolean = false;
      
      private var destroyMC:MovieClip;
      
      private var _isEnemy:Boolean = false;
      
      private var interactive:ISpriteInteractiveAction;
      
      public function PKArmModel(param1:TeamPkBuildingInfo, param2:Boolean = false, param3:uint = 1)
      {
         super();
         this.container = new Sprite();
         addChild(this.container);
         this.colorType = param3;
         this.info = param1;
         this.mouseChildren = false;
         this.mouseEnabled = false;
         if(param2)
         {
            this.mirror();
         }
         this.destroyMC = ShotBehaviorManager.getMovieClip("pkArm_destroy_mc");
         this.destroyMC.gotoAndStop(1);
      }
      
      public function set isEnemy(param1:Boolean) : void
      {
         this._isEnemy = param1;
         if(param1)
         {
            this.mouseChildren = true;
            this.interactive = new PKInteractiveAction(this);
            this.container.addEventListener(MouseEvent.ROLL_OVER,this.overHandler);
            this.container.addEventListener(MouseEvent.ROLL_OUT,this.outHandler);
            this.container.addEventListener(MouseEvent.CLICK,this.clickHandler);
         }
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         this.interactive.rollOver();
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         this.interactive.rollOut();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.interactive.click();
      }
      
      public function shot(param1:SpriteModel) : void
      {
         var target:SpriteModel = param1;
         if(!target)
         {
            return;
         }
         this._shotBehavior.shot(this,target);
         if(this._info.id == 1)
         {
            return;
         }
         if(this.localToGlobal(new Point()).x > target.localToGlobal(new Point()).x)
         {
            if(this.isMirror)
            {
               this.container.scaleX = -this.container.scaleX;
               setTimeout(function():void
               {
                  container.scaleX = -container.scaleX;
               },1000);
            }
         }
         else if(!this.isMirror)
         {
            this.container.scaleX = -this.container.scaleX;
            setTimeout(function():void
            {
               container.scaleX = -container.scaleX;
            },1000);
         }
      }
      
      public function get isMirror() : Boolean
      {
         return this._isMirror;
      }
      
      public function mirror() : void
      {
         if(Boolean(this._content))
         {
            this.container.scaleX = -1;
         }
         else
         {
            this.mirrorBuf = true;
         }
         this._isMirror = true;
      }
      
      public function get info() : TeamPkBuildingInfo
      {
         return this._info;
      }
      
      public function set info(param1:TeamPkBuildingInfo) : void
      {
         this._info = param1;
         if(this._resURL != "")
         {
            ResourceManager.cancel(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
         }
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
         if(this._info.type != SolidType.FRAME)
         {
            if(this._info.isFixed)
            {
               this._info.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
            }
         }
         x = this._info.pos.x;
         y = this._info.pos.y;
         direction = Direction.indexToStr(this._info.dir);
         this.changeUI(this._resURL);
         this._shotBehavior = ShotBehaviorManager.getBehavior(this._info.id,this._info.form);
      }
      
      private function onLoadRes(param1:DisplayObject) : void
      {
         this._content = param1 as Sprite;
         MovieClipUtil.childStop(this,1);
         this._content.addEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
         if(this.mirrorBuf)
         {
            this.container.scaleX = -1;
            this.mirrorBuf = false;
         }
         this.container.addChild(this._content);
         this._content.mouseEnabled = false;
         this.changeDir();
         var _loc2_:SpriteBloodBar = new SpriteBloodBar(ShotBehaviorManager.getMovieClip("pk_blood_bar"));
         _loc2_.setHp(this._info.hp,uint(FortressItemXMLInfo.getMaxHP(this._info.id,this._info.form)));
         additive = [_loc2_];
      }
      
      public function hideBmp() : void
      {
         DisplayUtil.removeForParent(this.bmp);
      }
      
      public function showBmp() : void
      {
         if(Boolean(this.bmp))
         {
            this.container.addChild(this.bmp);
         }
      }
      
      public function freeze() : void
      {
         this.isFreeze = true;
         EventManager.dispatchEvent(new DynamicEvent(BE_DESTROY,this));
         this.container.addChild(this.destroyMC);
         this.destroyMC.gotoAndPlay(2);
         setTimeout(function():void
         {
            TweenLite.to(container.parent,1,{
               "alpha":0,
               "onComplete":onComp
            });
         },1200);
         if(this._info.styleID >= 90000)
         {
            TeamPKManager.win();
         }
      }
      
      private function onComp() : void
      {
         DisplayUtil.removeForParent(this.container);
         this.container.mouseEnabled = false;
         this.container.mouseChildren = false;
      }
      
      private function changeDir() : void
      {
         var _loc1_:Class = null;
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
         if(this._info.id == 1)
         {
            if(this.colorType == TeamPKManager.HOME)
            {
               _loc1_ = this.redcls[this._info.form - 2];
               this.bmp = DisplayUtil.copyDisplayAsBmp(new _loc1_());
            }
            else
            {
               _loc1_ = this.bluecls[this._info.form - 2];
               this.bmp = DisplayUtil.copyDisplayAsBmp(new _loc1_());
            }
         }
         else
         {
            this.bmp = DisplayUtil.copyDisplayAsBmp(this._content);
         }
         this.container.addChild(this.bmp);
      }
      
      private function onADDStage(param1:Event) : void
      {
         this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
         DepthManager.swapDepth(this,y);
         DisplayUtil.removeForParent(this._content);
      }
      
      public function changeUI(param1:String) : void
      {
         if(Boolean(this._content))
         {
            this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
            DisplayUtil.removeForParent(this._content);
            this._content = null;
            DisplayUtil.removeForParent(this.bmp);
            this.bmp = null;
         }
         this._resURL = param1;
         ResourceManager.getResource(ClientConfig.getArmItem(this._resURL),this.onLoadRes);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.container.removeEventListener(MouseEvent.ROLL_OVER,this.overHandler);
         this.container.removeEventListener(MouseEvent.ROLL_OUT,this.outHandler);
         this.container.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         if(Boolean(this._content))
         {
            this._content.removeEventListener(Event.ADDED_TO_STAGE,this.onADDStage);
            DisplayUtil.removeForParent(this._content);
            this._content = null;
         }
         DisplayUtil.removeForParent(this.bmp);
         this.bmp = null;
         this.container = null;
         this._shotBehavior.destroy();
         this._shotBehavior = null;
         DisplayUtil.removeForParent(this.destroyMC);
         this.destroyMC = null;
         if(Boolean(this.interactive))
         {
            this.interactive.destroy();
         }
         this.interactive = null;
      }
   }
}

