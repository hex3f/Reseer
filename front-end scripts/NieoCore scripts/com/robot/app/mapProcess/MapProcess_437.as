package com.robot.app.mapProcess
{
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.DragManager;
   import org.taomee.manager.ToolTipManager;
   
   public class MapProcess_437 extends BaseMapProcess
   {
      
      private var task573Btn1:MovieClip;
      
      private var task573Btn2:MovieClip;
      
      private var task573Btn3:MovieClip;
      
      private var mouseMov:MovieClip;
      
      private var mouseDoor:MovieClip;
      
      private var doorTips:MovieClip;
      
      private var map443Door:MovieClip;
      
      private var dienMentisMov:MovieClip;
      
      private var _book:AppModel;
      
      private var _intro:AppModel;
      
      public function MapProcess_437()
      {
         super();
      }
      
      override protected function init() : void
      {
         ToolBarController.showOrHideAllUser(true);
         conLevel["bead"].visible = false;
         conLevel["eye_1"].visible = false;
         conLevel["eye_2"].visible = false;
         conLevel["eye_3"].visible = false;
         conLevel["light"].visible = false;
         conLevel["door_0"].visible = false;
         ToolTipManager.add(conLevel["stoneBook"],"石碑");
         conLevel["stoneBook"].addEventListener(MouseEvent.CLICK,this.onBookClick);
         ToolTipManager.add(conLevel["intro"],"石块");
         conLevel["intro"].addEventListener(MouseEvent.CLICK,this.onIntroClick);
         ToolTipManager.add(conLevel["stoneLion"],"石柱");
         conLevel["stoneLion"].buttonMode = true;
         conLevel["stoneLion"].mouseChildren = false;
         conLevel["stoneLion"].addEventListener(MouseEvent.CLICK,this.onLionClick);
         this.map443Door = conLevel["map443Door"];
         this.map443Door.visible = false;
         this.task573Btn1 = conLevel["task573Btn1"];
         this.task573Btn2 = conLevel["task573Btn2"];
         this.task573Btn3 = conLevel["task573Btn3"];
         this.mouseMov = conLevel["mouseMov"];
         this.doorTips = conLevel["doorTips"];
         this.doorTips.closeBtn.addEventListener(MouseEvent.CLICK,this.onMouseDoor);
         this.mouseDoor = conLevel["mouseDoor"];
         this.mouseDoor.buttonMode = true;
         this.mouseDoor.addEventListener(MouseEvent.CLICK,this.onMouseDoor);
         this.mouseDoor.light.gotoAndStop(1);
         this.mouseDoor.light.visible = false;
         this.dienMentisMov = conLevel["dienMentisMov"];
         this.task573Done();
      }
      
      private function onMouseDoor(param1:MouseEvent) : void
      {
         conLevel.parent.addChild(this.doorTips);
         this.doorTips.visible = !this.doorTips.visible;
      }
      
      private function startTask573() : void
      {
         ToolTipManager.add(this.mouseDoor,"石门");
         this.mouseDoor.light.visible = true;
         this.mouseDoor.light.gotoAndPlay(2);
         this.mouseDoor.visible = true;
         this.map443Door.visible = true;
         this.dienMentisMov.visible = false;
      }
      
      private function task573Done() : void
      {
         this.doorTips.visible = false;
         this.mouseDoor.visible = false;
         this.dienMentisMov.visible = false;
         this.task573Btn1.visible = false;
         this.task573Btn2.visible = false;
         this.task573Btn3.visible = false;
         this.mouseMov.visible = false;
      }
      
      public function onDoorClick() : void
      {
         conLevel["light"].visible = true;
         AnimateManager.playMcAnimate(conLevel["light"],0,"",function():void
         {
            conLevel["light"].visible = false;
            NpcDialog.show(NPC.SEER,["啊……好刺眼！这里到底藏着什么？为什么不能进入？"],["再找找其它入口吧！"]);
         });
      }
      
      public function onBookClick(param1:MouseEvent) : void
      {
         if(!this._book)
         {
            this._book = new AppModel(ClientConfig.getAppModule("StoneBook_534"),"正在加载面板");
            this._book.setup();
         }
         this._book.show();
      }
      
      public function onIntroClick(param1:MouseEvent) : void
      {
         if(!this._intro)
         {
            this._intro = new AppModel(ClientConfig.getAppModule("StoneCityIntro_534"),"正在加载面板");
            this._intro.setup();
         }
         this._intro.show();
      }
      
      private function onLionClick(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         conLevel["stoneLion"].gotoAndStop(conLevel["stoneLion"].currentFrame + 1);
         if(conLevel["stoneLion"].currentFrame == 4)
         {
            ToolTipManager.remove(conLevel["stoneLion"]);
            conLevel["stoneLion"].buttonMode = false;
            conLevel["stoneLion"].removeEventListener(MouseEvent.CLICK,this.onLionClick);
            AnimateManager.playMcAnimate(conLevel["stoneLion"],5,"mc",function():void
            {
               conLevel["stoneLion"].gotoAndStop(4);
               conLevel["bead"].visible = true;
               ToolTipManager.add(conLevel["bead"],"宝珠");
               conLevel["bead"].buttonMode = true;
               conLevel["bead"].addEventListener(MouseEvent.MOUSE_UP,onBeadUp);
               DragManager.add(conLevel["bead"],conLevel["bead"]);
            });
         }
      }
      
      private function onBeadUp(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(conLevel["bead"].x > 360 && conLevel["bead"].x < 500 && conLevel["bead"].y > 320 && conLevel["bead"].y < 406)
         {
            conLevel["bead"].visible = false;
            ToolTipManager.remove(conLevel["bead"]);
            conLevel["bead"].removeEventListener(MouseEvent.MOUSE_UP,this.onBeadUp);
            DragManager.remove(conLevel["bead"]);
            AnimateManager.playMcAnimate(animatorLevel["ground"],2,"mc_1",function():void
            {
               var _loc1_:int = 0;
               var _loc2_:Array = [];
               do
               {
                  _loc1_ = Math.floor(Math.random() * 3 + 1);
                  if(_loc2_.indexOf(_loc1_) == -1)
                  {
                     _loc2_.push(_loc1_);
                  }
               }
               while(_loc2_.length != 3);
               
               conLevel["eye_1"].visible = true;
               conLevel["eye_1"].gotoAndStop(_loc2_[0]);
               ToolTipManager.add(conLevel["eye_1"],"六芒阵");
               conLevel["eye_1"].buttonMode = true;
               conLevel["eye_1"].mouseChildren = false;
               conLevel["eye_1"].addEventListener(MouseEvent.CLICK,onEyeClick);
               conLevel["eye_2"].visible = true;
               conLevel["eye_2"].gotoAndStop(_loc2_[1]);
               ToolTipManager.add(conLevel["eye_2"],"六芒阵");
               conLevel["eye_2"].buttonMode = true;
               conLevel["eye_2"].mouseChildren = false;
               conLevel["eye_2"].addEventListener(MouseEvent.CLICK,onEyeClick);
               conLevel["eye_3"].visible = true;
               conLevel["eye_3"].gotoAndStop(_loc2_[2]);
               ToolTipManager.add(conLevel["eye_3"],"六芒阵");
               conLevel["eye_3"].buttonMode = true;
               conLevel["eye_3"].mouseChildren = false;
               conLevel["eye_3"].addEventListener(MouseEvent.CLICK,onEyeClick);
            });
         }
      }
      
      private function onEyeClick(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var mc:MovieClip = e.target as MovieClip;
         if(mc.currentFrame == 3)
         {
            mc.gotoAndStop(1);
         }
         else
         {
            mc.gotoAndStop(mc.currentFrame + 1);
         }
         if(conLevel["eye_1"].currentFrame == conLevel["eye_2"].currentFrame && conLevel["eye_2"].currentFrame == conLevel["eye_3"].currentFrame)
         {
            ToolTipManager.remove(conLevel["eye_1"]);
            conLevel["eye_3"].buttonMode = false;
            conLevel["eye_1"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
            ToolTipManager.remove(conLevel["eye_2"]);
            conLevel["eye_3"].buttonMode = false;
            conLevel["eye_2"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
            ToolTipManager.remove(conLevel["eye_3"]);
            conLevel["eye_3"].buttonMode = false;
            conLevel["eye_3"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
            AnimateManager.playMcAnimate(animatorLevel["ground"],3,"mc_2",function():void
            {
               AnimateManager.playMcAnimate(conLevel["tree"],0,"",function():void
               {
                  conLevel["door_0"].visible = true;
               });
            });
         }
      }
      
      override public function destroy() : void
      {
         ToolTipManager.remove(conLevel["stoneBook"]);
         conLevel["stoneBook"].removeEventListener(MouseEvent.CLICK,this.onBookClick);
         ToolTipManager.remove(conLevel["intro"]);
         conLevel["intro"].removeEventListener(MouseEvent.CLICK,this.onIntroClick);
         ToolTipManager.remove(conLevel["stoneLion"]);
         conLevel["stoneLion"].removeEventListener(MouseEvent.CLICK,this.onLionClick);
         ToolTipManager.remove(conLevel["bead"]);
         conLevel["bead"].removeEventListener(MouseEvent.MOUSE_UP,this.onBeadUp);
         DragManager.remove(conLevel["bead"]);
         ToolTipManager.remove(conLevel["eye_1"]);
         conLevel["eye_1"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
         ToolTipManager.remove(conLevel["eye_2"]);
         conLevel["eye_2"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
         ToolTipManager.remove(conLevel["eye_3"]);
         conLevel["eye_3"].removeEventListener(MouseEvent.CLICK,this.onEyeClick);
      }
   }
}

