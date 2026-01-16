package com.robot.core.mode
{
   import com.robot.core.CommandID;
   import com.robot.core.aticon.AimatAction;
   import com.robot.core.aticon.ChatAction;
   import com.robot.core.aticon.FigureAction;
   import com.robot.core.aticon.PeculiarAction;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.AimatXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.item.DoodleInfo;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.info.team.ITeamLogoInfo;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.additiveInfo.ISpriteAdditiveInfo;
   import com.robot.core.mode.additiveInfo.TeamPkPlayerSideInfo;
   import com.robot.core.mode.spriteInteractive.ClothLightInteractive;
   import com.robot.core.mode.spriteInteractive.ISpriteInteractiveAction;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import com.robot.core.skeleton.ISkeleton;
   import com.robot.core.skeleton.TransformSkeleton;
   import com.robot.core.teamInstallation.TeamLogo;
   import com.robot.core.utils.Direction;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   [Event(name="changeDirection",type="com.robot.core.event.RobotEvent")]
   [Event(name="walkStart",type="com.robot.core.event.RobotEvent")]
   [Event(name="walkEnd",type="com.robot.core.event.RobotEvent")]
   [Event(name="walkEnterFrame",type="com.robot.core.event.RobotEvent")]
   public class BasePeoleModel extends BobyModel implements ISkeletonSprite
   {
      
      public static var SPECIAL_ACTION:String = "action";
      
      public static const defaultY:int = 14;
      
      public static const defaultTopIconY:int = -70;
      
      public var isShield:Boolean = false;
      
      protected var _info:UserInfo;
      
      protected var tf:TextFormat;
      
      protected var _nameTxt:TextField;
      
      protected var _isProtected:Boolean = false;
      
      protected var _protectMC:MovieClip;
      
      protected var _skeletonSys:ISkeleton;
      
      protected var _oldSkeleton:ISkeleton;
      
      protected var _teamLogo:TeamLogo;
      
      protected var _interactiveAction:ISpriteInteractiveAction;
      
      private var _nono:INonoModel;
      
      private var _pet:PetModel;
      
      private var _tranMC:MovieClip;
      
      protected var clickBtn:Sprite;
      
      private var shieldMC:MovieClip;
      
      private var shieldTimer:Timer;
      
      private var _additiveInfo:ISpriteAdditiveInfo;
      
      private var clothLight:MovieClip;
      
      protected var _nameContainer:DisplayObjectContainer;
      
      private var _icon:Sprite;
      
      private var _topIconContainer:Sprite;
      
      public function BasePeoleModel(param1:UserInfo)
      {
         var _loc2_:PetShowInfo = null;
         super();
         this._info = param1;
         mouseEnabled = false;
         name = "BasePeoleModel_" + this._info.userID.toString();
         this.tf = new TextFormat();
         this.tf.font = "宋体";
         this.tf.letterSpacing = 0.5;
         this.tf.size = 12;
         this.tf.align = TextFormatAlign.CENTER;
         this._nameTxt = new TextField();
         this._nameTxt.mouseEnabled = false;
         this._nameTxt.autoSize = TextFieldAutoSize.CENTER;
         this._nameTxt.width = 100;
         this._nameTxt.height = 30;
         this._nameTxt.x = this.nameTxt.width / 2 - 4;
         this._nameTxt.text = this._info.nick;
         this._nameTxt.setTextFormat(this.tf);
         addChild(UIManager.getMovieClip("show_mc"));
         this._nameContainer = new Sprite();
         this._nameContainer.name = "nameContainer";
         this._nameContainer.y = defaultY;
         this._nameContainer.cacheAsBitmap = true;
         addChild(this._nameContainer);
         this._topIconContainer = new Sprite();
         this._topIconContainer.y = defaultTopIconY;
         this._topIconContainer.cacheAsBitmap = true;
         addChild(this._topIconContainer);
         this.skeleton = new EmptySkeletonStrategy();
         if(param1.changeShape != 0)
         {
            this.skeleton = new TransformSkeleton();
         }
         pos = this._info.pos;
         this.direction = Direction.indexToStr(this._info.direction);
         if(this._info.action > 10000)
         {
            this.peculiarAction(direction,false);
         }
         if(this._info.spiritID != 0)
         {
            _loc2_ = new PetShowInfo();
            _loc2_.catchTime = this._info.spiritTime;
            _loc2_.petID = this._info.spiritID;
            _loc2_.userID = this._info.userID;
            _loc2_.dv = this._info.petDV;
            _loc2_.skinID = this._info.petSkin;
            this.showPet(_loc2_);
         }
         this.clickBtn = new Sprite();
         this.clickBtn.graphics.beginFill(0,0);
         this.clickBtn.graphics.drawRect(0,0,40,50);
         this.clickBtn.graphics.endFill();
         this.clickBtn.buttonMode = true;
         this.clickBtn.x = -20;
         this.clickBtn.y = -50;
         addChild(this.clickBtn);
         this._additiveInfo = new TeamPkPlayerSideInfo(this);
         this.interactiveAction = new ClothLightInteractive(this);
         this.addEvent();
         this.refreshTitle(this._info.curTitle);
      }
      
      public function get clickMc() : Sprite
      {
         return this.clickBtn;
      }
      
      public function refreshTitle(param1:uint) : void
      {
         DisplayUtil.removeForParent(this._icon);
         this._icon = null;
         this._info.curTitle = param1;
         if(this._info.curTitle > 0)
         {
            this._nameContainer.x = 5;
            this._nameContainer.addChild(this._nameTxt);
            this.getMedal();
         }
         else
         {
            this._nameContainer.y = defaultY;
            this._nameContainer.x = 0;
            this._nameContainer.addChild(this._nameTxt);
         }
      }
      
      public function switchTitle(param1:Boolean) : void
      {
         if(param1)
         {
            this.getMedal();
         }
         else
         {
            DisplayUtil.removeForParent(this._icon);
            this._icon = null;
            this._nameContainer.y = defaultY;
         }
      }
      
      private function getMedal() : void
      {
         var _url:String = null;
         var _p:BasePeoleModel = null;
         _p = null;
         DisplayUtil.removeForParent(this._icon);
         this._icon = null;
         _p = this;
         _url = ClientConfig.getResPath("achieve/title/" + this._info.curTitle + ".swf");
         ResourceManager.getResource(_url,function(param1:DisplayObject):void
         {
            var _loc2_:Rectangle = null;
            if(Boolean(param1))
            {
               _icon = param1 as Sprite;
               addChild(_icon);
               _loc2_ = _icon.getBounds(_p);
               _icon.x = -(_loc2_.x + _loc2_.width / 2) + 3;
               _icon.y = 16;
               _nameContainer.y = 32;
            }
         },"title");
      }
      
      public function showClothLight(param1:Boolean = false) : void
      {
         if(param1)
         {
            DisplayUtil.removeForParent(this.clothLight);
            return;
         }
         DisplayUtil.removeForParent(this.clothLight);
         var _loc2_:uint = this.info.clothMaxLevel;
         if(_loc2_ > 1)
         {
            ResourceManager.getResource(ClientConfig.getClothLightUrl(_loc2_),this.onLoadLight);
         }
      }
      
      private function onLoadLight(param1:DisplayObject) : void
      {
         this.clothLight = param1 as MovieClip;
         this.addChild(this.clothLight);
      }
      
      public function addProtectMC() : void
      {
         if(!this._protectMC)
         {
            this._protectMC = this.getProtectMC();
         }
         if(!DisplayUtil.hasParent(this._protectMC))
         {
            this._protectMC.gotoAndStop(1);
            addChild(this._protectMC);
         }
         this._isProtected = true;
      }
      
      public function aimatAction(param1:uint, param2:uint, param3:Point, param4:Boolean = true) : void
      {
         if(param4)
         {
            SocketConnection.send(CommandID.AIMAT,param1,param2,param3.x,param3.y);
         }
         else
         {
            this.stop();
            AimatAction.execute(param1,param2,this._info.userID,this,param3);
         }
      }
      
      override public function aimatState(param1:AimatInfo) : void
      {
         if(this._isProtected)
         {
            this._protectMC.gotoAndPlay(2);
            return;
         }
         super.aimatState(param1);
      }
      
      override public function get centerPoint() : Point
      {
         _centerPoint.x = x;
         _centerPoint.y = y - 20;
         return _centerPoint;
      }
      
      public function set interactiveAction(param1:ISpriteInteractiveAction) : void
      {
         if(Boolean(this._interactiveAction))
         {
            this._interactiveAction.destroy();
         }
         if(param1 == null)
         {
            this._interactiveAction = new ClothLightInteractive(this);
         }
         else
         {
            this._interactiveAction = param1;
         }
      }
      
      public function changeCloth(param1:Array, param2:Boolean = true) : void
      {
         new FigureAction().changeCloth(this,param1,param2);
      }
      
      public function changeColor(param1:uint, param2:Boolean = true) : void
      {
         new FigureAction().changeColor(this,param1,param2);
      }
      
      public function changeDoodle(param1:DoodleInfo, param2:Boolean = true) : void
      {
         new FigureAction().changeDoodle(this,param1,param2);
      }
      
      public function changeNickName(param1:String, param2:Boolean = true) : void
      {
         new FigureAction().changeNickName(this,param1,param2);
         if(!param2)
         {
            this._nameTxt.text = param1;
            this._nameTxt.setTextFormat(this.tf);
         }
      }
      
      public function chatAction(param1:String, param2:uint = 0, param3:Boolean = true) : void
      {
         new ChatAction().execute(this,param1,param2,param3);
      }
      
      public function delProtectMC() : void
      {
         DisplayUtil.removeForParent(this._protectMC,false);
         this._isProtected = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEvent();
         this.hidePet();
         this.hideNono();
         this._pet = null;
         DisplayUtil.removeForParent(this);
         this._info = null;
         this._skeletonSys = null;
         DisplayUtil.removeForParent(this._protectMC);
         this._protectMC = null;
         if(Boolean(this._teamLogo))
         {
            this._teamLogo.destroy();
         }
         this._teamLogo = null;
         if(Boolean(this._interactiveAction))
         {
            this._interactiveAction.destroy();
            this._interactiveAction = null;
         }
         DisplayUtil.removeForParent(this.clothLight);
         this.clothLight = null;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         _direction = param1;
         this._skeletonSys.changeDirection(param1);
         dispatchEvent(new DynamicEvent(RobotEvent.CHANGE_DIRECTION,param1));
      }
      
      public function get skeleton() : ISkeleton
      {
         return this._skeletonSys;
      }
      
      override public function get height() : Number
      {
         return this._skeletonSys.getBodyMC().height;
      }
      
      public function hideNono() : void
      {
         if(Boolean(this._nono))
         {
            this._nono.destroy();
            this._nono = null;
         }
      }
      
      public function hidePet() : void
      {
         if(Boolean(this._pet))
         {
            this._pet.destroy();
            this._pet = null;
         }
      }
      
      override public function get hitRect() : Rectangle
      {
         _hitRect.x = x + this.clickBtn.x;
         _hitRect.y = y + this.clickBtn.y;
         _hitRect.width = 35;
         _hitRect.height = 40;
         return _hitRect;
      }
      
      public function get nameTxt() : TextField
      {
         return this._nameTxt;
      }
      
      public function get info() : UserInfo
      {
         return this._info;
      }
      
      public function get additiveInfo() : ISpriteAdditiveInfo
      {
         return this._additiveInfo;
      }
      
      public function get isTransform() : Boolean
      {
         return this._skeletonSys is TransformSkeleton;
      }
      
      public function get isProtected() : Boolean
      {
         return this._isProtected;
      }
      
      public function get nono() : INonoModel
      {
         return this._nono;
      }
      
      public function peculiarAction(param1:String = "", param2:Boolean = true) : void
      {
         new PeculiarAction().execute(this,param1,param2);
      }
      
      public function get pet() : PetModel
      {
         return this._pet;
      }
      
      public function removeTeamLogo() : void
      {
         DisplayUtil.removeForParent(this._teamLogo,false);
      }
      
      public function set skeleton(param1:ISkeleton) : void
      {
         if(Boolean(this._skeletonSys))
         {
            this._oldSkeleton = this._skeletonSys;
         }
         this._skeletonSys = param1;
         this._skeletonSys.people = this;
         this._skeletonSys.info = this._info;
      }
      
      public function clearOldSkeleton() : void
      {
         if(Boolean(this._oldSkeleton))
         {
            this._oldSkeleton.destroy();
            this._oldSkeleton = null;
         }
      }
      
      public function showNono(param1:NonoInfo, param2:uint = 0) : void
      {
         param1.flyStyle = param2;
         if(Boolean(this._nono))
         {
            this._nono.destroy();
            this._nono = null;
         }
         if(param1.superStage == 0)
         {
            param1.superStage = 1;
         }
         if(param2 == 0)
         {
            this._nono = new NonoModel(param1,this);
         }
         else if(param1.userID == MainManager.actorInfo.userID)
         {
            this._nono = new NonoFlyModel(param1,this);
         }
         else
         {
            this._nono = new NonoModel(param1,this);
         }
      }
      
      public function showNonoShield(param1:uint) : void
      {
         if(!this.shieldTimer)
         {
            this.shieldTimer = new Timer(param1 * 1000,1);
            this.shieldTimer.addEventListener(TimerEvent.TIMER,this.onShieldTimer);
         }
         this.shieldTimer.reset();
         this.shieldTimer.start();
         this.isShield = true;
         if(!this.shieldMC)
         {
            this.shieldMC = ShotBehaviorManager.getMovieClip("pk_nono_shield");
         }
         this.shieldMC.gotoAndStop(1);
         addChild(this.shieldMC);
      }
      
      public function showPet(param1:PetShowInfo) : void
      {
         this.destroyPet();
         if(PetXMLInfo.isFlyPet(param1.petID) || PetXMLInfo.isRidePet(param1.petID))
         {
            if(this._info.actionType == 0)
            {
               this._pet = new FlyPetModel(this);
            }
            else
            {
               this._pet = new PetModel(this);
            }
         }
         else
         {
            this._pet = new PetModel(this);
         }
         this._pet.show(param1);
      }
      
      private function destroyPet() : void
      {
         if(Boolean(this._pet))
         {
            this._pet.destroy();
            this._pet = null;
         }
      }
      
      public function set topIconY(param1:int) : void
      {
         this._topIconContainer.y = param1;
      }
      
      public function get TitleIcon() : DisplayObjectContainer
      {
         return this._icon;
      }
      
      public function showShieldMovie() : void
      {
         this.shieldMC.gotoAndPlay(2);
      }
      
      public function showTeamLogo(param1:ITeamLogoInfo) : void
      {
         if(param1 is SimpleTeamInfo)
         {
            if(SimpleTeamInfo(param1).superCoreNum < 10)
            {
               return;
            }
         }
         if(!this._teamLogo)
         {
            this._teamLogo = new TeamLogo();
         }
         this._teamLogo.info = param1;
         this._teamLogo.scaleX = this._teamLogo.scaleY = 0.6;
         this._teamLogo.x = -this._teamLogo.width / 2;
         this._teamLogo.y = -60 - this._teamLogo.height * this._teamLogo.scaleX - 5;
         addChild(this._teamLogo);
      }
      
      public function specialAction(param1:uint) : void
      {
         this._skeletonSys.specialAction(this,param1);
      }
      
      override public function stop() : void
      {
         super.stop();
         if(Boolean(this._pet))
         {
            this._pet.stop();
         }
      }
      
      public function stopSpecialAct() : void
      {
         this.direction = Direction.DOWN;
      }
      
      public function takeOffCloth() : void
      {
         this._skeletonSys.takeOffCloth();
      }
      
      public function walkAction(param1:Object, param2:Boolean = true) : void
      {
         _walk.execute(this,param1,param2);
      }
      
      override public function get width() : Number
      {
         return this._skeletonSys.getBodyMC().width;
      }
      
      protected function addEvent() : void
      {
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         this.clickBtn.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.clickBtn.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.clickBtn.addEventListener(MouseEvent.CLICK,this.onClick);
         UserManager.addActionListener(this._info.userID,this.onAction);
         addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterFrame);
      }
      
      protected function onWalkEnd(param1:Event) : void
      {
         this._skeletonSys.stop();
      }
      
      private function getProtectMC() : MovieClip
      {
         var _loc1_:MovieClip = UIManager.getMovieClip("ui_TandS_Protecte_MC");
         _loc1_.mouseChildren = false;
         _loc1_.mouseEnabled = false;
         return _loc1_;
      }
      
      private function hideShield() : void
      {
         this.isShield = false;
         DisplayUtil.removeForParent(this.shieldMC,false);
      }
      
      private function onAction(param1:PeopleActionEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:NonoInfo = null;
         switch(param1.actionType)
         {
            case PeopleActionEvent.WALK:
               this.walkAction(param1.data,false);
               break;
            case PeopleActionEvent.CHAT:
               this.chatAction(param1.data as String,0,false);
               break;
            case PeopleActionEvent.COLOR_CHANGE:
               this._info.coins = param1.data.coins as uint;
               this.changeColor(param1.data.color,false);
               break;
            case PeopleActionEvent.CLOTH_CHANGE:
               this.changeCloth(param1.data as Array,false);
               break;
            case PeopleActionEvent.DOODLE_CHANGE:
               this.changeDoodle(param1.data as DoodleInfo,false);
               break;
            case PeopleActionEvent.PET_SHOW:
               this.showPet(param1.data as PetShowInfo);
               break;
            case PeopleActionEvent.PET_HIDE:
               this.hidePet();
               break;
            case PeopleActionEvent.NAME_CHANGE:
               this.changeNickName(param1.data.nickName,false);
               break;
            case PeopleActionEvent.AIMAT:
               _loc2_ = param1.data.type as uint;
               if(_loc2_ > 10000)
               {
                  if(AimatXMLInfo.getType(this._info.clothIDs) == 0)
                  {
                     return;
                  }
               }
               this.aimatAction(param1.data.itemID,_loc2_,param1.data.pos as Point,false);
               break;
            case PeopleActionEvent.SPECIAL:
               this.peculiarAction(param1.data as String,false);
               break;
            case PeopleActionEvent.NONO_FOLLOW:
               _loc3_ = param1.data as NonoInfo;
               this.showNono(_loc3_);
               break;
            case PeopleActionEvent.NONO_HOOM:
               this.hideNono();
               break;
            case PeopleActionEvent.SET_TITLE:
               this.refreshTitle(param1.data as uint);
         }
      }
      
      private function onShieldTimer(param1:TimerEvent) : void
      {
         this.hideShield();
      }
      
      private function onWalkEnterFrame(param1:Event) : void
      {
      }
      
      private function onWalkStart(param1:Event) : void
      {
         this._skeletonSys.play();
      }
      
      private function removeEvent() : void
      {
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         this.clickBtn.removeEventListener(MouseEvent.CLICK,this.onClick);
         UserManager.removeActionListener(this._info.userID,this.onAction);
         removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterFrame);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         this._interactiveAction.rollOver();
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         this._interactiveAction.rollOut();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this._interactiveAction.click();
      }
   }
}

