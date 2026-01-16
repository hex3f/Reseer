package com.robot.app.mapProcess
{
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.controller.MouseController;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class MapProcess_427 extends BaseMapProcess
   {
      
      private var _dmc0:MovieClip;
      
      private var _dmc1:MovieClip;
      
      private var _dmc2:MovieClip;
      
      private var _dmc3:MovieClip;
      
      private var isUnLocked:Boolean = false;
      
      private var _maskMc:MovieClip;
      
      private var _bgMc:MovieClip;
      
      private var _blackMc:MovieClip;
      
      public function MapProcess_427()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._dmc0 = this.topLevel["dmc0"];
         this._dmc1 = this.topLevel["dmc1"];
         this._dmc2 = this.topLevel["dmc2"];
         this._dmc3 = this.topLevel["dmc3"];
         this._maskMc = this.topLevel["maskMc"];
         this._bgMc = this.topLevel["bgMc"];
         this._blackMc = this.topLevel["blackMc"];
         this._dmc0.visible = false;
         this._dmc1.visible = false;
         this._dmc2.visible = false;
         this._dmc3.visible = false;
         this._maskMc.mouseEnabled = false;
         this._maskMc.mouseChildren = false;
         this._bgMc.mouseEnabled = false;
         this._bgMc.mouseChildren = false;
         this._blackMc.mouseEnabled = false;
         this._blackMc.mouseChildren = false;
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         var _loc1_:Point = MapXMLInfo.getDefaultPos(427);
         this._maskMc.x = _loc1_.x;
         this._maskMc.y = _loc1_.y;
         this.isUnLocked = true;
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         this._maskMc.x = MainManager.actorModel.sprite.x;
         this._maskMc.y = MainManager.actorModel.sprite.y - 20;
      }
      
      override public function destroy() : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         ToolBarController.showOrHideAllUser(true);
      }
      
      public function onGoto1() : void
      {
         NpcDialog.show(NPC.SEER,["不对啊！这里我来过了！还挪动了机关打开了某个阀门呢！快去找那个阀门吧！"],["应该就在不远处吧！"],[function():void
         {
         }]);
      }
      
      public function onGoto2() : void
      {
         this._dmc1.visible = true;
         AnimateManager.playMcAnimate(this._dmc1,2,"ani",function():void
         {
            _dmc1.visible = false;
            _dmc1.gotoAndStop(1);
            AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("task_525_2"),function():void
            {
               MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapOpenHandler);
               MapManager.changeMap(30);
            });
         });
      }
      
      public function onGoto3() : void
      {
         this._dmc2.visible = true;
         AnimateManager.playMcAnimate(this._dmc2,2,"ani",function():void
         {
            _dmc2.visible = false;
            _dmc2.gotoAndStop(1);
            AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("task_525_3"),function():void
            {
               MainManager.actorModel.stop();
               MainManager.actorModel.pos = new Point(72,430);
            });
         });
      }
      
      private function onMapOpenHandler(param1:MapEvent) : void
      {
         var e:MapEvent = param1;
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,this.onMapOpenHandler);
         MapManager.currentMap.depthLevel.mouseEnabled = false;
         MouseController.removeMouseEvent();
         NpcDialog.show(NPC.SEER,["这里是哪里？这不是赫尔卡星吗？我记得我刚才在空间补给站的地窖里啊……"],["难道我走错阀门了？不行！我得再去看看！"],[function():void
         {
            MapManager.currentMap.depthLevel.mouseEnabled = true;
            MapManager.changeMap(424);
         }]);
      }
      
      public function onGoto4() : void
      {
         this._dmc3.visible = true;
         AnimateManager.playMcAnimate(this._dmc3,2,"ani",function():void
         {
            _dmc3.visible = false;
            _dmc3.gotoAndStop(1);
            AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("task_525_4_2"),function():void
            {
               MapManager.changeMap(428);
            });
         });
      }
   }
}

