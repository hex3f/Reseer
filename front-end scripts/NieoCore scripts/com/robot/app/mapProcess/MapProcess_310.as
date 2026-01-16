package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.aimat.*;
   import com.robot.core.event.*;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.Point;
   
   public class MapProcess_310 extends BaseMapProcess
   {
      
      private var lili:MovieClip;
      
      private var miaozhunMC:MovieClip;
      
      private var oilcanArr:Array = [];
      
      private var count:uint = 0;
      
      private var hitArr:Array = [];
      
      public function MapProcess_310()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:String = null;
         var _loc2_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         var _loc5_:uint = 0;
         MazeController.setup();
         while(_loc5_ < 8)
         {
            _loc1_ = "oilcan_" + _loc5_;
            _loc2_ = conLevel[_loc1_] as MovieClip;
            _loc2_.gotoAndStop(1);
            this.oilcanArr.push(_loc2_);
            _loc3_ = "hitMC_" + _loc5_;
            _loc4_ = conLevel[_loc3_] as MovieClip;
            _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.onHitMcOver);
            _loc4_.addEventListener(MouseEvent.MOUSE_OUT,this.onHitMcOut);
            this.hitArr.push(_loc4_);
            _loc5_++;
         }
         this.lili = conLevel["lili"];
         this.lili.visible = false;
         this.miaozhunMC = conLevel["miaozhunMC"];
         this.miaozhunMC.visible = false;
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimat);
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimat);
      }
      
      private function onAimat(param1:AimatEvent) : void
      {
         var _loc5_:uint = 0;
         var _loc2_:Number = NaN;
         var _loc3_:AimatInfo = param1.info;
         if(_loc3_.userID != MainManager.actorID)
         {
            return;
         }
         var _loc4_:Point = _loc3_.endPos;
         while(_loc5_ < this.hitArr.length)
         {
            if(Boolean(this.hitArr[_loc5_].hitTestPoint(_loc4_.x,_loc4_.y)))
            {
               if(this.oilcanArr[_loc5_].currentFrame != 2)
               {
                  this.oilcanArr[_loc5_].gotoAndStop(2);
                  this.hitArr[_loc5_].removeEventListener(MouseEvent.MOUSE_OVER,this.onHitMcOver);
                  this.hitArr[_loc5_].removeEventListener(MouseEvent.MOUSE_OUT,this.onHitMcOut);
                  ++this.count;
               }
            }
            _loc5_++;
         }
         if(this.count == 8)
         {
            AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimat);
            _loc2_ = Math.random();
            if(_loc2_ <= 0.1)
            {
               this.lili.visible = true;
               this.lili.buttonMode = true;
               this.lili.addEventListener(MouseEvent.CLICK,this.onFightLili);
            }
            if(_loc2_ >= 0.9)
            {
               MapManager.changeMap(314);
            }
         }
      }
      
      private function onFightLili(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("果冻鸭");
      }
      
      private function onHitMcOver(param1:MouseEvent) : void
      {
         this.miaozhunMC.visible = true;
         this.miaozhunMC.x = MainManager.getStage().mouseX;
         this.miaozhunMC.y = MainManager.getStage().mouseY;
      }
      
      private function onHitMcOut(param1:MouseEvent) : void
      {
         this.miaozhunMC.visible = false;
      }
   }
}

