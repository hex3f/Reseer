package com.robot.core.controller
{
   import com.robot.core.event.MoveEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.MapModel;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class CameraController
   {
      
      private static var _mapModel:MapModel;
      
      private static var _body:BasePeoleModel;
      
      private static var _isUpDate:Boolean;
      
      private static var isRoomUp:Boolean;
      
      private static var isRoomDown:Boolean;
      
      private static var _closeScroll:Boolean;
      
      private static var _totalArea:Rectangle = new Rectangle();
      
      private static var _viewArea:Rectangle = new Rectangle(0,0,MainManager.getStageWidth(),MainManager.getStageHeight());
      
      private static var _farMultiple:Number = 0.3;
      
      private static var _nearMultiple:Number = 0.3;
      
      private static var _cameraMode:int = CameraMode.FACING;
      
      private static var _edgeRect:Rectangle = new Rectangle(250,260,250,192);
      
      private static var _viewCenterPoint:Point = new Point(_viewArea.width / 2,_viewArea.height / 2);
      
      public function CameraController()
      {
         super();
      }
      
      public static function setup(param1:MapModel, param2:BasePeoleModel, param3:Rectangle = null) : void
      {
         _viewArea = new Rectangle(0,0,MainManager.getStageWidth(),MainManager.getStageHeight());
         _mapModel = param1;
         if(Boolean(param3))
         {
            _totalArea = param3;
         }
         else
         {
            _totalArea = new Rectangle(0,0,MainManager.getStageWidth(),MainManager.getStageHeight());
         }
         _viewArea.x = _totalArea.x;
         _viewArea.y = _totalArea.y;
         _mapModel.root.scrollRect = _viewArea;
         _body = param2;
         if(_body == null)
         {
            return;
         }
         upDateForTotalAreaPoint(_body.pos);
         _body.addEventListener(MoveEvent.MOVE,onWalkEnter);
      }
      
      public static function clear() : void
      {
         if(Boolean(_body))
         {
            _body.removeEventListener(MoveEvent.MOVE,onWalkEnter);
            _body = null;
         }
         _mapModel = null;
      }
      
      public static function set totalArea(param1:Rectangle) : void
      {
         _totalArea = param1;
      }
      
      public static function get totalArea() : Rectangle
      {
         return _totalArea;
      }
      
      public static function set viewArea(param1:Rectangle) : void
      {
         _viewArea = param1;
         _viewCenterPoint.x = _viewArea.width / 2;
         _viewCenterPoint.y = _viewArea.height / 2;
      }
      
      public static function get viewArea() : Rectangle
      {
         return _viewArea;
      }
      
      public static function totalToView(param1:Point) : Point
      {
         return new Point(param1.x - _viewArea.x,param1.y - _viewArea.y);
      }
      
      public static function viewToTotal(param1:Point) : Point
      {
         return new Point(param1.x + _viewArea.x,param1.y + _viewArea.y);
      }
      
      public static function upDateForViewAreaPoint(param1:Point) : void
      {
         param1.x += _viewArea.x;
         param1.y += _viewArea.y;
         upDateForTotalAreaPoint(param1);
      }
      
      public static function upDateForTotalAreaPoint(param1:Point) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Boolean = _totalArea.containsPoint(param1);
         if(!_loc3_)
         {
            return;
         }
         _isUpDate = false;
         if(_cameraMode == CameraMode.FOLLOW)
         {
            _loc2_ = param1.subtract(_viewCenterPoint);
            if(_loc2_.x > _viewArea.x)
            {
               if(_viewArea.right < _totalArea.right)
               {
                  if(_loc2_.x > _totalArea.right - _viewArea.width)
                  {
                     _loc2_.x = _totalArea.right - _viewArea.width;
                  }
                  _viewArea.x = _loc2_.x;
                  _isUpDate = true;
               }
            }
            else if(_viewArea.x > _totalArea.x)
            {
               _viewArea.x = Math.max(_loc2_.x,_totalArea.x);
               _isUpDate = true;
            }
            if(_loc2_.y > _viewArea.y)
            {
               if(_viewArea.bottom < _totalArea.bottom)
               {
                  if(_loc2_.y > _totalArea.bottom - _viewArea.height)
                  {
                     _loc2_.y = _totalArea.bottom - _viewArea.height;
                  }
                  _viewArea.y = _loc2_.y;
                  _isUpDate = true;
               }
            }
            else if(_viewArea.y > _totalArea.y)
            {
               _viewArea.y = Math.max(_loc2_.y,_totalArea.y);
               _isUpDate = true;
            }
         }
         else if(_cameraMode == CameraMode.FACING)
         {
            if(param1.x > _viewArea.x + _edgeRect.x)
            {
               if(_viewArea.right < _totalArea.right)
               {
                  if(param1.x > _viewArea.right - _edgeRect.width)
                  {
                     _viewArea.x = param1.x - (_viewArea.width - _edgeRect.width);
                     if(_viewArea.right > _totalArea.right)
                     {
                        _viewArea.x = _totalArea.right - _viewArea.width;
                     }
                     _isUpDate = true;
                  }
               }
            }
            else if(_viewArea.x > _totalArea.x)
            {
               _viewArea.x = param1.x - _edgeRect.x;
               if(_viewArea.x < _totalArea.x)
               {
                  _viewArea.x = _totalArea.x;
               }
               _isUpDate = true;
            }
            if(param1.y > _viewArea.y + _edgeRect.y)
            {
               if(_viewArea.bottom < _totalArea.bottom)
               {
                  if(param1.y > _viewArea.bottom - _edgeRect.height)
                  {
                     _viewArea.y = param1.y - (_viewArea.height - _edgeRect.height);
                     if(_viewArea.bottom > _totalArea.bottom)
                     {
                        _viewArea.y = _totalArea.bottom - _viewArea.height;
                     }
                     _isUpDate = true;
                  }
               }
            }
            else if(_viewArea.y > _totalArea.y)
            {
               _viewArea.y = param1.y - _edgeRect.y;
               if(_viewArea.y < _totalArea.y)
               {
                  _viewArea.y = _totalArea.y;
               }
               _isUpDate = true;
            }
         }
         if(_isUpDate)
         {
            _mapModel.root.scrollRect = _viewArea;
         }
      }
      
      public static function get shiftX() : Number
      {
         return _viewArea.x;
      }
      
      public static function get shiftY() : Number
      {
         return _viewArea.y;
      }
      
      private static function onWalkEnter(param1:MoveEvent) : void
      {
         if(!_closeScroll)
         {
            upDateForTotalAreaPoint(param1.pos);
         }
      }
      
      public static function set closeScroll(param1:Boolean) : void
      {
         _closeScroll = param1;
      }
   }
}

