package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.*;
   import com.robot.app.spacesurvey.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.config.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.utils.*;
   
   public class MapProcess_15 extends BaseMapProcess
   {
      
      private var _musicMc:MovieClip;
      
      private var _musicBtn:MovieClip;
      
      private var monkeyApp:AppModel;
      
      public function MapProcess_15()
      {
         super();
      }
      
      override protected function init() : void
      {
         SpaceSurveyTool.getInstance().show("火山星");
         this._musicMc = conLevel.getChildByName("musicMc") as MovieClip;
         this._musicMc.gotoAndStop(1);
         this._musicMc.mouseEnabled = false;
         this._musicMc.buttonMode = true;
         this._musicMc.visible = false;
         this._musicBtn = conLevel.getChildByName("musicBtn") as MovieClip;
         this._musicBtn.addEventListener(MouseEvent.CLICK,this.onPaoClick);
         this._musicBtn.mouseEnabled = false;
         this._musicBtn.visible = false;
         this.check();
      }
      
      override public function destroy() : void
      {
         SpaceSurveyTool.getInstance().hide();
         this._musicBtn.removeEventListener(MouseEvent.CLICK,this.onPaoClick);
         this._musicMc.removeEventListener(MouseEvent.CLICK,this.onMusicClick);
         this._musicMc = null;
         this._musicBtn = null;
         if(Boolean(this.monkeyApp))
         {
            this.monkeyApp.destroy();
         }
         this.monkeyApp = null;
      }
      
      private function check() : void
      {
         if(TasksManager.getTaskStatus(401) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatus(401,0,function(param1:Boolean):void
            {
               if(!param1)
               {
                  _musicMc.mouseEnabled = true;
                  _musicMc.visible = true;
                  _musicMc.addEventListener(MouseEvent.CLICK,onMusicClick);
                  _musicBtn.visible = true;
                  _musicBtn.mouseEnabled = true;
               }
            });
         }
      }
      
      private function onPaoClick(param1:MouseEvent) : void
      {
         this._musicMc.gotoAndStop(2);
      }
      
      private function onMusicClick(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(!MainManager.actorModel.getIsPetFollw(22) && !MainManager.actorModel.getIsPetFollw(23) && !MainManager.actorModel.getIsPetFollw(24))
         {
            Alarm.show("只有带上你的<font color=\'#ff0000\'>毛毛</font>，这些音符才会起到作用呢。");
            return;
         }
         TasksManager.complete(401,0,function(param1:Boolean):void
         {
            if(param1)
            {
               DisplayUtil.removeForParent(_musicMc);
               Alarm.show("你帮助毛毛找到了一个音符！");
            }
         });
      }
      
      public function exploitOre() : void
      {
         EnergyController.exploit();
      }
      
      public function monkeyFun() : void
      {
         var _loc1_:String = null;
         var _loc4_:int = 0;
         var _loc2_:Array = [7,8,9,307,308,309];
         if(TasksManager.getTaskStatus(402) == TasksManager.COMPLETE)
         {
            NpcTipDialog.show("你的小火猴已经训练过一次咯，该休息一下了。合理控制训练强度，才能进步更快。",null,NpcTipDialog.GUARD);
            return;
         }
         if(TasksManager.getTaskStatus(402) == TasksManager.UN_ACCEPT)
         {
            _loc1_ = "你还没有领取" + TextFormatUtil.getRedTxt("小火猴的武学梦想") + "任务呢，" + "快点击右上角的" + TextFormatUtil.getRedTxt("精灵训练营") + "按钮看看吧！";
            Alarm.show(_loc1_);
            return;
         }
         var _loc3_:PetModel = MainManager.actorModel.pet;
         if(!_loc3_)
         {
            NpcTipDialog.show("要带上你的<font color=\'#ff0000\'>小火猴</font>在身边才能帮助他进行训练哦。",null,NpcTipDialog.GUARD);
            return;
         }
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_.info.petID == _loc2_[_loc4_])
            {
               this.onAccepetMonkey();
               return;
            }
            _loc4_++;
         }
         NpcTipDialog.show("要带上你的<font color=\'#ff0000\'>小火猴</font>在身边才能帮助他进行训练哦。",null,NpcTipDialog.GUARD);
      }
      
      private function onAccepetMonkey() : void
      {
         if(!this.monkeyApp)
         {
            this.monkeyApp = new AppModel(ClientConfig.getTaskModule("MonkeyKongfu"),"正在加载游戏");
            this.monkeyApp.setup();
         }
         this.monkeyApp.show();
      }
   }
}

