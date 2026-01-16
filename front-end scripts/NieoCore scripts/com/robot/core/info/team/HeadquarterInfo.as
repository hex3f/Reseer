package com.robot.core.info.team
{
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.utils.SolidType;
   
   public class HeadquarterInfo extends FitmentInfo
   {
      
      public function HeadquarterInfo()
      {
         super();
      }
      
      override public function set id(param1:uint) : void
      {
         _id = param1;
         if(_id >= 900001 && _id <= 900100)
         {
            type = SolidType.FRAME;
         }
         else if(_id >= 900101 && _id <= 900300)
         {
            type = SolidType.WAP;
         }
         else if(_id >= 900301 && _id <= 900500)
         {
            type = SolidType.FLO;
         }
         else if(_id >= 900501 && _id <= 900800)
         {
            type = SolidType.PUT;
         }
         else if(_id >= 900801 && _id <= 901000)
         {
            type = SolidType.HANG;
         }
         if(_id >= 900951 && _id <= 901000)
         {
            isFixed = true;
         }
         else
         {
            isFixed = false;
         }
      }
   }
}

