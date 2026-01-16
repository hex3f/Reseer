package com.robot.core.aticon
{
   import com.robot.core.CommandID;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.SuitXMLInfo;
   import com.robot.core.controller.SaveUserInfo;
   import com.robot.core.event.UserEvent;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.item.DoodleInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.TransformSkeleton;
   import flash.utils.ByteArray;
   import org.taomee.manager.EventManager;
   
   public class FigureAction
   {
      
      public function FigureAction()
      {
         super();
      }
      
      public function changeCloth(param1:BasePeoleModel, param2:Array, param3:Boolean = true) : void
      {
         var _loc4_:PeopleItemInfo = null;
         var _loc5_:* = 0;
         var _loc6_:ByteArray = null;
         var _loc7_:Array = null;
         if(param3)
         {
            _loc5_ = param2.length;
            _loc6_ = new ByteArray();
            for each(_loc4_ in param2)
            {
               _loc6_.writeUnsignedInt(_loc4_.id);
            }
            SocketConnection.send(CommandID.CHANGE_CLOTH,_loc5_,_loc6_);
         }
         else
         {
            param1.skeleton.takeOffCloth();
            param1.skeleton.changeCloth(param2);
            param1.info.clothes = param2;
            if(param1.skeleton is TransformSkeleton)
            {
               if(SuitXMLInfo.getSuitID(param1.info.clothIDs) == 0)
               {
                  TransformSkeleton(param1.skeleton).untransform();
               }
               else if(!SuitXMLInfo.getIsTransform(SuitXMLInfo.getSuitID(param1.info.clothIDs)))
               {
                  TransformSkeleton(param1.skeleton).untransform();
               }
            }
            SaveUserInfo.saveSo();
            _loc7_ = [];
            for each(_loc4_ in param2)
            {
               _loc7_.push(_loc4_.id);
            }
            if(param1.info.userID == MainManager.actorID)
            {
               AimatController.setClothType(_loc7_);
            }
            param1.speed = ItemXMLInfo.getSpeed(_loc7_);
            EventManager.dispatchEvent(new UserEvent(UserEvent.INFO_CHANGE,param1.info));
            param1.showClothLight();
         }
      }
      
      public function changeNickName(param1:BasePeoleModel, param2:String, param3:Boolean = true) : void
      {
         var _loc4_:ByteArray = null;
         if(param3)
         {
            _loc4_ = new ByteArray();
            _loc4_.writeUTFBytes(param2);
            _loc4_.length = 16;
            SocketConnection.send(CommandID.CHANG_NICK_NAME,_loc4_);
         }
         else
         {
            param1.info.nick = param2;
            EventManager.dispatchEvent(new UserEvent(UserEvent.INFO_CHANGE,param1.info));
         }
      }
      
      public function changeColor(param1:BasePeoleModel, param2:uint, param3:Boolean = true) : void
      {
         if(param3)
         {
            SocketConnection.send(CommandID.CHANGE_COLOR,param2);
         }
         else
         {
            param1.skeleton.changeColor(param2);
            param1.info.color = param2;
            param1.info.texture = 0;
            SaveUserInfo.saveSo();
         }
      }
      
      public function changeDoodle(param1:BasePeoleModel, param2:DoodleInfo, param3:Boolean = true) : void
      {
         if(param2.texture == 0)
         {
            this.changeColor(param1,param2.color);
            return;
         }
         if(param3)
         {
            SocketConnection.send(CommandID.CHANGE_DOODLE,param2.id);
         }
         else
         {
            param1.info.texture = param2.texture;
            param1.info.color = param2.color;
            param1.info.coins = param2.coins;
            if(param2.URL == "" || param2.URL == null)
            {
               return;
            }
            param1.skeleton.changeDoodle(param2.URL);
            param1.skeleton.changeColor(param2.color,false);
            SaveUserInfo.saveSo();
         }
      }
   }
}

