package org.taomee.utils
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.taomee.manager.TaomeeManager;
   
   public class DisplayUtil
   {
      
      private static const MOUSE_EVENT_LIST:Array = [MouseEvent.CLICK,MouseEvent.DOUBLE_CLICK,MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_OUT,MouseEvent.MOUSE_OVER,MouseEvent.MOUSE_UP,MouseEvent.MOUSE_WHEEL,MouseEvent.ROLL_OUT,MouseEvent.ROLL_OVER];
      
      public function DisplayUtil()
      {
         super();
      }
      
      public static function FillColor(param1:DisplayObject, param2:uint) : void
      {
         var _loc3_:ColorTransform = new ColorTransform();
         _loc3_.color = param2;
         param1.transform.colorTransform = _loc3_;
      }
      
      public static function stopAllMovieClip(param1:DisplayObjectContainer) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         var _loc3_:MovieClip = param1 as MovieClip;
         if(_loc3_ != null)
         {
            _loc3_.stop();
            _loc3_ = null;
         }
         var _loc4_:int = param1.numChildren - 1;
         if(_loc4_ < 0)
         {
            return;
         }
         var _loc5_:int = _loc4_;
         while(_loc5_ >= 0)
         {
            _loc2_ = param1.getChildAt(_loc5_) as DisplayObjectContainer;
            if(_loc2_ != null)
            {
               stopAllMovieClip(_loc2_);
            }
            _loc5_--;
         }
      }
      
      public static function hasParent(param1:DisplayObject) : Boolean
      {
         if(param1.parent == null)
         {
            return false;
         }
         return param1.parent.contains(param1);
      }
      
      public static function localToLocal(param1:DisplayObject, param2:DisplayObject, param3:Point = null) : Point
      {
         if(param3 == null)
         {
            param3 = new Point(0,0);
         }
         param3 = param1.localToGlobal(param3);
         return param2.globalToLocal(param3);
      }
      
      public static function copyDisplayAsBmp(param1:DisplayObject) : Bitmap
      {
         var _loc2_:BitmapData = new BitmapData(param1.width,param1.height,true,0);
         var _loc3_:Rectangle = param1.getRect(param1);
         var _loc4_:Matrix = new Matrix();
         _loc4_.translate(-_loc3_.x,-_loc3_.y);
         _loc2_.draw(param1,_loc4_);
         var _loc5_:Bitmap = new Bitmap(_loc2_,PixelSnapping.AUTO,true);
         _loc5_.x = _loc3_.x;
         _loc5_.y = _loc3_.y;
         return _loc5_;
      }
      
      public static function align(param1:DisplayObject, param2:Rectangle = null, param3:int = 0, param4:Point = null) : void
      {
         if(param2 == null)
         {
            param2 = new Rectangle(0,0,TaomeeManager.stageWidth,TaomeeManager.stageHeight);
         }
         if(Boolean(param4))
         {
            param2.offsetPoint(param4);
         }
         var _loc5_:Rectangle = param1.getRect(param1);
         var _loc6_:Number = param2.width - param1.width;
         var _loc7_:Number = param2.height - param1.height;
         switch(param3)
         {
            case AlignType.TOP_LEFT:
               param1.x = param2.x;
               param1.y = param2.y;
               break;
            case AlignType.TOP_CENTER:
               param1.x = param2.x + _loc6_ / 2 - _loc5_.x;
               param1.y = param2.y;
               break;
            case AlignType.TOP_RIGHT:
               param1.x = param2.x + _loc6_ - _loc5_.x;
               param1.y = param2.y;
               break;
            case AlignType.MIDDLE_LEFT:
               param1.x = param2.x;
               param1.y = param2.y + _loc7_ / 2 - _loc5_.x;
               break;
            case AlignType.MIDDLE_CENTER:
               param1.x = param2.x + _loc6_ / 2 - _loc5_.x;
               param1.y = param2.y + _loc7_ / 2 - _loc5_.y;
               break;
            case AlignType.MIDDLE_RIGHT:
               param1.x = param2.x + _loc6_ - _loc5_.x;
               param1.y = param2.y + _loc7_ / 2 - _loc5_.y;
               break;
            case AlignType.BOTTOM_LEFT:
               param1.x = param2.x;
               param1.y = param2.y + _loc7_ - _loc5_.y;
               break;
            case AlignType.BOTTOM_CENTER:
               param1.x = param2.x + _loc6_ / 2 - _loc5_.x;
               param1.y = param2.y + _loc7_ - _loc5_.y;
               break;
            case AlignType.BOTTOM_RIGHT:
               param1.x = param2.x + _loc6_ - _loc5_.x;
               param1.y = param2.y + _loc7_ - _loc5_.y;
         }
      }
      
      public static function getColor(param1:DisplayObject, param2:uint = 0, param3:uint = 0, param4:Boolean = false) : uint
      {
         var _loc5_:BitmapData = new BitmapData(param1.width,param1.height);
         _loc5_.draw(param1);
         var _loc6_:uint = !param4 ? _loc5_.getPixel(int(param2),int(param3)) : _loc5_.getPixel32(int(param2),int(param3));
         _loc5_.dispose();
         return _loc6_;
      }
      
      public static function removeForParent(param1:DisplayObject, param2:Boolean = true) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.parent == null)
         {
            return;
         }
         if(!param1.parent.contains(param1))
         {
            return;
         }
         if(param2)
         {
            _loc3_ = param1 as DisplayObjectContainer;
            if(Boolean(_loc3_))
            {
               stopAllMovieClip(_loc3_);
               _loc3_ = null;
            }
         }
         param1.parent.removeChild(param1);
      }
      
      public static function mouseEnabledAll(param1:InteractiveObject) : void
      {
         var container:DisplayObjectContainer = null;
         var target:InteractiveObject = param1;
         var i:int = 0;
         var child:InteractiveObject = null;
         var b:Boolean = Boolean(MOUSE_EVENT_LIST.some(function(param1:String, param2:int, param3:Array):Boolean
         {
            if(target.hasEventListener(param1))
            {
               return true;
            }
            return false;
         }));
         if(!b)
         {
            target.mouseEnabled = false;
         }
         container = target as DisplayObjectContainer;
         if(Boolean(container))
         {
            i = container.numChildren - 1;
            while(i >= 0)
            {
               child = container.getChildAt(i) as InteractiveObject;
               if(Boolean(child))
               {
                  mouseEnabledAll(child);
               }
               i--;
            }
         }
      }
      
      public static function uniformScale(param1:DisplayObject, param2:Number) : void
      {
         if(param1.width >= param1.height)
         {
            param1.width = param2;
            param1.scaleY = param1.scaleX;
         }
         else
         {
            param1.height = param2;
            param1.scaleX = param1.scaleY;
         }
      }
      
      public static function removeAllChild(param1:DisplayObjectContainer) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         while(param1.numChildren > 0)
         {
            _loc2_ = param1.removeChildAt(0) as DisplayObjectContainer;
            if(_loc2_ != null)
            {
               stopAllMovieClip(_loc2_);
               _loc2_ = null;
            }
         }
      }
   }
}

