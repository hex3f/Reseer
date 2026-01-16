package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.MovesLangXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.*;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.*;
   import flash.net.*;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import gs.TweenLite;
   import gs.easing.Back;
   import org.taomee.manager.*;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MathUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class OgreModel extends BobyModel
   {
      
      public static var isShow:Boolean = true;
      
      private var _id:uint;
      
      private var _index:uint;
      
      private var _obj:MovieClip;
      
      private var _dialogTime:uint;
      
      private const PATH_STR:String = "resource/pet/sound/";
      
      private var idList:Array = [1,4,7,19,27,53,59,62,65,102,108,122,133,143,164,203,217,219,237,240,254,269,281,284,378,422,482,509,580,588];
      
      private var _sound:Sound;
      
      public function OgreModel(param1:uint)
      {
         super();
         _speed = 2;
         mouseEnabled = false;
         this._index = param1;
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
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get index() : uint
      {
         return this._index;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(Boolean(this._obj))
         {
            this._obj.gotoAndStop(param1);
         }
      }
      
      override public function get centerPoint() : Point
      {
         _centerPoint.x = x;
         _centerPoint.y = y - 10;
         return _centerPoint;
      }
      
      override public function get hitRect() : Rectangle
      {
         _hitRect.x = x - this.width / 2;
         _hitRect.y = y - this.height;
         _hitRect.width = this.width;
         _hitRect.height = this.height;
         return _hitRect;
      }
      
      public function show(param1:uint, param2:Point) : void
      {
         if(Boolean(this._obj))
         {
            return;
         }
         this._id = param1;
         pos = param2;
         autoRect = new Rectangle(param2.x - 20,param2.y - 20,40,40);
         alpha = 0;
         if(isShow)
         {
            ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),this.onLoad,"pet");
         }
      }
      
      private function playSound() : void
      {
         if(Boolean(this._sound))
         {
            this._sound = null;
         }
         this._sound = new Sound();
         this._sound.load(new URLRequest(this.PATH_STR + this._id + ".mp3"));
         this._sound.play();
      }
      
      override public function destroy() : void
      {
         clearInterval(this._dialogTime);
         super.destroy();
         if(Boolean(this._obj))
         {
            this._obj.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
         ResourceManager.cancel(ClientConfig.getPetSwfPath(this._id),this.onLoad);
         this.effect("Pet_Effect_Out");
         TweenLite.to(this,1,{
            "alpha":0,
            "ease":Back.easeOut,
            "onComplete":this.onFinishTween
         });
      }
      
      private function effect(param1:String) : void
      {
         var _loc2_:MovieClip = UIManager.getMovieClip(param1);
         MovieClipUtil.playEndAndRemove(_loc2_);
         addChild(_loc2_);
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         var _loc2_:MovieClip = null;
         this._obj = param1 as MovieClip;
         this._obj.gotoAndStop(_direction);
         this._obj.buttonMode = true;
         this._obj.addEventListener(MouseEvent.CLICK,this.onClick);
         addChild(this._obj);
         this.effect("Pet_Effect_Over");
         MapManager.currentMap.depthLevel.addChild(this);
         TweenLite.to(this,1,{"alpha":1});
         starAutoWalk(3000);
         MovieClipUtil.childStop(this._obj,1);
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
         if(Boolean(NonoManager.info))
         {
            if(Boolean(NonoManager.info.func[9]))
            {
               clearInterval(this._dialogTime);
               this._dialogTime = setInterval(this.onAutoDialog,MathUtil.randomHalfAdd(10000));
            }
         }
         if(this.idList.indexOf(this._id) > -1)
         {
            _loc2_ = AssetsManager.getMovieClip("pk_flash_mc");
            this._obj.addChildAt(_loc2_,0);
            this.playSound();
         }
      }
      
      private function onFinishTween() : void
      {
         DisplayUtil.removeForParent(this);
         this._obj = null;
      }
      
      private function onAutoDialog() : void
      {
         var _loc1_:String = MovesLangXMLInfo.getRandomLang(this._id);
         if(_loc1_ != "")
         {
            showBox(_loc1_);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         dispatchEvent(new RobotEvent(RobotEvent.OGRE_CLICK));
      }
      
      private function onWalkStart(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(this._obj))
         {
            _loc2_ = this._obj.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               if(_loc2_.currentFrame == 1)
               {
                  _loc2_.gotoAndPlay(2);
               }
            }
         }
      }
      
      private function onWalkOver(param1:Event) : void
      {
         if(Boolean(this._obj))
         {
            MovieClipUtil.childStop(this._obj,1);
         }
      }
   }
}

