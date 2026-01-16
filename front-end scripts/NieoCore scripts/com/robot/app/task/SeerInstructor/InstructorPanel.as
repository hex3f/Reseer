package com.robot.app.task.SeerInstructor
{
   import com.robot.app.task.taskUtils.baseAction.GetTaskBuf;
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.core.info.task.novice.NoviceBufInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import org.taomee.effect.ColorFilter;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class InstructorPanel
   {
      
      private var mainPanel:MovieClip;
      
      private var taskBuf:NoviceBufInfo;
      
      private var tip:MovieClip;
      
      private var mainWb:MovieClip;
      
      private var buf:String;
      
      public function InstructorPanel()
      {
         super();
      }
      
      public function show() : void
      {
         var filter:ColorMatrixFilter = null;
         var filters:Array = null;
         var closeBtn:SimpleButton = null;
         var dragMc:SimpleButton = null;
         if(TasksManager.taskList[200] != 1)
         {
            return;
         }
         this.mainPanel = TaskUIManage.getMovieClip("instructorPanel",201);
         filter = ColorFilter.setGrayscale();
         filters = new Array();
         filters.push(filter);
         (this.mainPanel["waste1"] as MovieClip).filters = filters;
         (this.mainPanel["waste2"] as MovieClip).filters = filters;
         (this.mainPanel["waste3"] as MovieClip).filters = filters;
         (this.mainPanel["waste4"] as MovieClip).filters = filters;
         (this.mainPanel["waste5"] as MovieClip).filters = filters;
         (this.mainPanel["wb"] as MovieClip).filters = filters;
         this.mainWb = this.mainPanel["mainWb"];
         this.mainWb.addEventListener(MouseEvent.MOUSE_OVER,this.overHander);
         this.mainWb.addEventListener(MouseEvent.MOUSE_OUT,this.outHander);
         this.tip = TaskUIManage.getMovieClip("tipPanel",201);
         this.tip.x = 35;
         this.tip.y = 60;
         DisplayUtil.align(this.mainPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.topLevel.addChild(this.mainPanel);
         closeBtn = this.mainPanel["closeBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,this.closeHander);
         dragMc = this.mainPanel["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            mainPanel.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            mainPanel.stopDrag();
         });
         GetTaskBuf.taskId = 201;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,this.onGetWasteOk);
      }
      
      private function overHander(param1:MouseEvent) : void
      {
         if(this.contains(this.buf,"1") && this.contains(this.buf,"2") && this.contains(this.buf,"3") && this.contains(this.buf,"4") && this.contains(this.buf,"5") && this.contains(this.buf,"6"))
         {
            (this.tip["tipTxt"] as TextField).text = "恭喜你完成考核，快回办公室找我吧";
         }
         else
         {
            (this.tip["tipTxt"] as TextField).text = "海盗胡乱破坏环境，赶快回收污染品！2楼还有考验等着你";
         }
         this.mainPanel.addChild(this.tip);
      }
      
      private function outHander(param1:MouseEvent) : void
      {
         if(this.mainPanel.contains(this.tip))
         {
            this.mainPanel.removeChild(this.tip);
         }
      }
      
      private function closeHander(param1:MouseEvent) : void
      {
         LevelManager.topLevel.removeChild(this.mainPanel);
         LevelManager.openMouseEvent();
      }
      
      private function onGetWasteOk(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,this.onGetWasteOk);
         this.buf = GetTaskBuf.buf;
         if(this.contains(this.buf,"1") && this.contains(this.buf,"2") && this.contains(this.buf,"3") && this.contains(this.buf,"4") && this.contains(this.buf,"5") && this.contains(this.buf,"6"))
         {
            (this.tip["tipTxt"] as TextField).text = "恭喜你完成考核，快回办公室找我吧";
            this.mainWb.mouseEnabled = false;
            this.mainPanel.addChild(this.tip);
         }
         if(this.buf.indexOf("1") != -1)
         {
            (this.mainPanel["waste1"] as MovieClip).filters = [];
         }
         if(this.buf.indexOf("2") != -1)
         {
            (this.mainPanel["waste2"] as MovieClip).filters = [];
         }
         if(this.buf.indexOf("3") != -1)
         {
            (this.mainPanel["waste3"] as MovieClip).filters = [];
         }
         if(this.buf.indexOf("4") != -1)
         {
            (this.mainPanel["waste4"] as MovieClip).filters = [];
         }
         if(this.buf.indexOf("5") != -1)
         {
            (this.mainPanel["waste5"] as MovieClip).filters = [];
         }
         if(this.buf.indexOf("6") != -1)
         {
            (this.mainPanel["wb"] as MovieClip).filters = [];
         }
      }
      
      private function contains(param1:String, param2:String) : Boolean
      {
         if(param1.indexOf(param2) != -1)
         {
            return true;
         }
         return false;
      }
   }
}

