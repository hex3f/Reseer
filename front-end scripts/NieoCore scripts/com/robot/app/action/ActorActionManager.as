package com.robot.app.action
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.config.xml.SuitXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.AssetsManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.TransformSkeleton;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class ActorActionManager
   {
      
      private static var subMenu:MovieClip;
      
      private static var actionBtn:SimpleButton;
      
      private static var tranBtn:SimpleButton;
      
      private static var unTranBtn:SimpleButton;
      
      public static var isTransforming:Boolean = false;
      
      setup();
      
      public function ActorActionManager()
      {
         super();
      }
      
      private static function setup() : void
      {
         EventManager.addEventListener(RobotEvent.TRANSFORM_START,onTranStart);
         EventManager.addEventListener(RobotEvent.TRANSFORM_OVER,onTranOver);
      }
      
      private static function onTranStart(param1:RobotEvent) : void
      {
         isTransforming = true;
      }
      
      private static function onTranOver(param1:RobotEvent) : void
      {
         isTransforming = false;
         if(Boolean(tranBtn))
         {
            tranBtn.visible = !MainManager.actorModel.isTransform;
            unTranBtn.visible = MainManager.actorModel.isTransform;
         }
      }
      
      public static function showMenu(param1:DisplayObject) : void
      {
         var _loc2_:Point = null;
         _loc2_ = null;
         if(!subMenu)
         {
            subMenu = AssetsManager.getMovieClip("lib_transform_menu");
            _loc2_ = param1.localToGlobal(new Point());
            subMenu.x = _loc2_.x;
            subMenu.y = _loc2_.y - subMenu.height - 5;
            actionBtn = subMenu["actionBtn"];
            tranBtn = subMenu["tranBtn"];
            unTranBtn = subMenu["unTranBtn"];
            ToolTipManager.add(actionBtn,"蹲下");
            ToolTipManager.add(tranBtn,"变形");
            ToolTipManager.add(unTranBtn,"恢复变形");
            actionBtn.addEventListener(MouseEvent.CLICK,actionHandler);
            tranBtn.addEventListener(MouseEvent.CLICK,tranHandler);
            unTranBtn.addEventListener(MouseEvent.CLICK,unTranHandler);
         }
         tranBtn.visible = !MainManager.actorModel.isTransform;
         unTranBtn.visible = MainManager.actorModel.isTransform;
         LevelManager.topLevel.addChild(subMenu);
         MainManager.getStage().addEventListener(MouseEvent.CLICK,onStageClick);
      }
      
      private static function onStageClick(param1:MouseEvent) : void
      {
         MainManager.getStage().removeEventListener(MouseEvent.CLICK,onStageClick);
         if(!subMenu.hitTestPoint(param1.stageX,param1.stageY))
         {
            DisplayUtil.removeForParent(subMenu);
         }
      }
      
      private static function actionHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(subMenu);
         if(Boolean(MainManager.actorModel.pet))
         {
            if(PetXMLInfo.isFlyPet(MainManager.actorModel.pet.info.petID))
            {
               Alarm.show("注意！你现在骑着宠物，不能进行赛尔变形！");
               return;
            }
            if(PetXMLInfo.isRidePet(MainManager.actorModel.pet.info.petID))
            {
               Alarm.show("注意！你现在骑着宠物，不需要进行赛尔变形！");
               return;
            }
         }
         if(MainManager.actorInfo.actionType == 1)
         {
            Alarm.show("注意！不要采用危险操作，取消飞行模式才能进行赛尔变形。");
            return;
         }
         if(isTransforming)
         {
            return;
         }
         if(!MainManager.actorModel.isTransform)
         {
            MainManager.actorModel.peculiarAction(MainManager.actorModel.direction);
         }
      }
      
      private static function tranHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(subMenu);
         if(Boolean(MainManager.actorModel.pet))
         {
            if(PetXMLInfo.isFlyPet(MainManager.actorModel.pet.info.petID))
            {
               Alarm.show("注意！你现在骑着宠物，不能进行赛尔变形！");
               return;
            }
            if(PetXMLInfo.isRidePet(MainManager.actorModel.pet.info.petID))
            {
               Alarm.show("注意！你现在骑着宠物，不需要进行赛尔变形！");
               return;
            }
         }
         if(MainManager.actorInfo.actionType == 1)
         {
            Alarm.show("注意！不要采用危险操作，取消飞行模式才能进行赛尔变形。");
            return;
         }
         if(isTransforming)
         {
            return;
         }
         var _loc2_:uint = uint(SuitXMLInfo.getSuitID(MainManager.actorInfo.clothIDs));
         SocketConnection.send(CommandID.PEOPLE_TRANSFROM,_loc2_);
      }
      
      private static function unTranHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(subMenu);
         if(isTransforming)
         {
            return;
         }
         if(MainManager.actorModel.skeleton is TransformSkeleton)
         {
            (MainManager.actorModel.skeleton as TransformSkeleton).untransform();
         }
      }
   }
}

