package com.robot.core.aticon
{
   import com.robot.core.CommandID;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.IActionSprite;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.Direction;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import gs.TweenMax;
   import gs.events.TweenEvent;
   import org.taomee.manager.DepthManager;
   
   public class FlyAction implements IWalk
   {
      
      private static var _shared_walk_frame_event:RobotEvent = new RobotEvent(RobotEvent.WALK_ENTER_FRAME);
      
      private var _isPlaying:Boolean = false;
      
      private var _obj:IActionSprite;
      
      private var _startPoint:Point;
      
      private var _endPoint:Point;
      
      private var _curvePoint:Point;
      
      private var _speed:Number = 150;
      
      private const MIN_DISTANCE:uint = 100;
      
      private var _time:Number;
      
      private var _tween:TweenMax;
      
      private var _color:uint;
      
      private var _isFly:Boolean;
      
      private var _isNet:Boolean;
      
      private const CURVE:Number = 2.5;
      
      private var _superLevel:int;
      
      public function FlyAction(param1:IActionSprite)
      {
         super();
         this.init();
         this._obj = param1;
         this._isNet = false;
         this._isFly = false;
      }
      
      public function execute_point(param1:IActionSprite, param2:Point, param3:Boolean = true) : void
      {
      }
      
      public function get endP() : Point
      {
         return this._endPoint;
      }
      
      public function get remData() : Array
      {
         return new Array();
      }
      
      public function get isPlaying() : Boolean
      {
         return this._isPlaying;
      }
      
      public function get endPoint() : Point
      {
         return this._endPoint;
      }
      
      public function init() : void
      {
         this._obj = null;
         this._tween = null;
         this._startPoint = null;
         this._endPoint = null;
         this._curvePoint = null;
         this._isPlaying = false;
      }
      
      public function execute(param1:IActionSprite, param2:Object, param3:Boolean = false) : void
      {
         var nn:uint = 0;
         nn = 0;
         var obj:IActionSprite = param1;
         var endP:Object = param2;
         var isNet:Boolean = param3;
         if(!obj)
         {
            return;
         }
         if(!MapManager.currentMap.isBlock(endP as Point))
         {
            return;
         }
         this._isNet = isNet;
         this._obj = obj;
         this._startPoint = this._obj.pos;
         this._endPoint = endP as Point;
         DepthManager.bringToTop(this._obj.sprite);
         this._obj.direction = Direction.getStr(this._startPoint,this._endPoint);
         if(Boolean((this._obj as BasePeoleModel).nono))
         {
            nn = setTimeout(function():void
            {
               clearTimeout(nn);
               if(Boolean(_obj))
               {
                  (_obj as BasePeoleModel).nono.direction = _obj.direction;
               }
            },100);
         }
         this._time = Point.distance(this._startPoint,this._endPoint) / this._speed;
         this._curvePoint = this._startPoint;
         this._isPlaying = true;
         this.fly(this._time,this._curvePoint,this._endPoint);
      }
      
      private function fly(param1:Number, param2:Point, param3:Point) : void
      {
         var _loc4_:Array = null;
         var _loc5_:ByteArray = null;
         if(!this._obj)
         {
            return;
         }
         if(Boolean((this._obj as BasePeoleModel).nono))
         {
            (this._obj as BasePeoleModel).nono.startPlay();
         }
         this._obj.sprite.dispatchEvent(new RobotEvent(RobotEvent.WALK_START));
         this._obj.sprite.addEventListener(Event.ENTER_FRAME,this.onEnterHandler);
         if(Boolean(this._tween))
         {
            this._tween.pause();
            this._tween.removeEventListener(TweenEvent.COMPLETE,this.onComHandler);
            this._tween = null;
         }
         this._tween = TweenMax.to(this._obj,param1,{
            "bezier":[{
               "x":param2.x,
               "y":param2.y
            },{
               "x":param3.x,
               "y":param3.y
            }],
            "orientToBezier":false
         });
         this._tween.addEventListener(TweenEvent.COMPLETE,this.onComHandler);
         if(this._isNet)
         {
            _loc4_ = [];
            _loc4_[0] = this._obj.pos;
            _loc5_ = new ByteArray();
            _loc5_.writeObject(_loc4_);
            SocketConnection.send(CommandID.PEOPLE_WALK,MainManager.actorInfo.actionType,this._endPoint.x,this._endPoint.y,_loc5_.length,_loc5_);
         }
      }
      
      private function onEnterHandler(param1:Event) : void
      {
         if(Boolean(this._obj))
         {
            this._obj.sprite.dispatchEvent(_shared_walk_frame_event);
         }
      }
      
      public function play() : void
      {
      }
      
      public function stop() : void
      {
         this._obj = null;
         if(Boolean(this._tween))
         {
            if(this._isPlaying)
            {
               this._tween.pause();
            }
            this._tween.removeEventListener(TweenEvent.COMPLETE,this.onComHandler);
            this._tween = null;
         }
      }
      
      private function onComHandler(param1:TweenEvent) : void
      {
         if(!this._obj)
         {
            return;
         }
         this._obj.sprite.removeEventListener(Event.ENTER_FRAME,this.onEnterHandler);
         this._tween.removeEventListener(TweenEvent.COMPLETE,this.onComHandler);
         this._isPlaying = false;
         (this._obj as BasePeoleModel).nono.stopPlay();
         this._obj.sprite.dispatchEvent(new RobotEvent(RobotEvent.WALK_END));
      }
      
      public function destroy() : void
      {
         if(Boolean(this._tween))
         {
            this._tween.pause();
            this._tween.removeEventListener(TweenEvent.COMPLETE,this.onComHandler);
            this._tween = null;
         }
         if(Boolean(this._obj))
         {
            this._obj.sprite.removeEventListener(Event.ENTER_FRAME,this.onEnterHandler);
            this._obj = null;
         }
         this._startPoint = null;
         this._endPoint = null;
         this._curvePoint = null;
         this._isPlaying = false;
         this._isFly = false;
         this._isNet = false;
      }
   }
}

