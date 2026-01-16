package com.robot.core.aticon
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimat;
   import com.robot.core.aimat.ThrowController;
   import com.robot.core.aimat.ThrowPropsController;
   import com.robot.core.config.xml.AimatXMLInfo;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.ISprite;
   import com.robot.core.utils.Direction;
   import flash.geom.Point;
   import org.taomee.utils.GeomUtil;
   import org.taomee.utils.Utils;
   
   public class AimatAction
   {
      
      private static const PATH:String = "com.robot.app.aimat.Aimat_";
      
      public function AimatAction()
      {
         super();
      }
      
      public static function execute(param1:uint, param2:uint, param3:uint, param4:ISprite, param5:Point) : void
      {
         var _loc6_:Class = null;
         var _loc7_:Point = null;
         var _loc8_:IAimat = null;
         var _loc9_:AimatInfo = null;
         if(param1 != 0)
         {
            if(param1 == 600001)
            {
               new ThrowController(param1,param3,param4,param5);
            }
            else
            {
               new ThrowPropsController(param1,param3,param4,param5);
            }
            return;
         }
         var _loc10_:uint = AimatXMLInfo.getTypeId(param2);
         if(_loc10_ == 0)
         {
            _loc6_ = Utils.getClass(PATH + param2.toString());
         }
         else
         {
            _loc6_ = Utils.getClass(PATH + _loc10_);
         }
         if(Boolean(_loc6_))
         {
            _loc7_ = param4.pos.clone();
            _loc7_.y -= 40;
            param4.direction = Direction.angleToStr(GeomUtil.pointAngle(_loc7_,param5));
            _loc8_ = new _loc6_();
            _loc9_ = new AimatInfo(param2,param3,_loc7_,param5);
            AimatController.dispatchEvent(AimatEvent.PLAY_START,_loc9_);
            _loc8_.execute(_loc9_);
         }
      }
      
      public static function execute2(param1:uint, param2:uint, param3:Point, param4:Point) : void
      {
         var _loc5_:IAimat = null;
         var _loc6_:AimatInfo = null;
         var _loc7_:Class = Utils.getClass(PATH + param1.toString());
         if(Boolean(_loc7_))
         {
            _loc5_ = new _loc7_();
            _loc6_ = new AimatInfo(param1,param2,param3,param4);
            AimatController.dispatchEvent(AimatEvent.PLAY_START,_loc6_);
            _loc5_.execute(_loc6_);
         }
      }
   }
}

