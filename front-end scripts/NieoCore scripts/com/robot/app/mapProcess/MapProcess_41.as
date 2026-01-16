package com.robot.app.mapProcess
{
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.utils.*;
   
   public class MapProcess_41 extends BaseMapProcess
   {
      
      private var _dia_1:MovieClip;
      
      private var maskMC:MovieClip;
      
      private var maskMC2:MovieClip;
      
      private var diamondBtn:SimpleButton;
      
      private var stoneMC:MovieClip;
      
      private var _shouMc:MovieClip;
      
      private var kakaBtn:SimpleButton;
      
      private var kakaMc:MovieClip;
      
      private var guang_mc:MovieClip;
      
      private var light_mc:MovieClip;
      
      public function MapProcess_41()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._dia_1 = conLevel.getChildByName("diaMc_1") as MovieClip;
         this._dia_1.visible = false;
         this._shouMc = conLevel.getChildByName("shouMc") as MovieClip;
         this._shouMc.visible = false;
         this.stoneMC = conLevel["stoneMC"];
         this.stoneMC.gotoAndStop(1);
         this.stoneMC.buttonMode = true;
         this.stoneMC.addEventListener(MouseEvent.CLICK,this.clickStone);
         this.maskMC = topLevel["maskMC"];
         this.maskMC2 = topLevel["maskMC2"];
         this.kakaMc = conLevel["kaka_mc"].kaka_mc;
         this.kakaBtn = conLevel["kakaBtn"];
         this.guang_mc = conLevel["guang_mc"];
         this.guang_mc.gotoAndStop(1);
         this.guang_mc.visible = false;
         this.light_mc = topLevel["light_mc"];
         this.diamondBtn = conLevel["diamondBtn"];
         this.diamondBtn.addEventListener(MouseEvent.CLICK,this.clickDiamond);
         this.cheak();
      }
      
      private function handPlay() : void
      {
         this.kakaMc.visible = false;
         this.light_mc.visible = false;
      }
      
      override public function destroy() : void
      {
         this.maskMC = null;
         this.maskMC2 = null;
         this.diamondBtn.removeEventListener(MouseEvent.CLICK,this.clickDiamond);
         this.diamondBtn = null;
         this.stoneMC.removeEventListener(MouseEvent.CLICK,this.clickStone);
         this.stoneMC = null;
         this.kakaBtn = null;
         this.kakaMc = null;
      }
      
      private function cheak() : void
      {
         if(TasksManager.getTaskStatus(8) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(8,function(param1:Array):void
            {
               if(Boolean(param1[0]) && !param1[1])
               {
                  _shouMc.visible = true;
               }
               if(!param1[5])
               {
                  _dia_1.visible = true;
               }
            });
         }
      }
      
      private function clickDiamond(param1:MouseEvent) : void
      {
         this.maskMC["mirrorMC"].play();
         this.maskMC.play();
      }
      
      private function clickStone(param1:MouseEvent) : void
      {
         if(this.stoneMC.currentFrame < 35)
         {
            this.stoneMC.play();
         }
      }
      
      public function hitHole() : void
      {
         DisplayUtil.removeForParent(conLevel["holeMC"]);
      }
      
      public function getDia_1() : void
      {
         TasksManager.complete(8,5,function(param1:Boolean):void
         {
            _dia_1.visible = false;
            Alarm.show("你得到一块晶体");
         });
      }
      
      public function onShouHit() : void
      {
         this._shouMc.visible = false;
      }
   }
}

