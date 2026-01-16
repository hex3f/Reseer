package com.robot.app.nono.featureApp
{
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   
   public class App_700005
   {
      
      public function App_700005(param1:uint)
      {
         super();
         SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,1);
      }
   }
}

