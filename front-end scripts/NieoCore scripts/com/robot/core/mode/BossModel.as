package com.robot.core.mode
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import gs.TweenLite;
   import gs.easing.Back;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class BossModel extends BobyModel
   {
      
      protected var _id:uint;
      
      protected var _hp:uint;
      
      protected var _obj:MovieClip;
      
      protected var _region:uint;
      
      private var _startPos:Point;
      
      private var _inTime:uint;
      
      private var _isMove:Boolean = false;
      
      public function BossModel(param1:uint, param2:uint)
      {
         super();
         this._id = param1;
         this._region = param2;
         _speed = 2;
         mouseEnabled = false;
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
      
      public function get hp() : uint
      {
         return this._hp;
      }
      
      public function set hp(param1:uint) : void
      {
         this._hp = param1;
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
            if(this.id != 47 && this.id != 219 && this.id != 432)
            {
               MovieClipUtil.childStop(this._obj,1);
            }
         }
      }
      
      override public function get centerPoint() : Point
      {
         _centerPoint.x = x;
         _centerPoint.y = y - 20;
         return _centerPoint;
      }
      
      override public function get hitRect() : Rectangle
      {
         _hitRect.x = x - this.width / 2;
         _hitRect.y = y - 20 - this.height / 2;
         _hitRect.width = this.width;
         _hitRect.height = this.height;
         return _hitRect;
      }
      
      public function show(param1:Point, param2:uint) : void
      {
         this._startPos = param1.clone();
         if(Boolean(this._obj))
         {
            this._isMove = true;
            if(Boolean(this._inTime))
            {
               clearInterval(this._inTime);
            }
            _walk.execute(this,param1,false);
            return;
         }
         pos = param1;
         alpha = 0;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this.id),this.onLoad,"pet");
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this._obj))
         {
            this._obj.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
         if(Boolean(this._inTime))
         {
            clearInterval(this._inTime);
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
      
      override public function aimatState(param1:AimatInfo) : void
      {
         super.aimatState(param1);
         if(Boolean(_aimatStateManager))
         {
            SocketConnection.send(CommandID.ATTACK_BOSS,this._region);
         }
      }
      
      private function allerWalk() : void
      {
         if(!MapManager.isInMap)
         {
            return;
         }
         _walk.execute(this,this._startPos.add(Point.polar(50 - Math.random() * 100,Math.random())),false);
      }
      
      private function effect(param1:String) : void
      {
         var _loc2_:MovieClip = UIManager.getMovieClip(param1);
         MovieClipUtil.playEndAndRemove(_loc2_);
         addChild(_loc2_);
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         this._obj.gotoAndStop(_direction);
         this._obj.buttonMode = true;
         this._obj.addEventListener(MouseEvent.CLICK,this.onClick);
         addChild(this._obj);
         this.effect("Pet_Effect_Over");
         MapManager.currentMap.depthLevel.addChild(this);
         TweenLite.to(this,1,{"alpha":1});
         MovieClipUtil.childStop(this._obj,1);
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
      }
      
      private function onFinishTween() : void
      {
         DisplayUtil.stopAllMovieClip(this);
         DisplayUtil.removeForParent(this);
         this._obj = null;
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
         if(this._isMove)
         {
            this._isMove = false;
            this._inTime = setInterval(this.allerWalk,3000);
         }
      }
   }
}

