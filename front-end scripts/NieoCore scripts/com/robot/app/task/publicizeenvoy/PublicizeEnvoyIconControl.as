package com.robot.app.task.publicizeenvoy
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.BitUtil;
   
   public class PublicizeEnvoyIconControl
   {
      
      private static var _iconMc:MovieClip;
      
      private static var _lightMC:MovieClip;
      
      private static var _isAlarm:Boolean = false;
      
      public function PublicizeEnvoyIconControl()
      {
         super();
      }
      
      public static function canGetTaskReword(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:Boolean = Boolean(BitUtil.getBit(param2,0));
         var _loc4_:Boolean = Boolean(BitUtil.getBit(param2,1));
         var _loc5_:Boolean = Boolean(BitUtil.getBit(param2,2));
         if(param1 >= 2 && param1 <= 5)
         {
            if(!_loc3_)
            {
               return true;
            }
         }
         else if(param1 >= 5 && param1 <= 10)
         {
            if(!_loc3_ || !_loc4_)
            {
               return true;
            }
         }
         else if(param1 >= 10)
         {
            if(!_loc3_ || !_loc4_ || !_loc5_)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function check() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:uint = uint(MainManager.actorInfo.newInviteeCnt);
         var _loc3_:uint = uint(MainManager.actorInfo.freshManBonus);
         var _loc4_:Boolean = Boolean(BitUtil.getBit(_loc3_,1));
         var _loc5_:Boolean = Boolean(BitUtil.getBit(_loc3_,2));
         var _loc6_:Boolean = Boolean(BitUtil.getBit(_loc3_,3));
         if(MainManager.actorInfo.dsFlag == 1)
         {
            if(_loc4_ && _loc5_ && _loc6_)
            {
               return;
            }
            addIcon();
            _loc1_ = canGetTaskReword(_loc2_,_loc3_);
            if(_loc1_)
            {
               lightIcon();
            }
         }
      }
      
      public static function addIcon() : void
      {
         _iconMc = TaskIconManager.getIcon("PublicizeEnloy_ICON") as MovieClip;
         ToolTipManager.add(_iconMc,"赛尔召集令");
         TaskIconManager.addIcon(_iconMc);
         _lightMC = _iconMc["lightMC"];
         _lightMC.visible = false;
         _iconMc.buttonMode = true;
         _iconMc.visible = false;
         _iconMc.addEventListener(MouseEvent.CLICK,onClickHandler);
      }
      
      private static function onClickHandler(param1:MouseEvent) : void
      {
         PublicizeEnvoyController.show(_isAlarm);
         _isAlarm = false;
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(_iconMc);
      }
      
      public static function lightIcon() : void
      {
         if(Boolean(_lightMC))
         {
            _lightMC.visible = true;
            _isAlarm = true;
         }
      }
   }
}

