package com.robot.app.mapProcess
{
   import com.robot.app.task.control.*;
   import com.robot.core.aimat.*;
   import com.robot.core.animate.*;
   import com.robot.core.event.*;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.*;
   import flash.display.MovieClip;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_322 extends BaseMapProcess
   {
      
      private var seerLamuMC:MovieClip;
      
      private var grapeMovie:MovieClip;
      
      private var grapeMC:MovieClip;
      
      private var daweiMC:MovieClip;
      
      public function MapProcess_322()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.grapeMovie = animatorLevel["grapeMovie"];
         this.grapeMC = conLevel["grapeMC"];
         this.daweiMC = animatorLevel["daweiMC"];
         this.daweiMC.visible = false;
         this.seerLamuMC = animatorLevel["seerLamuMC"];
         this.seerLamuMC.gotoAndStop(1);
         this.seerLamuMC.visible = false;
         if(TasksManager.getTaskStatus(95) == TasksManager.COMPLETE)
         {
            DisplayUtil.removeForParent(this.grapeMovie);
            DisplayUtil.removeForParent(this.grapeMC);
            DisplayUtil.removeForParent(this.daweiMC);
            DisplayUtil.removeForParent(this.seerLamuMC);
            DisplayUtil.removeForParent(animatorLevel["shipeMC"]);
            return;
         }
         if(TasksManager.getTaskStatus(95) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(95,this.taskStatus);
         }
      }
      
      override public function destroy() : void
      {
      }
      
      public function changeMap() : void
      {
         if(TasksManager.getTaskStatus(95) == TasksManager.COMPLETE)
         {
            MapManager.changeMap(323);
            return;
         }
         MapManager.changeLocalMap(323);
      }
      
      private function taskStatus(param1:Array) : void
      {
         var arr:Array = param1;
         if(!arr[0])
         {
            NpcDialog.show(NPC.SEER,["这里到底是哪里呀？那几尊雕像又是怎么回事？这里难道是精灵世界？快看！那个小胖子，脸上有红鼻子的家伙，它也是精灵吗？#10"],["啊哈！精灵胶囊出击吧！"],[function():void
            {
               MainManager.actorModel.visible = false;
               AnimateManager.playMcAnimate(grapeMovie,2,"mc2",function():void
               {
                  NpcDialog.show(NPC.WULIGULA,["不……不是吧！#3精灵胶囊在这里失……失控？我……我的妈呀！又是一个精灵吗？这个家伙怎么像长胡子的洋……洋葱头？#7这回就来看我的吧！"],["它们真的是精灵吗？"],[function():void
                  {
                     MainManager.actorModel.visible = true;
                     AnimateManager.playMcAnimate(grapeMovie,3,"mc3",function():void
                     {
                        NpcDialog.show(NPC.WULIGULA,["妖……妖怪！！！它把……把我的胶囊吃了……！哥哥……那家伙是妖怪！！！#3#3#3"],["好你个家伙！看我们不用头部射击打你！"],[function():void
                        {
                           TasksManager.complete(95,0,null,true);
                           AimatController.addEventListener(AimatEvent.PLAY_END,onShotGrape);
                        }]);
                     });
                  }]);
               });
            }]);
         }
         if(Boolean(arr[0]))
         {
            this.grapeMovie.gotoAndStop(3);
            AimatController.addEventListener(AimatEvent.PLAY_END,this.onShotGrape);
            this.daweiMC.visible = false;
         }
         if(Boolean(arr[1]))
         {
            DisplayUtil.removeForParent(this.grapeMC);
            DisplayUtil.removeForParent(this.grapeMovie);
            this.daweiMC.visible = true;
            if(!arr[2])
            {
               NpcDialog.show(NPC.LAMU,["凄凄凉凉……冷冷清清……我的主人啊！咦？那个不是大卫嘛！铁皮你要不去问问我们的大卫？那个穿梭的东西就是他发明的！他肯定会有办法的！"],["你们这里的人都顶着大红鼻子走路的吗？"],[function():void
               {
                  NpcDialog.show(NPC.DAWEI,["是缺少能源？缺少电量？问题到底出在哪里呢？#7哇哇哇哇！！！！哇！外星人？哇哇哇哇哇！！！！！那不是葡萄吗？"],["我们不是外星人……是赛尔！"],[function():void
                  {
                     TaskController_95.showTaskPanel(3);
                     EventManager.addEventListener("taskPanel_3_close",showTaskPanelComp_3);
                  }]);
               }]);
            }
         }
         if(Boolean(arr[5]) && !arr[6])
         {
            if(TaskController_95.get_kuangshi)
            {
               TaskController_95.showTaskPanel(5);
               EventManager.addEventListener("taskPanel_5_close",this.showTaskPanelComp_5);
            }
         }
      }
      
      private function onShotGrape(param1:AimatEvent) : void
      {
         var info:AimatInfo = null;
         var evt:AimatEvent = param1;
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onShotGrape);
         info = evt.info;
         if(info.userID != MainManager.actorID)
         {
            return;
         }
         if(this.grapeMC.hitTestPoint(info.endPos.x,info.endPos.y))
         {
            AnimateManager.playMcAnimate(this.grapeMovie,4,"mc4",function():void
            {
               NpcDialog.show(NPC.SEER,["如果推算没有错，这里应该就是黑色旋涡产生的原因所在！但是……为什么没有线索啊？#7先把这个胡子洋葱头带回赛尔号让博士看看吧……也许他会知道点什么！"],["事不宜迟！我们这就回赛尔号实验室！"],[function():void
               {
                  MapManager.changeMap(5);
                  TaskController_95.shot_grape_complete = true;
               }]);
            });
         }
         else
         {
            AimatController.addEventListener(AimatEvent.PLAY_END,this.onShotGrape);
         }
      }
      
      private function showTaskPanelComp_3(param1:DynamicEvent) : void
      {
         EventManager.removeEventListener("taskPanel_3_close",this.showTaskPanelComp_3);
         TasksManager.complete(95,2,null,true);
      }
      
      private function showTaskPanelComp_5(param1:DynamicEvent) : void
      {
         var url:String = null;
         var evt:DynamicEvent = param1;
         TaskController_95.get_kuangshi = false;
         EventManager.removeEventListener("taskPanel_5_close",this.showTaskPanelComp_5);
         url = "resource/bounsMovie/task_95_1.swf";
         AnimateManager.playFullScreenAnimate(url,function():void
         {
            TaskController_95.showTaskPanel(6);
            EventManager.addEventListener("taskPanel_6_close",showTaskPanelComp_6);
         });
      }
      
      private function showTaskPanelComp_6(param1:DynamicEvent) : void
      {
         var evt:DynamicEvent = param1;
         EventManager.removeEventListener("taskPanel_6_close",this.showTaskPanelComp_6);
         MainManager.actorModel.visible = false;
         this.seerLamuMC.visible = true;
         AnimateManager.playMcAnimate(this.seerLamuMC,0,"",function():void
         {
            NpcDialog.show(NPC.DAWEI,["哎呀！葡萄？菩提大伯呢？……大铁皮超人……"],["我好像隐约听到点声音？"],[function():void
            {
               MapManager.changeMap(5);
               TaskController_95.help_dawei_complete = true;
            }]);
         });
      }
   }
}

