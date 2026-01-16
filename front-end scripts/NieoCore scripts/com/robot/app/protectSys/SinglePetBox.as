package com.robot.app.protectSys
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.utils.Direction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.manager.ResourceManager;
   
   public class SinglePetBox extends MLoadPane
   {
      
      public static const UP:uint = 0;
      
      public static const DOWN:uint = 1;
      
      public static const LEFT:uint = 2;
      
      private var mc:MovieClip;
      
      private var type:uint;
      
      public function SinglePetBox(param1:uint, param2:uint = 0)
      {
         super(null,MLoadPane.FIT_HEIGHT);
         this.isMask = false;
         setSizeWH(90,80);
         this.type = param2;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),this.onLoad,"pet");
      }
      
      public function get dirType() : uint
      {
         return this.type;
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         var o:DisplayObject = param1;
         this.mc = o as MovieClip;
         if(Boolean(this.mc))
         {
            this.setIcon(this.mc);
            this.mc.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var _loc3_:MovieClip = mc.getChildAt(0) as MovieClip;
               if(Boolean(_loc3_))
               {
                  mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  _loc3_.gotoAndStop(1);
               }
            });
            if(this.type == UP)
            {
               this.mc.gotoAndStop(Direction.UP);
            }
            else if(this.type == DOWN)
            {
               this.mc.gotoAndStop(Direction.DOWN);
            }
            else if(this.type == LEFT)
            {
               this.mc.gotoAndStop(Direction.LEFT);
            }
         }
      }
   }
}

