package com.robot.core.aimat
{
   import com.robot.core.event.AimatEvent;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.ISprite;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import gs.TweenMax;
   import gs.easing.Quad;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class ThrowPropsController
   {
      
      private var mc:MovieClip;
      
      private var _isFullScreen:Boolean = false;
      
      private var _itemID:uint;
      
      private var _userID:uint;
      
      private var _startPoint:Point;
      
      private var _endPoint:Point;
      
      public function ThrowPropsController(param1:uint, param2:uint, param3:ISprite, param4:Point)
      {
         var _loc5_:Point = null;
         _loc5_ = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         super();
         if(param1 == 600002)
         {
            this._isFullScreen = true;
         }
         this._itemID = param1;
         this._userID = param2;
         this._endPoint = param4;
         this.mc = TaskIconManager.getIcon("item_" + param1.toString()) as MovieClip;
         this.mc.gotoAndStop(1);
         _loc5_ = param3.pos.clone();
         this._startPoint = _loc5_;
         _loc5_.y -= 40;
         param3.direction = Direction.angleToStr(GeomUtil.pointAngle(_loc5_,param4));
         var _loc8_:BasePeoleModel = param3 as BasePeoleModel;
         if(_loc8_.direction == Direction.RIGHT_UP || _loc8_.direction == Direction.LEFT_UP)
         {
            _loc6_ = param4.y - Math.abs(param4.x - _loc5_.y) / 2;
         }
         else
         {
            _loc6_ = _loc5_.y - Math.abs(param4.x - _loc5_.y) / 2;
         }
         _loc7_ = _loc5_.x + (param4.x - _loc5_.x) / 2;
         this.mc.x = _loc5_.x;
         this.mc.y = _loc5_.y;
         LevelManager.mapLevel.addChild(this.mc);
         var _loc9_:AimatInfo = new AimatInfo(param1,param2,_loc5_,param4);
         AimatController.dispatchEvent(AimatEvent.PLAY_START,_loc9_);
         TweenMax.to(this.mc,1,{
            "bezier":[{
               "x":_loc7_,
               "y":_loc6_
            },{
               "x":param4.x,
               "y":param4.y
            }],
            "onComplete":this.onThrowComp,
            "orientToBezier":true,
            "ease":Quad.easeIn
         });
      }
      
      private function onThrowComp() : void
      {
         var url:String = null;
         var mcloader:MCLoader = null;
         mcloader = null;
         var info:AimatInfo = new AimatInfo(this._itemID,this._userID,this._startPoint,this._endPoint);
         AimatController.dispatchEvent(AimatEvent.PLAY_END,info);
         this.mc.gotoAndPlay(2);
         url = "resource/item/throw/animate/" + this._itemID + ".swf";
         mcloader = new MCLoader(url,LevelManager.mapLevel,-1);
         mcloader.addEventListener(MCLoadEvent.SUCCESS,this.onLoaded);
         setTimeout(function():void
         {
            if(Boolean(mc))
            {
               DisplayUtil.removeForParent(mc);
               mc = null;
            }
            mcloader.doLoad();
         },1000);
      }
      
      private function onLoaded(param1:MCLoadEvent) : void
      {
         var app:ApplicationDomain = null;
         var cls:* = undefined;
         var r:uint = 0;
         var throwMC:MovieClip = null;
         var evt:MCLoadEvent = param1;
         throwMC = null;
         (evt.currentTarget as MCLoader).removeEventListener(MCLoadEvent.SUCCESS,this.onLoaded);
         app = evt.getApplicationDomain();
         cls = app.getDefinition("ThrowPropMC");
         throwMC = new cls() as MovieClip;
         r = Math.floor(Math.random() * throwMC.totalFrames) + 1;
         throwMC.gotoAndStop(r);
         if(this._isFullScreen)
         {
            throwMC.x = MainManager.getStage().width / 2;
            throwMC.y = MainManager.getStage().height / 2;
         }
         else
         {
            throwMC.x = this._endPoint.x;
            throwMC.y = this._endPoint.y;
         }
         LevelManager.mapLevel.addChild(throwMC);
         setTimeout(function():void
         {
            if(Boolean(throwMC))
            {
               DisplayUtil.removeForParent(throwMC);
               throwMC = null;
            }
         },10000);
      }
   }
}

