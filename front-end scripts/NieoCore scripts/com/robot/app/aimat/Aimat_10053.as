package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10053 extends BaseAimat
   {
      
      private var speedPos:Point;
      
      private var ui:MovieClip;
      
      private var ui2:MovieClip;
      
      private var _speed:Number = 36;
      
      private var _sound:Sound;
      
      private var _sounds:SoundChannel;
      
      private var _soundt:SoundTransform = new SoundTransform(0.5);
      
      public function Aimat_10053()
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
         this.ui = AimatController.getResState(_info.id);
         this.ui.x = _info.startPos.x;
         this.ui.y = _info.startPos.y;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         MapManager.currentMap.depthLevel.addChild(this.ui);
         this.speedPos = GeomUtil.angleSpeed(_info.endPos,_info.startPos);
         this.ui.addFrameScript(this.ui.totalFrames - 1,this.onEnter);
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
            this.onEnd();
         }
      }
      
      private function onEnter() : void
      {
         var _loc1_:DisplayObject = null;
         this.ui.addFrameScript(this.ui.totalFrames - 1,null);
         AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
         this.ui2 = AimatController.getResState(_info.id,"_1");
         this.ui2.x = _info.endPos.x;
         this.ui2.y = _info.endPos.y;
         this.ui2.mouseEnabled = false;
         this.ui2.mouseChildren = false;
         this.ui2.addFrameScript(this.ui2.totalFrames - 1,this.onEnd);
         MapManager.currentMap.depthLevel.addChild(this.ui2);
         var _loc2_:Array = MapManager.getObjectsPointRect(_info.endPos,30,[IAimatSprite]);
         for each(_loc1_ in _loc2_)
         {
            if(_loc1_ is IAimatSprite)
            {
               IAimatSprite(_loc1_).aimatState(_info);
            }
         }
      }
      
      private function onEnd() : void
      {
         this.ui2.addFrameScript(this.ui2.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui2);
         this.ui2 = null;
      }
   }
}

