package com.robot.core.mode
{
   import com.robot.core.info.NonoInfo;
   import com.robot.core.info.UserInfo;
   
   public class PeopleModel extends BasePeoleModel
   {
      
      public function PeopleModel(param1:UserInfo)
      {
         var _loc2_:NonoInfo = null;
         super(param1);
         if(Boolean(param1.nonoState[1]))
         {
            _loc2_ = new NonoInfo();
            _loc2_.userID = param1.userID;
            _loc2_.color = param1.nonoColor;
            _loc2_.superStage = param1.vipStage;
            _loc2_.nick = param1.nonoNick;
            _loc2_.superNono = param1.superNono;
            showNono(_loc2_,param1.actionType);
         }
      }
   }
}

