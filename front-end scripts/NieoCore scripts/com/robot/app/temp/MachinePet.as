package com.robot.app.temp
{
   import com.robot.core.mode.ActionSpriteModel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MachinePet extends ActionSpriteModel
   {
      
      private static var oldStr:String;
      
      private var mc:MovieClip;
      
      private var array:Array = ["down","leftdown","left","leftup","up","rightup","right","rightdown"];
      
      private var posArray:Array = [];
      
      public var type:String;
      
      public function MachinePet()
      {
         super();
         this.loadUI();
         this.x = int(Math.random() * 524) + 235;
         this.y = int(Math.random() * 234) + 155;
      }
      
      public function get color() : String
      {
         return this.type;
      }
      
      private function loadUI() : void
      {
         ResourceManager.getResource("resource/pet/swf/143.swf",function(param1:DisplayObject):void
         {
            var _loc2_:MovieClip = param1 as MovieClip;
            addChild(_loc2_);
            _loc2_.gotoAndStop(array[Math.floor(Math.random() * array.length)]);
         },"pet");
      }
      
      override public function destroy() : void
      {
         super.destroy();
         DisplayUtil.removeForParent(this);
         this.mc = null;
      }
   }
}

