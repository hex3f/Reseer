package com.robot.core.skeleton
{
   import com.robot.core.mode.ISkeletonSprite;
   
   public interface IPeopleAdditiveSystem
   {
      
      function set people(param1:ISkeletonSprite) : void;
      
      function get people() : ISkeletonSprite;
      
      function destroy() : void;
   }
}

