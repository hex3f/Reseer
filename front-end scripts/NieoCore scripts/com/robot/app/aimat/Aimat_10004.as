package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10004 extends BaseAimat
   {
      
      private var speedPos:Point;
      
      private var ui:MovieClip;
      
      private var ui2:MovieClip;
      
      private var arr:Array = [];
      
      private var _speed:Number = 20;
      
      public function Aimat_10004()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         if(param1.speed > 0)
         {
            this._speed = param1.speed;
         }
         this.ui = AimatController.getResEffect(_info.id);
         this.ui.x = _info.startPos.x;
         this.ui.y = _info.startPos.y - this.ui.height - 6;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         this.ui.scaleX = _info.endPos.x > _info.startPos.x ? 1 : -1;
         MapManager.currentMap.depthLevel.addChild(this.ui);
         _info.startPos.x = this.ui.scaleX > 0 ? this.ui.x + this.ui.width + this._speed : this.ui.x - this.ui.width - this._speed;
         _info.startPos.y = this.ui.y;
         this.speedPos = GeomUtil.angleSpeed(_info.endPos,_info.startPos);
         this.speedPos.x *= this._speed;
         this.speedPos.y *= this._speed;
         this.ui.addFrameScript(this.ui.totalFrames - 1,this.onEnd);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.ui))
         {
            this.ui.addFrameScript(this.ui.totalFrames - 1,null);
            DisplayUtil.removeForParent(this.ui);
            this.ui = null;
         }
         this.speedPos = null;
         if(Boolean(this.ui2))
         {
            this.ui2.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            DisplayUtil.removeForParent(this.ui2);
            this.ui2 = null;
         }
         this.arr = null;
      }
      
      private function onEnd() : void
      {
         var _loc1_:MovieClip = null;
         this.ui.addFrameScript(this.ui.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
         var _loc2_:int = 0;
         while(_loc2_ < 5)
         {
            _loc1_ = AimatController.getResEffect(_info.id,"02");
            _loc1_.mouseEnabled = false;
            _loc1_.mouseChildren = false;
            _loc1_.scaleX = _loc1_.scaleY = Math.random();
            _loc1_.alpha = Math.random() + 0.3;
            _loc1_.x = _info.startPos.x;
            _loc1_.y = _info.startPos.y;
            this.arr.push(_loc1_);
            MapManager.currentMap.depthLevel.addChild(_loc1_);
            _loc2_++;
         }
         this.ui2 = AimatController.getResEffect(_info.id,"02");
         this.ui2.x = _info.startPos.x;
         this.ui2.y = _info.startPos.y;
         this.ui2.mouseEnabled = false;
         this.ui2.mouseChildren = false;
         MapManager.currentMap.depthLevel.addChild(this.ui2);
         this.ui2.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      private function onEnter(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IAimatSprite = null;
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         if(Math.abs(this.ui2.x - _info.endPos.x) < this._speed / 2 && Math.abs(this.ui2.y - _info.endPos.y) < this._speed / 2)
         {
            this.ui2.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            DisplayUtil.removeForParent(this.ui2);
            this.ui2 = null;
            _loc2_ = 0;
            while(_loc2_ < 5)
            {
               _loc4_ = this.arr[_loc2_];
               DisplayUtil.removeForParent(_loc4_);
               _loc4_ = null;
               _loc2_++;
            }
            this.arr = null;
            AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
            _loc3_ = MapManager.getObjectPoint(_info.endPos,[IAimatSprite]) as IAimatSprite;
            if(Boolean(_loc3_))
            {
               _loc3_.aimatState(_info);
            }
            return;
         }
         this.ui2.x += this.speedPos.x;
         this.ui2.y += this.speedPos.y;
         var _loc6_:int = 0;
         while(_loc6_ < 5)
         {
            _loc5_ = this.arr[_loc6_];
            _loc5_.x += this.speedPos.x + Math.random() * 6 - 3;
            _loc5_.y += this.speedPos.y + (Math.random() * 40 - 20);
            _loc6_++;
         }
      }
   }
}

