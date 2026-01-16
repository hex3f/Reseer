package com.robot.core.pet
{
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class PetGenderIconManager
   {
      
      public function PetGenderIconManager()
      {
         super();
      }
      
      public static function addIcon(param1:DisplayObjectContainer, param2:Point, param3:uint) : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = UIManager.getMovieClip("PetGenderIcon");
         if(Boolean(param1))
         {
            _loc4_ = param1.getChildByName("PetGenderIcon") as MovieClip;
            if(Boolean(_loc4_))
            {
               param1.removeChild(_loc4_);
            }
            param1.addChild(_loc5_);
            _loc5_.x = param2.x;
            _loc5_.y = param2.y;
            _loc5_.gotoAndStop(param3 + 1);
            _loc5_.name = "PetGenderIcon";
         }
      }
      
      public static function hideIcon(param1:DisplayObjectContainer) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(param1))
         {
            _loc2_ = param1.getChildByName("PetGenderIcon") as MovieClip;
            if(Boolean(_loc2_))
            {
               param1.removeChild(_loc2_);
            }
         }
      }
   }
}

