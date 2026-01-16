package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.pioneerTaskList.HOTestTask;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class DoctorGuideDialog
   {
      
      private static var npcMc:String;
      
      private static var npcImgMC:MovieClip;
      
      private static var grassMC:SimpleButton;
      
      private static var fireMC:SimpleButton;
      
      private static var waterMC:SimpleButton;
      
      private static var xita:MovieClip;
      
      private static var spriteMC:MovieClip;
      
      private static var count:uint = 0;
      
      private static var dialogStrArr:Array = ["清淡的自然营养剂？？从来没听说过的样子哎……那是什么呀？","赫尔卡星你们还没有去过吗？地下广场的精灵树可以结出精灵们喜欢的果实哦。","( ⊙ o ⊙ ) 哇~第一次听说哎！！可是，地下广场我也去过的呀，为什么从来没看到过树上结果子？","呵呵，因为那棵树结果子是需要特定条件的呀。派特博士，请让我来试试看吧！","真是个懂事谦虚的好孩子，快去试试看吧。精灵们的状态不容乐观呢，我留在实验室检测它们的状况，防止意外发上。"];
      
      private static var dialogNpcArr:Array = [NpcTipDialog.SEER,NpcTipDialog.DIEN,NpcTipDialog.SEER,NpcTipDialog.DIEN,NpcTipDialog.DOCTOR];
      
      private static var dialogCount:uint = 0;
      
      public function DoctorGuideDialog()
      {
         super();
      }
      
      public static function showDialog(param1:uint = 0) : void
      {
         npcMc = NpcTipDialog.DOCTOR;
         var _loc2_:uint = uint(TasksManager.taskList[2]);
         if(_loc2_ == 1 && !GuideTaskModel.bTaskDoctor)
         {
            NpcTipDialog.show("我是派特博士，研究精灵是我的工作。这里就是精灵实验室，这里很多神奇的设备都和精灵有关。还有关于精灵的问题？快打开精灵手册，了解下精灵的介绍吧！",okFun,npcMc,-80);
         }
         else if(_loc2_ == 1 && GuideTaskModel.bReadMonBook)
         {
            NpcTipDialog.show("看完精灵手册，对赛尔精灵有了更多了解了吧！\n    现在你可以去机械室，和茜茜切磋一下。如果能战胜她的精灵，说明你真的开始了解你的新伙伴了。",null,npcMc,-80);
         }
         spriteMC = MapManager.currentMap.topLevel.getChildByName("spriteMC") as MovieClip;
      }
      
      private static function loadHoTestTask() : void
      {
         var _loc1_:HOTestTask = new HOTestTask();
      }
      
      public static function okFun() : void
      {
         GuideTaskModel.bTaskDoctor = true;
         GuideTaskModel.setTaskBuf("8");
         GuideTaskModel.statusAry[2] = 1;
         (MapManager.currentMap.controlLevel["glowMC"] as MovieClip).visible = true;
         (MapManager.currentMap.controlLevel["glowMC"] as MovieClip).play();
      }
      
      public static function showChooseMonster() : void
      {
         var dragMc:SimpleButton = null;
         var exitBtn:SimpleButton = null;
         npcImgMC = UIManager.getMovieClip("chooseMon");
         LevelManager.topLevel.addChild(npcImgMC);
         DisplayUtil.align(npcImgMC,null,AlignType.MIDDLE_CENTER,new Point(0,-80));
         LevelManager.closeMouseEvent();
         dragMc = npcImgMC["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            npcImgMC.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            npcImgMC.stopDrag();
         });
         exitBtn = npcImgMC["exitBtn"];
         exitBtn.addEventListener(MouseEvent.CLICK,onRemove);
         grassMC = npcImgMC["grassMC"];
         grassMC.addEventListener(MouseEvent.CLICK,selGrass);
         fireMC = npcImgMC["fireMC"];
         fireMC.addEventListener(MouseEvent.CLICK,selFireMC);
         waterMC = npcImgMC["waterMC"];
         waterMC.addEventListener(MouseEvent.CLICK,selWaterMC);
      }
      
      private static function onRemove(param1:MouseEvent) : void
      {
         removeDialog();
      }
      
      public static function removeDialog() : void
      {
         DisplayUtil.removeForParent(npcImgMC);
         LevelManager.openMouseEvent();
      }
      
      private static function selGrass(param1:MouseEvent) : void
      {
         SelectPet.checkStatus(1);
      }
      
      private static function selFireMC(param1:MouseEvent) : void
      {
         SelectPet.checkStatus(2);
      }
      
      private static function selWaterMC(param1:MouseEvent) : void
      {
         SelectPet.checkStatus(3);
      }
   }
}

