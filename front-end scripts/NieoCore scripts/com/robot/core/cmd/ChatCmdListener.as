package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.ChatEvent;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.info.ChatInfo;
   import com.robot.core.manager.MessageManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class ChatCmdListener
   {
      
      public function ChatCmdListener()
      {
         super();
      }
      
      public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.CHAT,this.onChat);
      }
      
      private function onChat(param1:SocketEvent) : void
      {
         var _loc2_:ChatInfo = param1.data as ChatInfo;
         if(_loc2_.toID == 0)
         {
            UserManager.dispatchAction(_loc2_.senderID,PeopleActionEvent.CHAT,_loc2_.msg);
            MessageManager.dispatchEvent(new ChatEvent(ChatEvent.CHAT_COM,_loc2_));
         }
         else
         {
            MessageManager.addChatInfo(_loc2_);
         }
      }
   }
}

