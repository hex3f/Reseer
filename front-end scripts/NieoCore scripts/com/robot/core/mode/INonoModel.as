package com.robot.core.mode
{
   import com.robot.core.info.NonoInfo;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface INonoModel
   {
      
      function set people(param1:ActionSpriteModel) : void;
      
      function get people() : ActionSpriteModel;
      
      function get info() : NonoInfo;
      
      function set direction(param1:String) : void;
      
      function get centerPoint() : Point;
      
      function get hitRect() : Rectangle;
      
      function set visible(param1:Boolean) : void;
      
      function startPlay() : void;
      
      function stopPlay() : void;
      
      function destroy() : void;
   }
}

