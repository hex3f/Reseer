package com.robot.core.skeleton
{
   import com.robot.core.info.item.ClothData;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.ISkeletonSprite;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   
   public class SkeletonClothPreview extends ClothPreview
   {
      
      public static var FLAG_CLOTH:String = "cloth";
      
      private var defaultCloth:MovieClip;
      
      public function SkeletonClothPreview(param1:MovieClip, param2:ISkeletonSprite = null)
      {
         super(param1,param2);
      }
      
      override protected function getFlagArray() : Array
      {
         return new Array(FLAG_TOP,FLAG_HEAD,FLAG_EYE,FLAG_HAND,FLAG_HAND_1,FLAG_WAIST,FLAG_DECORATOR,FLAG_FOOT,FLAG_BG,FLAG_CLOTH);
      }
      
      public function changeDefaultCloth() : void
      {
         this.defaultCloth = UIManager.getMovieClip("defaultCloth");
         var _loc1_:ChangeClothAction = changeClothActObj[FLAG_CLOTH];
         _loc1_.addChildCloth(this.defaultCloth,composeMC[FLAG_CLOTH]);
      }
      
      public function play() : void
      {
         var _loc1_:ChangeClothAction = null;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = colorMC.getChildAt(0) as MovieClip;
         if(Boolean(_loc4_))
         {
            _loc4_.gotoAndPlay(2);
         }
         if(doodleMC.numChildren > 0)
         {
            _loc2_ = doodleMC.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               _loc3_ = _loc2_.getChildAt(0) as MovieClip;
               if(Boolean(_loc3_))
               {
                  _loc3_.gotoAndPlay(2);
               }
            }
         }
         for each(_loc1_ in changeClothActObj)
         {
            _loc1_.goStart();
         }
      }
      
      public function stop() : void
      {
         var _loc1_:ChangeClothAction = null;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         if(colorMC.numChildren == 0)
         {
            return;
         }
         var _loc4_:MovieClip = colorMC.getChildAt(0) as MovieClip;
         if(Boolean(_loc4_))
         {
            _loc4_.gotoAndStop(1);
         }
         if(doodleMC.numChildren > 0)
         {
            _loc2_ = doodleMC.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               _loc3_ = _loc2_.getChildAt(0) as MovieClip;
               if(Boolean(_loc3_))
               {
                  _loc3_.gotoAndStop(1);
               }
            }
         }
         for each(_loc1_ in changeClothActObj)
         {
            _loc1_.goOver();
         }
      }
      
      public function onEnterFrame() : void
      {
         var _loc1_:ChangeClothAction = null;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = colorMC.getChildAt(0) as MovieClip;
         if(Boolean(_loc4_))
         {
            if(_loc4_.currentFrame == 1)
            {
               _loc4_.gotoAndPlay(2);
            }
         }
         if(doodleMC.numChildren > 0)
         {
            _loc2_ = doodleMC.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               _loc3_ = _loc2_.getChildAt(0) as MovieClip;
               if(Boolean(_loc3_))
               {
                  if(_loc3_.currentFrame == 1)
                  {
                     _loc3_.gotoAndPlay(2);
                  }
               }
            }
         }
         for each(_loc1_ in changeClothActObj)
         {
            _loc1_.goEnterFrame();
         }
      }
      
      override public function changeCloth(param1:Array) : void
      {
         super.changeCloth(param1);
         colorMC.gotoAndStop(people.direction);
         this.defaultCloth.gotoAndStop(people.direction);
      }
      
      public function changeDirection(param1:String) : void
      {
         var _loc2_:ChangeClothAction = null;
         var _loc3_:MovieClip = null;
         colorMC.gotoAndStop(param1);
         if(doodleMC.numChildren > 0)
         {
            _loc3_ = doodleMC.getChildAt(0) as MovieClip;
            if(Boolean(_loc3_))
            {
               _loc3_.gotoAndStop(param1);
            }
         }
         for each(_loc2_ in changeClothActObj)
         {
            _loc2_.changeDir(param1);
         }
      }
      
      public function specialAction(param1:BasePeoleModel, param2:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:ChangeClothAction = null;
         var _loc5_:ChangeClothAction = null;
         var _loc6_:ClothData = ClothInfo.getItemInfo(param2);
         var _loc7_:int = _loc6_.actionDir;
         if(_loc7_ != -1)
         {
            _loc3_ = _loc6_.type;
            people.direction = Direction.indexToStr(_loc7_);
            _loc4_ = changeClothActObj[_loc3_];
            _loc4_.specialAction(param1,param2,false);
         }
         else
         {
            colorMC.gotoAndStop(BasePeoleModel.SPECIAL_ACTION);
            for each(_loc5_ in changeClothActObj)
            {
               _loc5_.specialAction(param1,param2);
            }
         }
      }
   }
}

