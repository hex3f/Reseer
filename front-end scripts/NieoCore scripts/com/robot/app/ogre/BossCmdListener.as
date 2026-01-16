package com.robot.app.ogre
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class BossCmdListener extends BaseBeanController
   {
      
      public function BossCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.MAP_BOSS,this.onBossList);
         finish();
      }
      
      private function onBossList(param1:SocketEvent) : void
      {
         var i:int = 0;
         var e:SocketEvent = param1;
         var id:uint = 0;
         var region:uint = 0;
         var hp:uint = 0;
         var pos:uint = 0;
         var data:ByteArray = e.data as ByteArray;
         var len:uint = data.readUnsignedInt();
         i = 0;
         while(i < len)
         {
            id = data.readUnsignedInt();
            if(id == 70)
            {
               setTimeout(function():void
               {
                  EventManager.dispatchEvent(new Event("LY_OUT"));
               },1000);
            }
            region = data.readUnsignedInt();
            hp = data.readUnsignedInt();
            pos = data.readUnsignedInt();
            if(pos == 200)
            {
               BossController.remove(region);
            }
            else
            {
               BossController.add(id,region,hp,pos);
            }
            i++;
         }
      }
   }
}

