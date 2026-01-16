package com.robot.app.sceneInteraction
{
   import com.robot.core.CommandID;
   import com.robot.core.aimat.AimatStateManamer;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.ActionSpriteModel;
   import com.robot.core.mode.IAimatSprite;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.DialogBox;
   import com.robot.core.utils.Direction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.Utils;
   
   public class BailuenModel extends ActionSpriteModel implements IAimatSprite
   {
      
      private static const atype:Array = [10020,10021,10022];
      
      private static const OVER:int = 2;
      
      private static const HIT:int = 42;
      
      private static const FIGHT:int = 46;
      
      private static const DIE:int = 317;
      
      private static const OVER_END:int = 41;
      
      private static const HIT_END:int = 45;
      
      private static const FIGHT_END:int = 316;
      
      private static const DIE_END:int = 337;
      
      public static const FIG:String = "bailuenfig";
      
      private static const SWFPATH:String = ClientConfig.getResPath("body/bailuenNpc.swf");
      
      protected var _aimatStateManager:AimatStateManamer;
      
      protected var _dialogBox:DialogBox;
      
      private var _obj:MovieClip;
      
      private var _eff:Boolean;
      
      private var _currAction:int = 1;
      
      private var _bloodMc:Sprite;
      
      private var _nameTxt:TextField;
      
      private var _panel:Sprite;
      
      private var _load:MCLoader;
      
      public function BailuenModel()
      {
         super();
         this._aimatStateManager = new AimatStateManamer(this);
         addEventListener(MouseEvent.CLICK,this.onClick);
         this._nameTxt = new TextField();
         this._nameTxt.mouseEnabled = false;
         this._nameTxt.autoSize = TextFieldAutoSize.LEFT;
         this._nameTxt.text = "拜伦号扫荡者";
         this._nameTxt.textColor = 238;
         this._nameTxt.x = -this._nameTxt.textWidth / 2;
         this._nameTxt.y = 100;
         this._nameTxt.filters = [new GlowFilter(16777215,1,2,2,5)];
         addChild(this._nameTxt);
      }
      
      public function get aimatStateManager() : AimatStateManamer
      {
         return this._aimatStateManager;
      }
      
      override public function get width() : Number
      {
         if(Boolean(this._obj))
         {
            return this._obj.width;
         }
         return super.width;
      }
      
      override public function get height() : Number
      {
         if(Boolean(this._obj))
         {
            return this._obj.height;
         }
         return super.height;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         _direction = param1;
         if(Boolean(this._obj))
         {
            switch(_direction)
            {
               case Direction.DOWN:
               case Direction.RIGHT_DOWN:
               case Direction.RIGHT_UP:
               case Direction.RIGHT:
                  this._obj.scaleX = -1;
                  break;
               case Direction.UP:
               case Direction.LEFT:
               case Direction.LEFT_UP:
               case Direction.LEFT_DOWN:
                  this._obj.scaleX = 1;
            }
         }
      }
      
      public function set hp(param1:uint) : void
      {
         if(this._bloodMc == null)
         {
            this._bloodMc = UIManager.getSprite("BloodBox_MC");
            this._bloodMc.scaleX = 0.6;
            this._bloodMc.scaleY = 0.6;
            this._bloodMc.y = -80;
            this._bloodMc.x = -this._bloodMc.width / 2;
            addChild(this._bloodMc);
         }
         this._bloodMc["maskMc"].width = param1 / 100 * this._bloodMc["viswMc"].width;
         if(param1 == 0)
         {
            this.setAction(DIE);
         }
      }
      
      public function show(param1:Point, param2:Boolean) : void
      {
         if(Boolean(this._obj))
         {
            return;
         }
         pos = param1;
         this._eff = param2;
         ResourceManager.getResource(SWFPATH,this.onLoad);
      }
      
      public function fight() : void
      {
         this.setAction(FIGHT);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._aimatStateManager.destroy();
         this._aimatStateManager = null;
         removeEventListener(MouseEvent.CLICK,this.onClick);
         if(Boolean(this._dialogBox))
         {
            this._dialogBox.destroy();
            this._dialogBox = null;
         }
         ResourceManager.cancel(SWFPATH,this.onLoad);
         DisplayUtil.removeForParent(this);
         this._obj.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         this._obj = null;
         this._bloodMc = null;
         if(Boolean(this._panel))
         {
            this._panel["okBtn"].removeEventListener(MouseEvent.CLICK,this.onOKClick);
            DisplayUtil.removeForParent(this._panel);
            this._panel = null;
         }
         if(Boolean(this._load))
         {
            this._load.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadPanel);
            this._load.clear();
            this._load = null;
         }
      }
      
      public function aimatState(param1:AimatInfo) : void
      {
         if(this._currAction != 1)
         {
            return;
         }
         if(atype.indexOf(param1.id) == -1)
         {
            return;
         }
         if(Boolean(this._aimatStateManager))
         {
            this._aimatStateManager.execute(param1);
         }
         SocketConnection.send(CommandID.ATTACK_BAILUEN);
         this.setAction(HIT);
      }
      
      public function showBox(param1:String, param2:Number = 0) : void
      {
         if(Boolean(this._dialogBox))
         {
            this._dialogBox.destroy();
            this._dialogBox = null;
         }
         this._dialogBox = new DialogBox();
         this._dialogBox.name = "dialogBox";
         this._dialogBox.show(param1,0,-this.height + param2,this);
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         this.direction = _direction;
         this._obj.gotoAndStop(1);
         addChild(this._obj);
         if(this._eff)
         {
            this.setAction(OVER);
         }
         else
         {
            this.setDef();
         }
      }
      
      private function setAction(param1:int) : void
      {
         if(Boolean(this._obj))
         {
            this._obj.addEventListener(Event.ENTER_FRAME,this.onEnter);
            this._obj.gotoAndPlay(param1);
            this._currAction = param1;
         }
         stopAutoWalk();
      }
      
      private function setDef() : void
      {
         if(Boolean(this._obj))
         {
            this._obj.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         }
         this._currAction = 1;
         starAutoWalk(3000);
      }
      
      private function onEnter(param1:Event) : void
      {
         if(this._currAction == OVER)
         {
            if(this._obj.currentFrame == OVER_END)
            {
               this.setDef();
               this.showBox("发现入侵者，开始进入清除模式！",100);
            }
         }
         else if(this._currAction == HIT)
         {
            if(this._obj.currentFrame == OVER_END)
            {
               this.setDef();
            }
         }
         else if(this._currAction == FIGHT)
         {
            if(this._obj.currentFrame == FIGHT_END)
            {
               this.setDef();
               dispatchEvent(new Event(FIG));
            }
         }
         else if(this._currAction == DIE)
         {
            if(this._obj.currentFrame == DIE_END)
            {
               this._obj.removeEventListener(Event.ENTER_FRAME,this.onEnter);
               this._currAction = 1;
            }
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(Boolean(this._panel))
         {
            LevelManager.topLevel.addChild(this._panel);
            DisplayUtil.align(this._panel,null,AlignType.MIDDLE_CENTER);
            return;
         }
         this._load = new MCLoader();
         this._load.addEventListener(MCLoadEvent.SUCCESS,this.onLoadPanel);
         this._load.doLoad(ClientConfig.getResPath("body/bailuenalert.swf"));
      }
      
      private function onLoadPanel(param1:MCLoadEvent) : void
      {
         this._load.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadPanel);
         var _loc2_:Class = Utils.getClassFromLoader("UI_BailuenPanel",this._load.loader);
         this._panel = new _loc2_() as Sprite;
         if(Boolean(this._panel))
         {
            LevelManager.topLevel.addChild(this._panel);
            DisplayUtil.align(this._panel,null,AlignType.MIDDLE_CENTER);
            this._panel["okBtn"].addEventListener(MouseEvent.CLICK,this.onOKClick);
         }
      }
      
      private function onOKClick(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._panel);
      }
   }
}

