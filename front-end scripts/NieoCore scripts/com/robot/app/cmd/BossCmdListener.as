package com.robot.app.cmd
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.task.BossMonsterInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   import org.taomee.events.SocketEvent;
   
   public class BossCmdListener extends BaseBeanController
   {
      
      public function BossCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_BOSS_MONSTER,this.onGetBossMonster);
         finish();
      }
      
      private function showAwards(param1:BossMonsterInfo) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         for each(_loc2_ in param1.monBallList)
         {
            _loc3_ = uint(_loc2_["itemCnt"]);
            _loc4_ = uint(_loc2_["itemID"]);
            if(_loc4_ == 100096 || _loc4_ == 100097 || _loc4_ == 100098 || _loc4_ == 100099)
            {
               LevelManager.tipLevel.addChild(Alarm.show("<font color=\'#FF0000\'>闪光勇士</font>套装已经放入了你的储存箱！"));
               break;
            }
            if(_loc4_ == 100333)
            {
               LevelManager.tipLevel.addChild(Alarm.show(" 你的实力得到了肯定，这<font color=\'#FF0000\'>试炼勋章</font>送给你，作为你实力的证明。"));
               break;
            }
            _loc5_ = ItemXMLInfo.getName(_loc4_);
            if(_loc4_ == 1)
            {
               MainManager.actorInfo.coins += _loc3_;
            }
            if(_loc4_ < 10)
            {
               if(param1.bonusID == 5065 || param1.bonusID == 5066)
               {
                  if(_loc3_ == 100)
                  {
                     _loc6_ = "看来这样的难度还难不倒你，后面的精灵会更加厉害，这<font color=\'#FF0000\'>" + _loc3_ + "</font>个" + _loc5_ + "是你的奖励。";
                  }
                  else if(_loc3_ == 200)
                  {
                     _loc6_ = "你确实具备了很强大的实力，给你<font color=\'#FF0000\'>" + _loc3_ + "</font>个" + _loc5_ + "做为奖励。";
                  }
                  else
                  {
                     _loc6_ = "你成功挑战了30关，奖励你<font color=\'#FF0000\'>" + _loc3_ + "</font>个" + _loc5_ + "。";
                  }
               }
               else
               {
                  _loc6_ = "恭喜你得到了<font color=\'#FF0000\'>" + _loc3_ + "</font>个" + _loc5_;
               }
               LevelManager.tipLevel.addChild(Alarm.show(_loc6_));
            }
            else
            {
               _loc6_ = _loc3_ + "个<font color=\'#FF0000\'>" + _loc5_ + "</font>已经放入了你的储存箱！";
               LevelManager.tipLevel.addChild(ItemInBagAlert.show(_loc4_,_loc6_));
            }
         }
      }
      
      private function onGetBossMonster(param1:SocketEvent) : void
      {
         var info:BossMonsterInfo = null;
         var e:SocketEvent = param1;
         info = null;
         if(AutomaticFightManager.isStart)
         {
            return;
         }
         info = e.data as BossMonsterInfo;
         if(info.bonusID == 5065 || info.bonusID == 5066)
         {
            this.showAwards(info);
            return;
         }
         this.showAwards(info);
         if(info.petID == 0)
         {
            return;
         }
         if(PetManager.length >= 6)
         {
            PetManager.addStorage(info.petID,info.captureTm);
            PetInStorageAlert.show(info.petID,"恭喜你获得了<font color=\'#00CC00\'>" + PetXMLInfo.getName(info.petID) + "</font>，你可以在基地仓库里找到");
            return;
         }
         PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
         {
            PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
            PetInBagAlert.show(info.petID,"恭喜你获得了<font color=\'#00CC00\'>" + PetXMLInfo.getName(info.petID) + "</font>，你可以点击右下方的精灵按钮来查看");
         });
         PetManager.setIn(info.captureTm,1);
      }
   }
}

