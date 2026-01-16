package com.robot.core.aticon
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.SpecialXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   import gs.TweenLite;
   import gs.easing.Bounce;
   
   public class PeculiarAction
   {
      
      public function PeculiarAction()
      {
         super();
      }
      
      public function execute(param1:BasePeoleModel, param2:String, param3:Boolean = true) : void
      {
         var bodyMCArray:Array = null;
         var compose:MovieClip = null;
         var obj:BasePeoleModel = param1;
         var dir:String = param2;
         var isNet:Boolean = param3;
         var id:uint = 0;
         bodyMCArray = null;
         compose = null;
         var skeleton:EmptySkeletonStrategy = null;
         var num:uint = 0;
         var i:uint = 0;
         var mc:MovieClip = null;
         if(isNet)
         {
            SocketConnection.send(CommandID.DANCE_ACTION,10001,Direction.strToIndex(obj.direction));
         }
         else
         {
            id = SpecialXMLInfo.getSpecialID(obj.info.clothIDs);
            if(id > 0)
            {
               obj.stop();
               obj.specialAction(id);
               return;
            }
            bodyMCArray = [];
            obj.sprite.addEventListener(RobotEvent.WALK_START,function(param1:RobotEvent):void
            {
               var _loc3_:MovieClip = null;
               obj.sprite.removeEventListener(RobotEvent.WALK_START,arguments.callee);
               for each(_loc3_ in bodyMCArray)
               {
                  TweenLite.to(_loc3_,0.2,{
                     "alpha":1,
                     "scaleX":1,
                     "scaleY":1
                  });
               }
               TweenLite.to(compose,0.5,{
                  "y":-21.4,
                  "ease":Bounce.easeOut
               });
            });
            obj.stop();
            obj.direction = dir;
            skeleton = obj.skeleton as EmptySkeletonStrategy;
            compose = skeleton.getBodyMC();
            num = uint(compose.numChildren);
            i = 0;
            while(i < num)
            {
               mc = compose.getChildAt(i) as MovieClip;
               if(mc.name != "cloth" && mc.name != "color" && mc.name != "waist" && mc.name != "head" && mc.name != "decorator")
               {
                  bodyMCArray.push(mc);
                  TweenLite.to(mc,0.2,{
                     "alpha":0,
                     "scaleX":0,
                     "scaleY":0
                  });
               }
               i++;
            }
            TweenLite.to(compose,0.5,{
               "y":-8,
               "ease":Bounce.easeOut
            });
         }
      }
      
      public function keepDown(param1:EmptySkeletonStrategy) : void
      {
         var _loc2_:MovieClip = null;
         if(!param1)
         {
            return;
         }
         var _loc3_:MovieClip = param1.getBodyMC();
         var _loc4_:uint = uint(_loc3_.numChildren);
         var _loc5_:Number = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = _loc3_.getChildAt(_loc5_) as MovieClip;
            if(_loc2_.name != "cloth" && _loc2_.name != "color" && _loc2_.name != "waist" && _loc2_.name != "head" && _loc2_.name != "decorator")
            {
               TweenLite.to(_loc2_,0.2,{
                  "alpha":0,
                  "scaleX":0,
                  "scaleY":0
               });
            }
            _loc5_++;
         }
         TweenLite.to(_loc3_,0.5,{
            "y":-8,
            "ease":Bounce.easeOut
         });
      }
      
      public function keepUp(param1:EmptySkeletonStrategy, param2:Number) : void
      {
         var _loc3_:MovieClip = null;
         if(param1 == null)
         {
            return;
         }
         var _loc4_:MovieClip = param1.getBodyMC();
         var _loc5_:uint = uint(_loc4_.numChildren);
         var _loc6_:Number = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = _loc4_.getChildAt(_loc6_) as MovieClip;
            if(_loc3_.name != "cloth" && _loc3_.name != "color" && _loc3_.name != "waist" && _loc3_.name != "head" && _loc3_.name != "decorator")
            {
               TweenLite.to(_loc3_,0.2,{
                  "alpha":0,
                  "scaleX":0,
                  "scaleY":0
               });
            }
            _loc6_++;
         }
         TweenLite.to(_loc4_,0.2,{
            "y":param2,
            "ease":Bounce.easeOut
         });
         if(Boolean(param1.people))
         {
            (param1.people as BasePeoleModel).topIconY = param2 - 48.6;
         }
      }
      
      public function standUp(param1:EmptySkeletonStrategy) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = param1.getBodyMC();
         var _loc4_:uint = uint(_loc3_.numChildren);
         var _loc5_:Number = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = _loc3_.getChildAt(_loc5_) as MovieClip;
            if(_loc2_.name != "cloth" && _loc2_.name != "color" && _loc2_.name != "waist" && _loc2_.name != "head" && _loc2_.name != "decorator")
            {
               TweenLite.to(_loc2_,0.2,{
                  "alpha":1,
                  "scaleX":1,
                  "scaleY":1
               });
            }
            _loc5_++;
         }
         TweenLite.to(_loc3_,0.5,{
            "y":-21.4,
            "ease":Bounce.easeOut
         });
      }
   }
}

