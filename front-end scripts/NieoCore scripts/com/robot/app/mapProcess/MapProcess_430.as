package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.CommandID;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.utils.CommonUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.DragManager;
   import org.taomee.manager.ToolTipManager;
   
   public class MapProcess_430 extends BaseMapProcess
   {
      
      private var _hitNum:int;
      
      private var _point_1:Point;
      
      private var _point_2:Point;
      
      private var _timer:Timer;
      
      private var _array:Array = [false,false];
      
      private var _stone:MovieClip;
      
      private var _stone_1:MovieClip;
      
      private var _stone_2:MovieClip;
      
      private var _spring_1:MovieClip;
      
      private var _spring_2:MovieClip;
      
      private var _spring_3:MovieClip;
      
      private var crystal:MovieClip;
      
      private var crystalClickTimes:uint;
      
      private var spt672Btn:SimpleButton;
      
      private var tempMC:Sprite;
      
      public function MapProcess_430()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._stone = conLevel["stone"];
         ToolTipManager.add(this._stone,"活力浮石");
         this._stone_1 = conLevel["stone_1"];
         this._stone_1.visible = false;
         this._stone_1.mouseChildren = false;
         ToolTipManager.add(this._stone_1,"石块");
         this._point_1 = new Point(this._stone_1.x,this._stone_1.y);
         this._stone_2 = conLevel["stone_2"];
         this._stone_2.visible = false;
         this._stone_2.mouseChildren = false;
         this._point_2 = new Point(this._stone_2.x,this._stone_2.y);
         ToolTipManager.add(this._stone_2,"石块");
         this._timer = new Timer(30000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this._spring_1 = conLevel["spring_1"];
         this._spring_2 = conLevel["spring_2"];
         this._spring_3 = conLevel["spring_3"];
         DragManager.add(this._stone_1,this._stone_1);
         DragManager.add(this._stone_2,this._stone_2);
         this._stone_1.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this._stone_2.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onPlayEnd);
         this.addSPT672();
      }
      
      private function addSPT672() : void
      {
         this.tempMC = new Sprite();
         this.tempMC.graphics.beginFill(0);
         this.tempMC.graphics.drawRect(0,0,121,82);
         this.tempMC.graphics.endFill();
         this.tempMC.alpha = 0;
         this.tempMC.x = 568;
         this.tempMC.y = 288;
         typeLevel.addChild(this.tempMC);
         MapManager.currentMap.makeMapArray();
         this.spt672Btn = conLevel["spt672Btn"];
         this.spt672Btn.visible = false;
         this.spt672Btn.addEventListener(MouseEvent.CLICK,this.onSPT672Click);
         this.crystalClickTimes = 1;
         this.crystal = conLevel["crystal"];
         this.crystal.buttonMode = true;
         this.crystal.addEventListener(MouseEvent.CLICK,this.onCrystalClick);
      }
      
      private function onSPT672Click(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("亚伦斯");
      }
      
      private function removeSPT672() : void
      {
         this.spt672Btn.removeEventListener(MouseEvent.CLICK,this.onSPT672Click);
         this.crystal.removeEventListener(MouseEvent.CLICK,this.onCrystalClick);
      }
      
      private function onCrystalClick(param1:MouseEvent) : void
      {
         var _loc2_:PetListInfo = null;
         var _loc3_:PetListInfo = null;
         var _loc4_:Array = PetManager.getBagMap();
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.id == 671)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(Boolean(_loc2_))
         {
            if(_loc2_.level >= 26 && TasksManager.getTaskStatus(322) == TasksManager.COMPLETE)
            {
               SocketConnection.addCmdListener(CommandID.PET_EVOLVTION,this.evo);
               SocketConnection.send(CommandID.PET_EVOLVTION,_loc2_.catchTime,1);
            }
            else
            {
               this.clickGoOn();
            }
         }
         else
         {
            this.clickGoOn();
         }
      }
      
      private function evo(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_EVOLVTION,this.evo);
         AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("spt671EVO"));
      }
      
      private function clickGoOn() : void
      {
         ++this.crystalClickTimes;
         if(this.crystalClickTimes < 4)
         {
            this.crystal.gotoAndStop(this.crystalClickTimes);
         }
         else
         {
            this.crystal.removeEventListener(MouseEvent.CLICK,this.onCrystalClick);
            this.spt672Btn.alpha = 0;
            this.spt672Btn.visible = true;
            this.crystal.buttonMode = false;
            this.crystal.mouseEnabled = false;
            this.crystal.mouseChildren = false;
            this.crystal.gotoAndStop(this.crystal.totalFrames);
         }
      }
      
      private function onPlayEnd(param1:AimatEvent) : void
      {
         var e:AimatEvent = param1;
         var info:AimatInfo = e.info as AimatInfo;
         if(info.userID == MainManager.actorID)
         {
            if(this._stone.hitTestPoint(info.endPos.x,info.endPos.y))
            {
               if(this._hitNum == 0)
               {
                  ++this._hitNum;
                  AnimateManager.playMcAnimate(this._stone,2,"mc_1",function():void
                  {
                     _stone_1.visible = true;
                  });
               }
               else if(this._hitNum == 1)
               {
                  ++this._hitNum;
                  AnimateManager.playMcAnimate(this._stone,3,"mc_2",function():void
                  {
                     _stone_2.visible = true;
                  });
               }
               if(this._hitNum == 2)
               {
                  CommonUI.removeYellowArrow(topLevel);
                  ToolTipManager.remove(this._stone);
                  ToolTipManager.add(this._stone,"活力浮石");
                  NpcDialog.show(NPC.SEER,["成功了！！接下来要怎么做呢？让我想想..."],[function():void
                  {
                     NpcDialog.show(NPC.SEER,["有了！0xff0000用碎石块压住其他两支水柱，就可以将中央的水柱升起带动浮石，做出道路了0xffffff！！哎呀，我真是太聪明了！"],[function():void
                     {
                        CommonUI.addYellowArrow(topLevel,744,322,45);
                        CommonUI.addYellowArrow(topLevel,796,189,45);
                        ToolTipManager.add(conLevel["spring_1"],"用碎石块压住水柱");
                        ToolTipManager.add(conLevel["spring_2"],"用碎石块压住水柱");
                     }]);
                  }]);
               }
            }
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(param1.target == this._stone_1)
         {
            if(!this._array[0])
            {
               if(this._stone_1.x > 636 && this._stone_1.x < 676 && this._stone_1.y > 356 && this._stone_1.y < 396)
               {
                  this._array[0] = true;
                  this._stone_1.visible = false;
                  this.changeHeight();
               }
            }
            if(!this._array[1])
            {
               if(this._stone_1.x > 686 && this._stone_1.x < 726 && this._stone_1.y > 186 && this._stone_1.y < 226)
               {
                  this._array[1] = true;
                  this._stone_1.visible = false;
                  this.changeHeight();
               }
            }
         }
         if(param1.target == this._stone_2)
         {
            if(!this._array[0])
            {
               if(this._stone_2.x > 656 && this._stone_2.x < 686 && this._stone_2.y > 382 && this._stone_2.y < 412)
               {
                  this._array[0] = true;
                  this._stone_2.visible = false;
                  this.changeHeight();
               }
            }
            if(!this._array[1])
            {
               if(this._stone_2.x > 712 && this._stone_2.x < 742 && this._stone_2.y > 216 && this._stone_2.y < 246)
               {
                  this._array[1] = true;
                  this._stone_2.visible = false;
                  this.changeHeight();
               }
            }
         }
      }
      
      private function changeHeight() : void
      {
         if(!this._array[0] && !this._array[1])
         {
            if(this._spring_1.currentFrame != 4)
            {
               this._spring_1.gotoAndStop(4);
               this._spring_1.addEventListener(Event.ENTER_FRAME,this.gotoFrame_1);
            }
            if(this._spring_2.currentFrame != 4)
            {
               this._spring_2.gotoAndStop(4);
               this._spring_2.addEventListener(Event.ENTER_FRAME,this.gotoFrame_1);
            }
            if(this._spring_3.currentFrame != 4)
            {
               typeLevel["block"].y = 92.5;
               MapManager.currentMap.makeMapArray();
               AnimateManager.playMcAnimate(this._spring_3,4,"mc_2",function():void
               {
                  _spring_3.gotoAndStop(1);
                  _stone_1.x = _point_1.x;
                  _stone_1.y = _point_1.y;
                  _stone_2.x = _point_2.x;
                  _stone_2.y = _point_2.y;
                  AnimateManager.playMcAnimate(_stone,4,"mc_3",function():void
                  {
                     _hitNum = 0;
                     _stone.gotoAndStop(1);
                  });
               });
            }
         }
         else if(Boolean(this._array[0]) && !this._array[1])
         {
            if(this._spring_1.currentFrame != 2)
            {
               this._spring_1.gotoAndStop(2);
            }
            if(this._spring_2.currentFrame != 3)
            {
               this._spring_2.gotoAndStop(3);
            }
            if(this._spring_3.currentFrame != 2)
            {
               this._spring_3.gotoAndStop(2);
            }
            CommonUI.removeYellowArrow(topLevel);
            CommonUI.addYellowArrow(topLevel,796,189,45);
            ToolTipManager.remove(conLevel["spring_1"]);
         }
         else if(!this._array[0] && Boolean(this._array[1]))
         {
            if(this._spring_1.currentFrame != 3)
            {
               this._spring_1.gotoAndStop(3);
            }
            if(this._spring_2.currentFrame != 2)
            {
               this._spring_2.gotoAndStop(2);
            }
            if(this._spring_3.currentFrame != 2)
            {
               this._spring_3.gotoAndStop(2);
            }
            CommonUI.removeYellowArrow(topLevel);
            CommonUI.removeYellowArrow(topLevel);
            CommonUI.addYellowArrow(topLevel,744,322,45);
            ToolTipManager.remove(conLevel["spring_2"]);
         }
         else
         {
            CommonUI.removeYellowArrow(topLevel);
            CommonUI.removeYellowArrow(topLevel);
            ToolTipManager.remove(conLevel["spring_1"]);
            ToolTipManager.remove(conLevel["spring_2"]);
            this._timer.start();
            if(this._spring_1.currentFrame != 2)
            {
               this._spring_1.gotoAndStop(2);
            }
            if(this._spring_2.currentFrame != 2)
            {
               this._spring_2.gotoAndStop(2);
            }
            AnimateManager.playMcAnimate(this._spring_3,3,"mc_1",function():void
            {
               typeLevel["block"].y = 0;
               MapManager.currentMap.makeMapArray();
            });
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this._array[0] = false;
         this._array[1] = false;
         this._timer.reset();
         this.changeHeight();
      }
      
      private function gotoFrame_1(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(Boolean(_loc2_["mc"]))
         {
            if(_loc2_["mc"].currentFrame == _loc2_["mc"].totalFrames)
            {
               _loc2_.gotoAndStop(1);
               param1.currentTarget.removeEventListener(Event.ENTER_FRAME,this.gotoFrame_1);
            }
         }
      }
      
      public function onBoxClick() : void
      {
      }
      
      override public function destroy() : void
      {
         this.removeSPT672();
         ToolTipManager.remove(this._stone);
         ToolTipManager.remove(this._stone_1);
         ToolTipManager.remove(this._stone_2);
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this._stone_1.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this._stone_2.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onPlayEnd);
      }
   }
}

