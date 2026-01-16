package com.robot.core.aimat
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.ISprite;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import gs.TweenLite;
   import gs.TweenMax;
   import gs.easing.Quad;
   import org.taomee.utils.GeomUtil;
   
   public class ThrowController
   {
      
      private var array:Array;
      
      private var mc:MovieClip;
      
      public function ThrowController(param1:uint, param2:uint, param3:ISprite, param4:Point)
      {
         var _loc5_:int = 0;
         _loc5_ = 0;
         var _loc6_:int = 0;
         this.array = [65280,1046943,39167,16776960,6632191,16777215];
         super();
         this.mc = UIManager.getMovieClip("ui_Beacon");
         this.mc.gotoAndStop(1);
         var _loc7_:Point = param3.pos.clone();
         _loc7_.y -= 40;
         param3.direction = Direction.angleToStr(GeomUtil.pointAngle(_loc7_,param4));
         var _loc8_:BasePeoleModel = param3 as BasePeoleModel;
         if(_loc8_.direction == Direction.RIGHT_UP || _loc8_.direction == Direction.LEFT_UP)
         {
            _loc5_ = param4.y - Math.abs(param4.x - _loc7_.y) / 2;
         }
         else
         {
            _loc5_ = _loc7_.y - Math.abs(param4.x - _loc7_.y) / 2;
         }
         _loc6_ = _loc7_.x + (param4.x - _loc7_.x) / 2;
         this.mc.x = _loc7_.x;
         this.mc.y = _loc7_.y;
         LevelManager.mapLevel.addChild(this.mc);
         TweenMax.to(this.mc,1.5,{
            "bezier":[{
               "x":_loc6_,
               "y":_loc5_
            },{
               "x":param4.x,
               "y":param4.y
            }],
            "onComplete":this.onComp,
            "orientToBezier":true,
            "ease":Quad.easeOut
         });
      }
      
      private function onComp() : void
      {
         this.mc.rotation = 0;
         TweenLite.to(this.mc,2,{
            "scaleX":2,
            "scaleY":2
         });
         this.mc.gotoAndPlay(2);
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.color = this.array[Math.floor(Math.random() * this.array.length)];
         this.mc.transform.colorTransform = _loc1_;
      }
   }
}

