package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.event.SysTimeEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.SystemTimerManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_415 extends BaseMapProcess
   {
      
      private static const ROCK_NUM:uint = 3;
      
      private static const INIT_POINTS:Array = [[[100,236],[192,242],[744,172]],[[202,350],[356,336],[686,344]],[[906,170],[850,348],[860,270]]];
      
      private var _rock1:MovieClip;
      
      private var _rock2:MovieClip;
      
      private var _rock3:MovieClip;
      
      private var _rockStatus:Array;
      
      private var _isStart:Boolean = false;
      
      public function MapProcess_415()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.initRocks();
         EventManager.addEventListener(SysTimeEvent.RECEIVE_SYSTEM_TIME,this.onSysTime);
         this.initMoonPetOutbreak();
      }
      
      private function initRocks() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:* = 0;
         this._rockStatus = new Array(3);
         var _loc3_:Number = 0;
         while(_loc3_ < ROCK_NUM)
         {
            _loc1_ = Math.random() < 0.1 ? true : false;
            this._rockStatus[_loc3_] = _loc1_;
            if(_loc1_)
            {
               _loc2_ = uint(_loc3_ + 1);
               while(_loc2_ < ROCK_NUM)
               {
                  this._rockStatus[_loc2_] = false;
                  _loc2_++;
               }
               break;
            }
            _loc3_++;
         }
         this._rock1 = conLevel["rock_1"];
         this._rock2 = conLevel["rock_2"];
         this._rock3 = conLevel["rock_3"];
         this._rock1.buttonMode = true;
         this._rock2.buttonMode = true;
         this._rock3.buttonMode = true;
         ToolTipManager.add(this._rock1,"奇怪的石头");
         ToolTipManager.add(this._rock2,"奇怪的石头");
         ToolTipManager.add(this._rock3,"奇怪的石头");
         this._rock1.addEventListener(MouseEvent.CLICK,this.onRockClick);
         this._rock2.addEventListener(MouseEvent.CLICK,this.onRockClick);
         this._rock3.addEventListener(MouseEvent.CLICK,this.onRockClick);
         this.initRocksPoint();
      }
      
      private function initRocksPoint() : void
      {
         var _loc1_:* = 0;
         var _loc2_:Number = 0;
         while(_loc2_ < ROCK_NUM)
         {
            _loc1_ = Math.floor(Math.random() * 3);
            conLevel["rock_" + (_loc2_ + 1)].x = INIT_POINTS[_loc2_][_loc1_][0];
            conLevel["rock_" + (_loc2_ + 1)].y = INIT_POINTS[_loc2_][_loc1_][1];
            _loc2_++;
         }
      }
      
      private function onRockClick(param1:MouseEvent) : void
      {
         var index:uint = 0;
         var rock:MovieClip = null;
         rock = null;
         rock = param1.target as MovieClip;
         ToolTipManager.remove(rock);
         rock.removeEventListener(MouseEvent.CLICK,this.onRockClick);
         index = uint(uint(rock.name.split("_")[1]) - 1);
         if(Boolean(this._rockStatus[index]))
         {
            AnimateManager.playMcAnimate(rock,3,"mc_3",function():void
            {
               ToolTipManager.add(rock,"该伊");
               rock.addEventListener(MouseEvent.CLICK,onFightBoss);
            });
         }
         else
         {
            AnimateManager.playMcAnimate(rock,2,"mc_2",function():void
            {
            });
         }
      }
      
      private function onFightBoss(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("该伊",0);
      }
      
      private function initMoonPetOutbreak() : void
      {
         var _loc1_:int = this.getTimeFlag();
         if(_loc1_ == -1)
         {
            if(this._isStart)
            {
               ToolTipManager.remove(depthLevel["stone"]);
               depthLevel["stone"].buttonMode = false;
               depthLevel["stone"].removeEventListener(MouseEvent.CLICK,this.onMoonStoneClick);
               EventManager.removeEventListener(SysTimeEvent.RECEIVE_SYSTEM_TIME,this.onSysTime);
            }
            DisplayUtil.removeForParent(depthLevel["pets"]);
            DisplayUtil.removeForParent(depthLevel["stone"]);
         }
         else if(_loc1_ == 0)
         {
            depthLevel["pets"].visible = false;
            depthLevel["stone"].visible = false;
         }
         else
         {
            this.startMoonPetOutbreak();
         }
      }
      
      private function getTimeFlag() : int
      {
         var _loc1_:Date = SystemTimerManager.sysDate;
         if(_loc1_.getMonth() != 8)
         {
            return -1;
         }
         if(_loc1_.getDate() < 9 || _loc1_.getDate() > 12)
         {
            return -1;
         }
         if(_loc1_.getUTCHours() + 8 < 18)
         {
            return 0;
         }
         if(_loc1_.getUTCHours() + 8 == 18)
         {
            if(_loc1_.getMinutes() >= 30)
            {
               return 1;
            }
            return 0;
         }
         if(_loc1_.getUTCHours() + 8 == 19)
         {
            if(_loc1_.getMinutes() < 30)
            {
               return 1;
            }
            return -1;
         }
         return -1;
      }
      
      private function onSysTime(param1:SysTimeEvent) : void
      {
         this.initMoonPetOutbreak();
      }
      
      private function startMoonPetOutbreak() : void
      {
         if(this._isStart == false)
         {
            this._isStart = true;
            ToolTipManager.add(depthLevel["stone"],"月亮石");
            depthLevel["stone"].buttonMode = true;
            depthLevel["stone"].addEventListener(MouseEvent.CLICK,this.onMoonStoneClick);
         }
      }
      
      private function onMoonStoneClick(param1:MouseEvent) : void
      {
         var id:uint = 0;
         var e:MouseEvent = param1;
         if(Boolean(MainManager.actorModel.pet))
         {
            id = uint(MainManager.actorModel.pet.info.petID);
            if(id == 461 || id == 462 || id == 2504 || id == 903 || id == 904 || id == 2534)
            {
               AnimateManager.playMcAnimate(depthLevel["stone"],2,"mc_2",function():void
               {
                  AnimateManager.playMcAnimate(depthLevel["stone"],3,"mc_3",function():void
                  {
                     depthLevel["stone"].gotoAndStop(1);
                     topLevel["light"].x = MainManager.actorModel.pet.x;
                     topLevel["light"].y = MainManager.actorModel.pet.y;
                     AnimateManager.playMcAnimate(topLevel["light"],0,"",function():void
                     {
                        Alarm.show("一股神奇的力量似乎正在月光兽体内涌动着……………………………");
                     });
                  });
               });
            }
            else
            {
               Alarm.show("只有带着月光兽才能参加他们的特殊仪式哦！");
            }
         }
         else
         {
            Alarm.show("只有带着月光兽才能参加他们的特殊仪式哦！");
         }
      }
      
      override public function destroy() : void
      {
         this._rock1.removeEventListener(MouseEvent.CLICK,this.onRockClick);
         this._rock2.removeEventListener(MouseEvent.CLICK,this.onRockClick);
         this._rock3.removeEventListener(MouseEvent.CLICK,this.onRockClick);
         this._rock1.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
         this._rock2.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
         this._rock3.removeEventListener(MouseEvent.CLICK,this.onFightBoss);
         ToolTipManager.remove(this._rock1);
         ToolTipManager.remove(this._rock2);
         ToolTipManager.remove(this._rock3);
         this._rock1 = null;
         this._rock2 = null;
         this._rock3 = null;
         if(Boolean(depthLevel["stone"]))
         {
            ToolTipManager.remove(depthLevel["stone"]);
            depthLevel["stone"].removeEventListener(MouseEvent.CLICK,this.onMoonStoneClick);
         }
         this._isStart = false;
         EventManager.removeEventListener(SysTimeEvent.RECEIVE_SYSTEM_TIME,this.onSysTime);
      }
   }
}

