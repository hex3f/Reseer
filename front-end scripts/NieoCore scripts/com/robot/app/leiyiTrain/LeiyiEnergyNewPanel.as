package com.robot.app.leiyiTrain
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class LeiyiEnergyNewPanel extends Sprite
   {
      
      private var _mainUI:MovieClip;
      
      private var app:ApplicationDomain;
      
      private var _closeBtn:SimpleButton;
      
      private var _returnBtn:SimpleButton;
      
      private var _today:Array;
      
      private var _current:Array;
      
      private var _total:Array;
      
      private var _desList:Array = ["体力","防御","特防","攻击","特攻","速度"];
      
      public function LeiyiEnergyNewPanel()
      {
         super();
      }
      
      public function setup(param1:MCLoadEvent) : void
      {
         var event:MCLoadEvent = param1;
         this.app = event.getApplicationDomain();
         this._mainUI = new (this.app.getDefinition("ChoosePanelUI") as Class)() as MovieClip;
         addChild(this._mainUI);
         DisplayUtil.align(this,null,AlignType.TOP_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(this);
         this._closeBtn = this._mainUI["close_btn"];
         this._returnBtn = this._mainUI["returnBtn"];
         SocketConnection.addCmdListener(CommandID.LEIYI_TRAIN_GET_STATUS,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.LEIYI_TRAIN_GET_STATUS,arguments.callee);
            var _loc3_:ByteArray = param1.data as ByteArray;
            _today = [];
            _current = [];
            _total = [];
            var _loc4_:int = 0;
            while(_loc4_ < 6)
            {
               _today.push(_loc3_.readUnsignedInt());
               _current.push(_loc3_.readUnsignedInt());
               _total.push(_loc3_.readUnsignedInt());
               _loc4_++;
            }
            addEvent();
         });
         SocketConnection.send(CommandID.LEIYI_TRAIN_GET_STATUS);
      }
      
      private function addEvent() : void
      {
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         this._returnBtn.addEventListener(MouseEvent.CLICK,this.onReturn);
         var _loc1_:int = 0;
         while(_loc1_ < 6)
         {
            this._mainUI["btn_" + _loc1_].addEventListener(MouseEvent.CLICK,this.clickHandle);
            this.setArtNum(this._mainUI["num_" + _loc1_],this._current[_loc1_],this._total[_loc1_]);
            _loc1_++;
         }
      }
      
      private function clickHandle(param1:MouseEvent) : void
      {
         var index:int = 0;
         var e:MouseEvent = param1;
         index = 0;
         var catchTime:uint = 0;
         var petinfo:PetInfo = null;
         var ename:String = e.target.name;
         if(ename.indexOf("btn_") != -1)
         {
            index = int(uint(ename.split("_")[1]));
            if(this._current[index] >= this._total[index])
            {
               Alarm.show("你已经完成了该项特训！");
               return;
            }
            catchTime = uint(PetManager.defaultTime);
            petinfo = PetManager.getPetInfo(catchTime);
            if(Boolean(petinfo) && petinfo.id == 70)
            {
               EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,function(param1:PetFightEvent):void
               {
                  var _loc3_:FightOverInfo = null;
                  EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,arguments.callee);
                  _loc3_ = param1.dataObj["data"] as FightOverInfo;
                  LeiyiEnergyNewPanelController.show();
                  if(_loc3_.winnerID == MainManager.actorInfo.userID)
                  {
                     Alarm.show("恭喜你完成了" + _desList[index] + "特训！");
                  }
               });
               FightInviteManager.fightWithBoss("雷伊幻影",10000 + index);
            }
            return;
         }
      }
      
      private function setArtNum(param1:TextField, param2:uint, param3:uint) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.text = "已完成次数" + param2.toString() + "/" + param3.toString();
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         if(this._mainUI == null)
         {
            _loc1_ = new MCLoader(ClientConfig.getResPath("/appRes/2016/0122/LeyiTrainNewPanel.swf"),this,1,"正在打开雷伊体能训练...");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.setup);
            _loc1_.doLoad();
         }
         else
         {
            DisplayUtil.align(this,null,AlignType.TOP_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(this._mainUI);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
      
      private function onReturn(param1:MouseEvent) : void
      {
         this.destroy();
         LeiyiTrainController.showTrainPanel();
      }
      
      public function destroy() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onClose);
         this._returnBtn.removeEventListener(MouseEvent.CLICK,this.onReturn);
         var _loc1_:int = 0;
         while(_loc1_ < 6)
         {
            this._mainUI["btn_" + _loc1_].removeEventListener(MouseEvent.CLICK,this.clickHandle);
            _loc1_++;
         }
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeAllChild(this._mainUI);
            DisplayUtil.removeForParent(this._mainUI);
         }
         this._mainUI = null;
         this._closeBtn = null;
         this._returnBtn = null;
      }
   }
}

