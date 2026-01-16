package com.robot.app.task.spacedoor
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class SpaceTaskGame extends Sprite
   {
      
      private const url_str:String = "resource/Games/BallTaskGame.swf";
      
      private var uiLoader:MCLoader;
      
      private var mainUI_mc:Sprite;
      
      private var closeBtn:SimpleButton;
      
      private var panelMc:MovieClip;
      
      private var panelEffect:MovieClip;
      
      private var app:ApplicationDomain;
      
      private var startX:Number;
      
      private var startY:Number;
      
      private var counter:Number = 0;
      
      private var grass_mc:MovieClip;
      
      private var fire_mc:MovieClip;
      
      private var w_mc:MovieClip;
      
      private var stone_mc:MovieClip;
      
      private var land_mc:MovieClip;
      
      public function SpaceTaskGame()
      {
         super();
         LevelManager.topLevel.addChild(this);
         this.loadAssets(this.url_str);
      }
      
      private function loadAssets(param1:String) : void
      {
         this.uiLoader = new MCLoader(param1,LevelManager.appLevel,1,"正在打开任务");
         this.uiLoader.addEventListener(MCLoadEvent.SUCCESS,this.onLoadUISuccessHandler);
         this.uiLoader.doLoad();
      }
      
      private function onLoadUISuccessHandler(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this.mainUI_mc = new (this.app.getDefinition("MainUI_MC") as Class)() as Sprite;
         this.addChild(this.mainUI_mc);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         this.panelMc = this.mainUI_mc["panel_mc"];
         this.panelMc.gotoAndStop(1);
         this.closeBtn = this.mainUI_mc["close_btn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.grass_mc = this.mainUI_mc["grass_mc"];
         this.fire_mc = this.mainUI_mc["fire_mc"];
         this.w_mc = this.mainUI_mc["w_mc"];
         this.stone_mc = this.mainUI_mc["stone_mc"];
         this.land_mc = this.mainUI_mc["land_mc"];
         ToolTipManager.add(this.grass_mc,"草");
         this.grass_mc.buttonMode = true;
         ToolTipManager.add(this.fire_mc,"火");
         this.fire_mc.buttonMode = true;
         ToolTipManager.add(this.w_mc,"水");
         this.w_mc.buttonMode = true;
         ToolTipManager.add(this.stone_mc,"电");
         this.stone_mc.buttonMode = true;
         ToolTipManager.add(this.land_mc,"地");
         this.land_mc.buttonMode = true;
         this.grass_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.grass_mc.addEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.fire_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.fire_mc.addEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.w_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.w_mc.addEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.stone_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.stone_mc.addEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.land_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.land_mc.addEventListener(MouseEvent.MOUSE_UP,this.dropIt);
      }
      
      private function pickUp(param1:MouseEvent) : void
      {
         param1.target.startDrag();
         param1.target.parent.addChild(param1.target);
         this.startX = param1.target.x;
         this.startY = param1.target.y;
      }
      
      private function dropIt(param1:MouseEvent) : void
      {
         param1.target.stopDrag();
         var _loc2_:String = "target" + param1.target.name;
         var _loc3_:DisplayObject = this.mainUI_mc[_loc2_];
         if(param1.target.dropTarget != null && param1.target.dropTarget.parent == _loc3_)
         {
            param1.target.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
            param1.target.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
            param1.target.buttonMode = false;
            param1.target.x = _loc3_.x;
            param1.target.y = _loc3_.y;
            ++this.counter;
         }
         else
         {
            param1.target.x = this.startX;
            param1.target.y = this.startY;
            this.onDropErrorHandler();
         }
         if(this.counter == 5)
         {
            this.onFinishedHander();
         }
      }
      
      private function onCloseBtnClickHandler(param1:MouseEvent) : void
      {
         this.destroy();
      }
      
      private function destroy() : void
      {
         if(Boolean(this.panelEffect))
         {
            this.panelEffect.removeEventListener(Event.ENTER_FRAME,this.onEffectFrameHandler);
         }
         DisplayUtil.removeForParent(this.mainUI_mc);
         DisplayUtil.removeForParent(this);
         this.closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.closeBtn = null;
         this.mainUI_mc = null;
         this.uiLoader.clear();
         this.uiLoader = null;
         this.grass_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.grass_mc.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.fire_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.fire_mc.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.w_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.w_mc.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.stone_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.stone_mc.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
         this.land_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.pickUp);
         this.land_mc.removeEventListener(MouseEvent.MOUSE_UP,this.dropIt);
      }
      
      private function onDropErrorHandler() : void
      {
         Alarm.show("你放置的位置不属于这颗属性球，记得对照<font color=\'#ff0000\'>属性相克表</font>来排列哦！");
      }
      
      private function onFinishedHander() : void
      {
         this.panelMc.gotoAndStop(2);
         this.panelEffect = this.panelMc["panel_effect"];
         this.panelEffect.addEventListener(Event.ENTER_FRAME,this.onEffectFrameHandler);
      }
      
      private function onEffectFrameHandler(param1:Event) : void
      {
         var e:Event = param1;
         if(this.panelEffect.currentFrame == this.panelEffect.totalFrames)
         {
            this.panelEffect.removeEventListener(Event.ENTER_FRAME,this.onEffectFrameHandler);
            this.destroy();
            Alarm.show("我果然没有看错，你真行啊！时空之门已经开启，通过时空之门我们就可以穿梭到千年前的赫尔卡星，那里曾经遭遇了异常可怕的浩劫……",function():void
            {
            });
         }
      }
   }
}

