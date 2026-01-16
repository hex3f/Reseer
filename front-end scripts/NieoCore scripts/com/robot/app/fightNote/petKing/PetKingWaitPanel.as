package com.robot.app.fightNote.petKing
{
   import com.robot.core.CommandID;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.pet.petWar.PetWarController;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.manager.DragManager;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetKingWaitPanel
   {
      
      private static var selectPanel:MovieClip;
      
      private static var waitPanel:MovieClip;
      
      private static var singleBtn:SimpleButton;
      
      private static var multiBtn:SimpleButton;
      
      private static var _petWarPanel:Sprite;
      
      initHandler();
      
      public function PetKingWaitPanel()
      {
         super();
      }
      
      private static function initHandler() : void
      {
         EventManager.addEventListener(RobotEvent.CLOSE_FIGHT_WAIT,closeWait);
      }
      
      private static function closeWait(param1:RobotEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,onMapSwitch);
         DisplayUtil.removeForParent(waitPanel,false);
         LevelManager.openMouseEvent();
      }
      
      private static function showWaitPanel() : void
      {
         var dragBtn:SimpleButton = null;
         var waitCloseBtn:SimpleButton = null;
         if(!waitPanel)
         {
            waitPanel = UIManager.getMovieClip("FightWait_mc");
            dragBtn = waitPanel["dragBtn"];
            dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,function():void
            {
               waitPanel.startDrag();
            });
            dragBtn.addEventListener(MouseEvent.MOUSE_UP,function():void
            {
               waitPanel.stopDrag();
            });
            waitCloseBtn = waitPanel["closeBtn"];
            waitCloseBtn.addEventListener(MouseEvent.CLICK,closeWaitPanel);
         }
      }
      
      public static function show() : void
      {
         var closeBtn:SimpleButton = null;
         var dragBtn2:SimpleButton = null;
         if(!waitPanel || !selectPanel)
         {
            showWaitPanel();
            selectPanel = MapLibManager.getMovieClip("ui_pet_king_panel");
            singleBtn = selectPanel["singleBtn"];
            multiBtn = selectPanel["multiBtn"];
            closeBtn = selectPanel["closeBtn"];
            closeBtn.addEventListener(MouseEvent.CLICK,closeSelect);
            singleBtn.addEventListener(MouseEvent.CLICK,selectModeHandler);
            multiBtn.addEventListener(MouseEvent.CLICK,selectModeHandler);
            dragBtn2 = selectPanel["dragBtn"];
            dragBtn2.addEventListener(MouseEvent.MOUSE_DOWN,function():void
            {
               selectPanel.startDrag();
            });
            dragBtn2.addEventListener(MouseEvent.MOUSE_UP,function():void
            {
               selectPanel.stopDrag();
            });
         }
         DisplayUtil.align(selectPanel,null,AlignType.MIDDLE_CENTER);
         DisplayUtil.align(waitPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(selectPanel);
      }
      
      public static function showPetWar() : void
      {
         if(!_petWarPanel)
         {
            _petWarPanel = MapLibManager.getMovieClip("ui_pet_metee_panel");
            _petWarPanel["startBtn"].addEventListener(MouseEvent.CLICK,onStartHandler);
            _petWarPanel["closeBtn"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               DisplayUtil.removeForParent(_petWarPanel);
               DragManager.remove(_petWarPanel["dragBtn"]);
            });
            DragManager.add(_petWarPanel["dragBtn"],_petWarPanel);
            LevelManager.appLevel.addChild(_petWarPanel);
            DisplayUtil.align(_petWarPanel,null,AlignType.MIDDLE_CENTER);
         }
         else
         {
            DragManager.add(_petWarPanel["dragBtn"],_petWarPanel);
            LevelManager.appLevel.addChild(_petWarPanel);
            DisplayUtil.align(_petWarPanel,null,AlignType.MIDDLE_CENTER);
         }
      }
      
      private static function onStartHandler(param1:MouseEvent) : void
      {
         LevelManager.closeMouseEvent();
         showWait();
         PetWarController.start(close);
      }
      
      private static function closeSelect(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(selectPanel,false);
      }
      
      public static function close() : void
      {
         DisplayUtil.removeForParent(waitPanel,false);
      }
      
      public static function closeWaitPanel(param1:MouseEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,onMapSwitch);
         DisplayUtil.removeForParent(waitPanel,false);
         SocketConnection.send(CommandID.INVITE_FIGHT_CANCEL);
         LevelManager.openMouseEvent();
      }
      
      private static function onMapSwitch(param1:MapEvent) : void
      {
         closeWaitPanel(null);
      }
      
      private static function selectModeHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:SimpleButton = param1.currentTarget as SimpleButton;
         if(_loc3_ == singleBtn)
         {
            _loc2_ = 5;
            PetFightModel.mode = PetFightModel.SINGLE_MODE;
         }
         else
         {
            _loc2_ = 6;
            PetFightModel.mode = PetFightModel.MULTI_MODE;
         }
         PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
         SocketConnection.send(CommandID.PET_KING_JOIN,_loc2_,0);
         closeSelect(null);
         showWait();
      }
      
      private static function showWait() : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onMapSwitch);
         showWaitPanel();
         DisplayUtil.align(waitPanel,null,AlignType.MIDDLE_CENTER);
         waitPanel["myNameTxt"].text = MainManager.actorInfo.nick;
         waitPanel["otherNameTxt"].text = "";
         LevelManager.topLevel.addChild(waitPanel);
         LevelManager.closeMouseEvent();
      }
   }
}

