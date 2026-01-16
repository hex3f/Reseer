package com.robot.core.mode
{
   import com.robot.core.aticon.PeculiarAction;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import com.robot.core.ui.nono.NonoInfoPanelController;
   import com.robot.core.ui.nono.NonoShortcut;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class NonoFlyModel extends BobyModel implements INonoModel
   {
      
      private var _url:String = "";
      
      private var _info:NonoInfo;
      
      private var _people:ActionSpriteModel;
      
      private var _flyMachineMc:MovieClip;
      
      private var _dirMc:MovieClip;
      
      private var _colorMc:MovieClip;
      
      private var _fireMc:MovieClip;
      
      public function NonoFlyModel(param1:NonoInfo, param2:ActionSpriteModel = null)
      {
         super();
         this._info = param1;
         this._people = param2;
         if(Boolean(param2))
         {
            this._url = ClientConfig.getNonoPath("nonoFlyModel/" + this._info.flyStyle + "/nonoFly");
            ResourceManager.getResource(this._url,this.onLoadMachineComHandler);
         }
      }
      
      public function set people(param1:ActionSpriteModel) : void
      {
         this._people = param1;
      }
      
      public function get people() : ActionSpriteModel
      {
         return this._people;
      }
      
      public function get info() : NonoInfo
      {
         return this._info;
      }
      
      override public function set direction(param1:String) : void
      {
         if(Boolean(this._flyMachineMc))
         {
            this._dirMc.gotoAndStop(param1);
            this._colorMc.gotoAndStop(param1);
            this._fireMc.gotoAndStop(param1);
         }
      }
      
      public function startPlay() : void
      {
      }
      
      public function stopPlay() : void
      {
      }
      
      override public function get centerPoint() : Point
      {
         return new Point();
      }
      
      override public function get hitRect() : Rectangle
      {
         return new Rectangle(0,0,0,0);
      }
      
      override public function set visible(param1:Boolean) : void
      {
      }
      
      private function onLoadMachineComHandler(param1:DisplayObject) : void
      {
         if(this._info == null)
         {
            return;
         }
         if(Boolean(param1))
         {
            this._flyMachineMc = param1 as MovieClip;
            this._dirMc = this._flyMachineMc["dirMc"];
            this._colorMc = this._flyMachineMc["colorMc"];
            this._fireMc = this._flyMachineMc["fireMc"];
            if(Boolean(this._people))
            {
               this.direction = this._people.direction;
               this._people.addEventListener(RobotEvent.WALK_START,this.onWalk);
            }
            this.config();
            if(Boolean(this._info) && this._info.userID == MainManager.actorID)
            {
               this._flyMachineMc.addEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
            }
            this._flyMachineMc.buttonMode = true;
            this._flyMachineMc.addEventListener(MouseEvent.CLICK,this.onClickHandler);
            DisplayUtil.FillColor(this._colorMc,this._info.color);
         }
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         NonoShortcut.hide();
      }
      
      private function config() : void
      {
         var _loc1_:Number = NaN;
         if(this._info.flyStyle == 1)
         {
            _loc1_ = -80;
            (this._people as BasePeoleModel).clickMc.y = -130;
         }
         else if(this._info.flyStyle == 2)
         {
            _loc1_ = -50;
            (this._people as BasePeoleModel).clickMc.y = -100;
         }
         else if(this._info.flyStyle == 3)
         {
            _loc1_ = -90;
            (this._people as BasePeoleModel).clickMc.y = -140;
         }
         else if(this._info.flyStyle == 4)
         {
            _loc1_ = -70;
            (this._people as BasePeoleModel).clickMc.y = -120;
         }
         new PeculiarAction().keepUp((this._people as BasePeoleModel).skeleton as EmptySkeletonStrategy,_loc1_);
         this._people.sprite.addChildAt(this._flyMachineMc,1);
      }
      
      private function onClickHandler(param1:MouseEvent) : void
      {
         NonoInfoPanelController.show(this._info);
      }
      
      private function onOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         if(this._people.walk.isPlaying)
         {
            return;
         }
         if(this._info.flyStyle == 4)
         {
            _loc2_ = this._flyMachineMc.localToGlobal(new Point(0,-35));
         }
         else
         {
            _loc2_ = this._flyMachineMc.localToGlobal(new Point(0,-65));
         }
         NonoShortcut.show(_loc2_,this._info,true);
      }
      
      override public function destroy() : void
      {
         if(this._url != "")
         {
            ResourceManager.cancelURL(this._url);
         }
         if(Boolean(this._people))
         {
            this._people.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         }
         if(Boolean(this._flyMachineMc))
         {
            DisplayUtil.removeForParent(this._flyMachineMc);
            this._flyMachineMc.removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
            this._flyMachineMc.removeEventListener(MouseEvent.CLICK,this.onClickHandler);
         }
         super.destroy();
         this._info = null;
         this._people = null;
         this._flyMachineMc = null;
         this._dirMc = null;
         this._colorMc = null;
         this._fireMc = null;
      }
   }
}

