package com.robot.core.manager
{
   import com.robot.core.manager.bean.BaseBeanController;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   import org.taomee.component.containers.VBox;
   import org.taomee.component.control.UIMovieClip;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class LeftToolBarManager extends BaseBeanController
   {
      
      private static var box:VBox;
      
      private static var map:HashMap;
      
      private static var mc:MovieClip;
      
      private var btn:MovieClip;
      
      private var isShow:Boolean = false;
      
      public function LeftToolBarManager()
      {
         super();
      }
      
      public static function addIcon(param1:DisplayObject) : void
      {
         var _loc2_:UIMovieClip = new UIMovieClip(param1);
         map.add(param1,_loc2_);
         box.append(_loc2_);
         checkLengh();
      }
      
      public static function delIcon(param1:DisplayObject) : void
      {
         var _loc2_:UIMovieClip = map.getValue(param1) as UIMovieClip;
         map.remove(param1);
         if(Boolean(_loc2_))
         {
            box.remove(_loc2_);
         }
         checkLengh();
      }
      
      private static function checkLengh() : void
      {
         if(map.length > 0)
         {
            LevelManager.toolsLevel.addChild(mc);
         }
         else
         {
            DisplayUtil.removeForParent(mc);
         }
      }
      
      override public function start() : void
      {
         map = new HashMap();
         mc = AssetsManager.getMovieClip("lib_left_toolBar");
         DisplayUtil.align(mc,null,AlignType.MIDDLE_LEFT);
         mc.x = -56;
         this.btn = mc["btn"];
         this.btn.buttonMode = true;
         this.btn.gotoAndStop(1);
         this.btn.addEventListener(MouseEvent.CLICK,this.clickHandler);
         box = new VBox();
         box.mouseEnabled = false;
         box.isMask = false;
         box.setSizeWH(50,256);
         DisplayUtil.align(box,mc.getRect(mc),AlignType.MIDDLE_CENTER);
         box.x = 0;
         box.halign = FlowLayout.CENTER;
         box.valign = FlowLayout.MIDLLE;
         mc.addChild(box);
         checkLengh();
         finish();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.isShow = !this.isShow;
         if(this.isShow)
         {
            this.btn.gotoAndStop(2);
            TweenLite.to(mc,0.3,{"x":0});
         }
         else
         {
            this.btn.gotoAndStop(1);
            TweenLite.to(mc,0.3,{"x":-56});
         }
      }
   }
}

