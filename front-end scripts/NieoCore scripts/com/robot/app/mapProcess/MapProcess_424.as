package com.robot.app.mapProcess
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MapProcess_424 extends BaseMapProcess
   {
      
      private var _amc01:MovieClip;
      
      private var _goToBtn:MovieClip;
      
      public function MapProcess_424()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._amc01 = this.conLevel["amc01"];
         this._amc01.gotoAndStop(1);
         this._amc01.buttonMode = true;
         this._amc01.addEventListener(MouseEvent.CLICK,this.onChangeHandler);
         this._goToBtn = this.conLevel["goToBtn"];
         this._goToBtn.buttonMode = true;
         this._goToBtn.addEventListener(MouseEvent.CLICK,this.onGoToBtnHandler);
         this.conLevel["sptAnimationMc"].visible = false;
      }
      
      public function onGo_425() : void
      {
         if(MainManager.actorInfo.superNono)
         {
            if(!MainManager.actorModel.nono)
            {
               NpcDialog.show(NPC.SUPERNONO,["#7咦？你怎么不带上你的超能NoNo？要知道没有它的保护进入时空罗盘可是很危险的！"],["我这就召唤我的超能NoNo"],[function():void
               {
               }]);
            }
            else
            {
               MapManager.changeMap(425);
            }
         }
      }
      
      private function onGoToBtnHandler(param1:MouseEvent) : void
      {
         MapManager.changeMap(427);
      }
      
      public function onChangeHandler(param1:MouseEvent) : void
      {
         if(this._amc01.currentFrame == this._amc01.totalFrames)
         {
            this._amc01.gotoAndStop(1);
         }
         else
         {
            this._amc01.nextFrame();
         }
      }
      
      override public function destroy() : void
      {
         this._amc01.removeEventListener(MouseEvent.CLICK,this.onChangeHandler);
         this._goToBtn.removeEventListener(MouseEvent.CLICK,this.onGoToBtnHandler);
      }
   }
}

