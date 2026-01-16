package com.robot.app.npc.npcClass
{
   import com.robot.core.event.NpcEvent;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class NpcClass_5 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      public function NpcClass_5(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onNpcClick);
      }
      
      private function onNpcClick(param1:NpcEvent) : void
      {
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.destroy();
            this._curNpcModel = null;
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

