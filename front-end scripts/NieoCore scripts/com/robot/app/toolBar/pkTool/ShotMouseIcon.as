package com.robot.app.toolBar.pkTool
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.config.xml.ShotDisXMLInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.geom.Point;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class ShotMouseIcon extends BasePKMouseIcon implements IPKMouseIcon
   {
      
      private var bmp:Bitmap;
      
      public function ShotMouseIcon()
      {
         super();
         ToolTipManager.add(this,"射击");
      }
      
      override protected function getIcon() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(ShotBehaviorManager.getMovieClip("pk_icon_bg"));
         var _loc2_:SimpleButton = ShotBehaviorManager.getButton("pk_icon_shot");
         DisplayUtil.align(_loc2_,_loc1_.getRect(_loc1_),AlignType.MIDDLE_CENTER);
         _loc1_.addChild(_loc2_);
         return _loc1_;
      }
      
      override protected function getMouseIcon() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         var _loc2_:MovieClip = ShotBehaviorManager.getMovieClip("pk_mouseIcon_shot");
         this.bmp = DisplayUtil.copyDisplayAsBmp(_loc2_);
         _loc1_.graphics.beginFill(0,0);
         _loc1_.graphics.drawRect(this.bmp.x,this.bmp.y,this.bmp.width,this.bmp.height);
         _loc1_.addChild(this.bmp);
         return _loc1_;
      }
      
      override public function move(param1:Point) : void
      {
         var _loc2_:Point = MainManager.actorModel.localToGlobal(new Point());
         if(Point.distance(_loc2_,param1) > shotDis)
         {
            outOfDistance = true;
            this.bmp.visible = false;
            mouseIcon.addChild(forbidIcon);
         }
         else
         {
            outOfDistance = false;
            this.bmp.visible = true;
            DisplayUtil.removeForParent(forbidIcon);
         }
      }
      
      override public function click() : void
      {
         AimatController.setClothType(MainManager.actorInfo.clothIDs);
         MainManager.actorModel.aimatAction(0,AimatController.type,new Point(LevelManager.mapLevel.mouseX,LevelManager.mapLevel.mouseY));
      }
      
      override public function show() : void
      {
         super.show();
         var _loc1_:uint = uint(ShotDisXMLInfo.getClothDistance(MainManager.actorInfo.clothIDs));
         MainManager.actorModel.showShotRadius(_loc1_);
      }
   }
}

