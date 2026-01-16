package com.robot.app.toolBar.pkTool
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.teamPK.TeamPKManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.geom.Point;
   import org.taomee.effect.ColorFilter;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetFightMouseIcon extends BasePKMouseIcon implements IPKMouseIcon
   {
      
      private var bmp:Bitmap;
      
      public function PetFightMouseIcon()
      {
         super();
         ToolTipManager.add(this,"精灵对战");
      }
      
      override protected function getIcon() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(ShotBehaviorManager.getMovieClip("pk_icon_bg"));
         var _loc2_:SimpleButton = ShotBehaviorManager.getButton("pk_icon_fight");
         DisplayUtil.align(_loc2_,_loc1_.getRect(_loc1_),AlignType.MIDDLE_CENTER);
         _loc1_.addChild(_loc2_);
         return _loc1_;
      }
      
      override protected function getMouseIcon() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         var _loc2_:MovieClip = ShotBehaviorManager.getMovieClip("pk_mouseIcon_pet");
         this.bmp = DisplayUtil.copyDisplayAsBmp(_loc2_);
         _loc1_.graphics.beginFill(0,0);
         _loc1_.graphics.drawRect(this.bmp.x,this.bmp.y,this.bmp.width,this.bmp.height);
         _loc1_.addChild(this.bmp);
         return _loc1_;
      }
      
      override public function move(param1:Point) : void
      {
         var _loc2_:Point = MainManager.actorModel.localToGlobal(new Point());
         if(Point.distance(_loc2_,param1) > petDis)
         {
            outOfDistance = true;
            mouseIcon.filters = [ColorFilter.setGrayscale()];
         }
         else
         {
            outOfDistance = false;
            mouseIcon.filters = [];
         }
      }
      
      override public function click() : void
      {
         var _loc1_:BasePeoleModel = null;
         for each(_loc1_ in UserManager.getUserModelList())
         {
            if(_loc1_.hitTestPoint(MainManager.getStage().mouseX,MainManager.getStage().mouseY))
            {
               if(_loc1_.isShield)
               {
                  _loc1_.showShieldMovie();
                  break;
               }
               TeamPKManager.petFight(_loc1_.info.userID);
               break;
            }
         }
      }
      
      override public function show() : void
      {
         super.show();
         MainManager.actorModel.showShotRadius(petDis);
      }
   }
}

