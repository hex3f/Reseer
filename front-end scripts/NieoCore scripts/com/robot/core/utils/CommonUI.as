package com.robot.core.utils
{
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   import org.taomee.effect.ColorFilter;
   
   public class CommonUI
   {
      
      public function CommonUI()
      {
         super();
      }
      
      public static function equalScale(param1:DisplayObject, param2:uint, param3:uint) : void
      {
         if(param1.width / param2 > param1.height / param3)
         {
            param1.scaleX = param1.scaleY = param2 / param1.width;
         }
         else
         {
            param1.scaleX = param1.scaleY = param3 / param1.height;
         }
      }
      
      public static function centerAlign(param1:DisplayObject, param2:Sprite, param3:Point) : void
      {
         var _loc4_:Number = NaN;
         _loc4_ = NaN;
         var _loc5_:Rectangle = param1.getBounds(param2);
         var _loc6_:Number = _loc5_.x - param1.x + param1.width / 2;
         _loc4_ = _loc5_.y - param1.y + param1.height / 2;
         param1.x = param3.x - _loc6_;
         param1.y = param3.y - _loc4_;
      }
      
      public static function getCenterPos(param1:DisplayObject, param2:Sprite) : Point
      {
         var _loc3_:Rectangle = param1.getBounds(param2);
         var _loc4_:Point = new Point();
         _loc4_.x = _loc3_.x + param1.width / 2;
         _loc4_.y = _loc3_.y + param1.height / 2;
         return _loc4_;
      }
      
      public static function setEnabled(param1:InteractiveObject, param2:Boolean, param3:Boolean = true) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Number = 0;
         var _loc6_:BitmapFilter = null;
         var _loc7_:Sprite = param1 as Sprite;
         if(Boolean(_loc7_))
         {
            _loc7_.mouseEnabled = param2;
            _loc7_.mouseChildren = param2;
         }
         var _loc8_:SimpleButton = param1 as SimpleButton;
         if(Boolean(_loc8_))
         {
            _loc8_.enabled = param2;
            _loc8_.mouseEnabled = param2;
         }
         if(param3)
         {
            _loc4_ = param1.filters;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc5_];
               if(_loc6_ is ColorMatrixFilter)
               {
                  _loc4_.splice(_loc5_,1);
               }
               _loc5_++;
            }
            if(param2 == false)
            {
               _loc4_.push(ColorFilter.setGrayscale());
            }
            param1.filters = _loc4_;
         }
      }
      
      public static function addYellowExcal(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = -80, param4:Number = 1) : void
      {
         var _loc5_:MovieClip = null;
         _loc5_ = UIManager.getMovieClip("lib_excalmatory_mark");
         _loc5_.x = param2;
         _loc5_.y = param3;
         _loc5_.scaleX = _loc5_.scaleY = param4;
         param1.addChild(_loc5_);
      }
      
      public static function removeYellowExcal(param1:DisplayObjectContainer) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(Boolean(param1))
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = getQualifiedClassName(param1.getChildAt(_loc2_));
               _loc4_ = _loc3_.split(".");
               _loc5_ = _loc4_[_loc4_.length - 1];
               if(_loc5_ == "lib_excalmatory_mark")
               {
                  param1.removeChild(param1.getChildAt(_loc2_));
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function addYellowQuestion(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = -80) : void
      {
         var _loc4_:MovieClip = null;
         _loc4_ = UIManager.getMovieClip("lib_question_mark");
         _loc4_.x = param2;
         _loc4_.y = param3;
         param1.addChild(_loc4_);
      }
      
      public static function removeYellowQuestion(param1:DisplayObjectContainer) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(Boolean(param1))
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = getQualifiedClassName(param1.getChildAt(_loc2_));
               _loc4_ = _loc3_.split(".");
               _loc5_ = _loc4_[_loc4_.length - 1];
               if(_loc5_ == "lib_question_mark")
               {
                  param1.removeChild(param1.getChildAt(_loc2_));
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function addYellowArrow(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = 0, param4:uint = 0) : void
      {
         var _loc5_:MovieClip = null;
         _loc5_ = UIManager.getMovieClip("Arrows_UI");
         _loc5_.x = param2;
         _loc5_.y = param3;
         _loc5_.rotation = param4;
         param1.addChild(_loc5_);
      }
      
      public static function removeYellowArrow(param1:DisplayObjectContainer) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(Boolean(param1))
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = getQualifiedClassName(param1.getChildAt(_loc2_));
               _loc4_ = _loc3_.split(".");
               _loc5_ = _loc4_[_loc4_.length - 1];
               if(_loc5_ == "Arrows_UI")
               {
                  param1.removeChild(param1.getChildAt(_loc2_));
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function showProgressBar(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = 0, param4:Function = null, param5:String = "正在采集") : void
      {
         var progressBar:MovieClip = null;
         var container:DisplayObjectContainer = null;
         var fun:Function = null;
         progressBar = null;
         container = param1;
         var offX:Number = param2;
         var offY:Number = param3;
         fun = param4;
         var txt:String = param5;
         progressBar = UIManager.getMovieClip("lib_progress_Bar");
         progressBar.x = offX;
         progressBar.y = offY;
         progressBar["txt"].text = txt;
         container.addChild(progressBar);
         AnimateManager.playMcAnimate(progressBar,0,"",function():void
         {
            container.removeChild(progressBar);
            if(fun != null)
            {
               fun();
            }
         });
      }
   }
}

