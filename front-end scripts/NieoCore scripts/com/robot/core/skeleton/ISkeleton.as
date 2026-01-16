package com.robot.core.skeleton
{
   import com.robot.core.info.UserInfo;
   import com.robot.core.mode.BasePeoleModel;
   import flash.display.MovieClip;
   
   public interface ISkeleton extends IPeopleAdditiveSystem
   {
      
      function getSkeletonMC() : MovieClip;
      
      function getBodyMC() : MovieClip;
      
      function set info(param1:UserInfo) : void;
      
      function play() : void;
      
      function stop() : void;
      
      function changeDirection(param1:String) : void;
      
      function changeCloth(param1:Array) : void;
      
      function takeOffCloth() : void;
      
      function changeColor(param1:uint, param2:Boolean = true) : void;
      
      function changeDoodle(param1:String) : void;
      
      function specialAction(param1:BasePeoleModel, param2:int) : void;
   }
}

