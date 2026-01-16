package com.robot.core.mode
{
   import com.robot.core.skeleton.ISkeleton;
   import flash.display.Sprite;
   
   public interface ISkeletonSprite
   {
      
      function set direction(param1:String) : void;
      
      function get direction() : String;
      
      function changeCloth(param1:Array, param2:Boolean = true) : void;
      
      function changeColor(param1:uint, param2:Boolean = true) : void;
      
      function specialAction(param1:uint) : void;
      
      function get sprite() : Sprite;
      
      function get skeleton() : ISkeleton;
      
      function play() : void;
      
      function stop() : void;
      
      function clearOldSkeleton() : void;
   }
}

