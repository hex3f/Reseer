package com.robot.core.manager.map
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.MapModel;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import gs.TweenMax;
   import gs.easing.Sine;
   import gs.events.TweenEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class MapTransEffect extends EventDispatcher
   {
      
      public static const NONE:int = 0;
      
      public static const TOP:int = 1;
      
      public static const LEFT:int = 2;
      
      public static const DOWN:int = 3;
      
      public static const RIGHT:int = 4;
      
      private var _mapModel:MapModel;
      
      private var _dir:int = 0;
      
      private var _sprite:Sprite;
      
      public function MapTransEffect(param1:MapModel, param2:int)
      {
         super();
         this._mapModel = param1;
         this._dir = param2;
      }
      
      public function star() : void
      {
         var _loc1_:Point = null;
         _loc1_ = null;
         var _loc2_:BitmapData = null;
         var _loc3_:Bitmap = null;
         var _loc4_:BitmapData = null;
         var _loc5_:Bitmap = null;
         if(this._dir == 0)
         {
            dispatchEvent(new MapEvent(MapEvent.MAP_EFFECT_COMPLETE));
         }
         else
         {
            _loc1_ = this.getNewMapXY();
            this._sprite = new Sprite();
            _loc2_ = new BitmapData(MainManager.getStageWidth(),MainManager.getStageHeight());
            _loc3_ = new Bitmap(_loc2_);
            _loc2_.draw(LevelManager.mapLevel.getChildAt(0));
            this._sprite.addChild(_loc3_);
            _loc4_ = new BitmapData(MainManager.getStageWidth(),MainManager.getStageHeight());
            _loc5_ = new Bitmap(_loc4_);
            _loc5_.x = _loc1_.x;
            _loc5_.y = _loc1_.y;
            _loc4_.draw(this._mapModel.root);
            this._sprite.addChild(_loc5_);
            DisplayUtil.removeAllChild(LevelManager.mapLevel);
            LevelManager.mapLevel.addChild(this._sprite);
            this.moveMap(this._sprite,_loc1_);
         }
      }
      
      private function moveMap(param1:DisplayObject, param2:Point) : void
      {
         var myTween:TweenMax = null;
         var sprite:DisplayObject = param1;
         var p:Point = param2;
         var finishx:Number = NaN;
         var finishy:Number = NaN;
         myTween = null;
         if(p.x == 0)
         {
            finishx = 0;
            finishy = -p.y;
         }
         else if(p.y == 0)
         {
            finishx = -p.x;
            finishy = 0;
         }
         myTween = new TweenMax(sprite,1,{
            "x":finishx,
            "y":finishy,
            "ease":Sine.easeOut
         });
         myTween.addEventListener(TweenEvent.COMPLETE,function(param1:TweenEvent):void
         {
            myTween.removeEventListener(TweenEvent.COMPLETE,arguments.callee);
            _mapModel.root.addEventListener(Event.ADDED_TO_STAGE,onAddHandler);
            dispatchEvent(new MapEvent(MapEvent.MAP_EFFECT_COMPLETE));
         });
      }
      
      private function onAddHandler(param1:Event) : void
      {
         this._mapModel.root.removeEventListener(Event.ADDED_TO_STAGE,this.onAddHandler);
         DisplayUtil.removeForParent(this._sprite);
         this._sprite = null;
         this._mapModel = null;
      }
      
      private function getNewMapXY() : Point
      {
         var _loc1_:Point = null;
         switch(this._dir)
         {
            case TOP:
               _loc1_ = new Point(0,-MainManager.getStageHeight());
               break;
            case LEFT:
               _loc1_ = new Point(-MainManager.getStageWidth(),0);
               break;
            case DOWN:
               _loc1_ = new Point(0,MainManager.getStageHeight());
               break;
            case RIGHT:
               _loc1_ = new Point(MainManager.getStageWidth(),0);
               break;
            default:
               _loc1_ = new Point(0,-MainManager.getStageHeight());
         }
         return _loc1_;
      }
   }
}

