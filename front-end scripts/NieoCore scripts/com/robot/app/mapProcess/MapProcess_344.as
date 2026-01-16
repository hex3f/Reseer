package com.robot.app.mapProcess
{
   import com.robot.core.CommandID;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_344 extends BaseMapProcess
   {
      
      private var mc_1:MovieClip;
      
      private var item_500640:SimpleButton;
      
      private var mc_2:MovieClip;
      
      private var mc_3:MovieClip;
      
      private var item_500641:SimpleButton;
      
      public function MapProcess_344()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.mc_1 = conLevel["mc_1"];
         this.mc_2 = conLevel["mc_2"];
         this.mc_3 = conLevel["mc_3"];
         this.item_500641 = conLevel["item_500641"];
         this.addEvent();
         topLevel.mouseChildren = false;
         topLevel.mouseEnabled = false;
      }
      
      public function addEvent() : void
      {
         this.mc_1.addEventListener(MouseEvent.CLICK,this.onClick_mc_1);
         this.mc_2["btn"].addEventListener(MouseEvent.CLICK,this.onClick_mc_2);
         this.item_500641.addEventListener(MouseEvent.CLICK,this.onClick_item_500641);
      }
      
      public function removeEvent() : void
      {
         this.mc_1.removeEventListener(MouseEvent.CLICK,this.onClick_mc_1);
         this.mc_2["btn"].removeEventListener(MouseEvent.CLICK,this.onClick_mc_2);
      }
      
      private function onClick_mc_1(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.mc_1.removeEventListener(MouseEvent.CLICK,this.onClick_mc_1);
         AnimateManager.playMcAnimate(this.mc_1,2,"mc_1_1",function():void
         {
            item_500640 = mc_1["mc_1_1"]["item_500640"];
            item_500640.addEventListener(MouseEvent.CLICK,onClick_item_500640);
         });
      }
      
      private function onClick_item_500640(param1:MouseEvent) : void
      {
         this.item_500640.removeEventListener(MouseEvent.CLICK,this.onClick_item_500640);
         DisplayUtil.removeForParent(this.item_500640);
         SocketConnection.send(CommandID.BUY_FITMENT,500640,1);
      }
      
      private function onClick_mc_2(param1:MouseEvent) : void
      {
         if(this.mc_3.currentFrame == 1 || this.mc_3.currentFrame == 3)
         {
            this.mc_3.gotoAndStop(2);
         }
         else
         {
            this.mc_3.gotoAndStop(3);
         }
      }
      
      private function onClick_item_500641(param1:MouseEvent) : void
      {
         this.item_500641.removeEventListener(MouseEvent.CLICK,this.onClick_item_500641);
         DisplayUtil.removeForParent(this.item_500641);
         SocketConnection.send(CommandID.BUY_FITMENT,500641,1);
      }
      
      override public function destroy() : void
      {
         this.removeEvent();
         if(Boolean(this.item_500640))
         {
            this.item_500640.removeEventListener(MouseEvent.CLICK,this.onClick_item_500640);
         }
         if(Boolean(this.item_500641))
         {
            this.item_500641.removeEventListener(MouseEvent.CLICK,this.onClick_item_500641);
         }
         this.mc_1 = null;
         this.item_500640 = null;
         this.mc_2 = null;
         this.mc_3 = null;
         this.item_500641 = null;
      }
   }
}

