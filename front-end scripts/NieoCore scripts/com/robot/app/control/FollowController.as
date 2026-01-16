package com.robot.app.control
{
   import com.robot.app.task.taskUtils.taskDialog.DynamicNpcTipDialog;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import flash.events.Event;
   
   public class FollowController
   {
      
      public function FollowController()
      {
         super();
      }
      
      public static function followSuperNono(param1:String, param2:String, param3:Function = null, param4:Function = null) : void
      {
         var withoutNonoStr:String = param1;
         var noSuperStr:String = param2;
         var func:Function = param3;
         var superFunc:Function = param4;
         var info:NonoInfo = null;
         if(Boolean(MainManager.actorModel.nono))
         {
            if(func != null)
            {
               func();
            }
            info = NonoManager.info;
            if(info.superNono)
            {
               if(superFunc != null)
               {
                  superFunc();
               }
            }
            else
            {
               DynamicNpcTipDialog.show(noSuperStr,function():void
               {
                  var r:VipSession = new VipSession();
                  r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
                  {
                  });
                  r.getSession();
               },NpcTipDialog.NONO);
            }
         }
         else
         {
            NpcTipDialog.show(withoutNonoStr,null,NpcTipDialog.NONO);
         }
      }
      
      public static function followPet(param1:Function = null, param2:Function = null, param3:Array = null, param4:String = null, param5:Function = null, param6:Function = null) : void
      {
         var _loc7_:* = 0;
         var _loc8_:Number = 0;
         if(Boolean(MainManager.actorModel.pet))
         {
            _loc7_ = uint(MainManager.actorModel.pet.info.petID);
            if(param3 == null && param4 == null && param4 == "")
            {
               if(param2 != null)
               {
                  param2();
               }
            }
            else if(param3 != null)
            {
               for each(_loc8_ in param3)
               {
                  if(_loc8_ == _loc7_)
                  {
                     if(param5 != null)
                     {
                        param5();
                     }
                     return;
                  }
               }
               if(param6 != null)
               {
                  param6();
               }
            }
            else
            {
               if(param4 == null || param4 == "")
               {
                  return;
               }
               if(PetXMLInfo.getTypeCN(_loc7_) == param4)
               {
                  if(param5 != null)
                  {
                     param5();
                  }
               }
               else if(param6 != null)
               {
                  param6();
               }
            }
         }
         else if(param1 != null)
         {
            param1();
         }
      }
   }
}

