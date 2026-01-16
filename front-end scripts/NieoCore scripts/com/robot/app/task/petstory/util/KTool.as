package com.robot.app.task.petstory.util
{
   import com.robot.core.CommandID;
   import com.robot.core.info.nono.OpenSupperNonoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.PetModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Answer;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class KTool
   {
      
      private static var pet:PetModel;
      
      private static var adjustObj:DisplayObject;
      
      private static var dragObjList:Array;
      
      private static var dragBtnList:Array;
      
      private static const SHOW_VIRTUALITEM_ARR:Array = [1400073];
      
      private static var _type:Array = [];
      
      public function KTool()
      {
         super();
      }
      
      public static function hideMC(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = param1[_loc4_];
            _loc3_.visible = param2;
            _loc4_++;
         }
      }
      
      public static function enableMC(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:InteractiveObject = null;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = param1[_loc4_];
            _loc3_.mouseEnabled = param2;
            if(_loc3_ is Sprite)
            {
               (_loc3_ as Sprite).mouseChildren = param2;
            }
            _loc4_++;
         }
      }
      
      public static function setButtonMode(param1:*, param2:Boolean) : void
      {
         if(null != param1 && Boolean(param1.hasOwnProperty("buttonMode")))
         {
            param1["buttonMode"] = param2;
         }
      }
      
      public static function setAlignMid(param1:DisplayObject, param2:Number, param3:Number) : void
      {
         param1.x = (960 - param2) / 2;
         param1.y = (560 - param3) / 2;
      }
      
      public static function setPanelMid(param1:DisplayObject) : void
      {
         param1.x = int(960 - param1.width) / 2;
         param1.y = int(560 - param1.height) / 2;
      }
      
      public static function initBenonoBtn(param1:*) : void
      {
         if(param1 is MovieClip)
         {
            if(Boolean(MainManager.actorInfo.viped))
            {
               param1.gotoAndStop(2);
            }
            else
            {
               param1.gotoAndStop(1);
            }
         }
         param1.addEventListener(MouseEvent.CLICK,beNono);
      }
      
      private static function beNono(param1:Event) : void
      {
         Answer.show("确认花费50金豆购买超能Nono吗？",okHandler);
      }
      
      private static function okHandler() : void
      {
         SocketConnection.addCmdListener(CommandID.OPEN_SUPER_NONO,onOpenFinish);
         SocketConnection.send(CommandID.OPEN_SUPER_NONO);
      }
      
      private static function onOpenFinish(param1:Object) : void
      {
         SocketConnection.removeCmdListener(CommandID.OPEN_SUPER_NONO,onOpenFinish);
         var _loc2_:OpenSupperNonoInfo = param1.data as OpenSupperNonoInfo;
         if(_loc2_.success == 0)
         {
            Alarm.show("开通成功");
         }
         else
         {
            Alarm.show("开通失败");
         }
      }
      
      public static function destroyBenonoBtn(param1:*) : void
      {
         param1.removeEventListener(MouseEvent.CLICK,beNono);
      }
      
      public static function getBit(param1:uint, param2:uint) : uint
      {
         return param1 >> param2 - 1 & 1;
      }
      
      public static function showScore(param1:MovieClip, param2:uint, param3:uint = 0, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc11_:Array = null;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:Number = NaN;
         if(param1 == null)
         {
            return;
         }
         var _loc9_:uint = 0;
         var _loc10_:uint = param3 * 10;
         _loc11_ = param2.toString().split("").reverse();
         var _loc12_:uint = _loc11_.length;
         _loc9_ = 0;
         while(param1["num_" + _loc9_] != null)
         {
            param1["num_" + _loc9_].gotoAndStop(1 + _loc10_);
            param1["num_" + _loc9_].visible = param4;
            _loc9_++;
         }
         _loc9_ = 0;
         while(_loc9_ < _loc12_)
         {
            if(_loc11_[_loc9_] != undefined)
            {
               if(Boolean(param1["num_" + _loc9_]))
               {
                  param1["num_" + _loc9_].visible = true;
                  param1["num_" + _loc9_].gotoAndStop(uint(_loc11_[_loc9_]) + 1 + _loc10_);
               }
            }
            _loc9_++;
         }
         if(!param4 && param5)
         {
            _loc6_ = Math.ceil((param1.getChildAt(0) as MovieClip).width);
            _loc7_ = _loc6_ * param1.numChildren;
            _loc8_ = (_loc7_ - _loc12_ * _loc6_) / 2;
            _loc9_ = 0;
            while(_loc9_ < _loc12_)
            {
               if(_loc11_[_loc9_] != undefined)
               {
                  if(Boolean(param1["num_" + _loc9_]))
                  {
                     (param1["num_" + _loc9_] as MovieClip).x = _loc8_ + (_loc12_ - _loc9_ - 1) * (_loc6_ + 2);
                  }
               }
               _loc9_++;
            }
         }
      }
   }
}

