package com.robot.app.im.ui
{
   import com.robot.app.im.talk.TalkPanelManager;
   import com.robot.app.teacher.TeacherSysManager;
   import com.robot.app.user.UserInfoController;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.RelationManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class IMListItem extends Sprite
   {
      
      protected var _info:UserInfo;
      
      private var _mainUI:Sprite;
      
      protected var _txt:TextField;
      
      protected var _headMc:Sprite;
      
      protected var _faceMc:Sprite;
      
      protected var _nonoMc:Sprite;
      
      protected var _talkMc:SimpleButton;
      
      protected var _clickBtn:SimpleButton;
      
      protected var _bgMc:Sprite;
      
      private var _teacherIcon:Sprite;
      
      private var _studentIcon:Sprite;
      
      private var _isMyStudent:Boolean;
      
      private var _isMyTeacher:Boolean;
      
      public function IMListItem()
      {
         super();
         buttonMode = true;
         this._mainUI = this.getMainUI();
         this._txt = this._mainUI["txt"];
         this._headMc = this._mainUI["headMc"];
         this._faceMc = this._mainUI["faceMc"];
         this._talkMc = this._mainUI["talkMc"];
         this._clickBtn = this._mainUI["clickBtn"];
         this._bgMc = this._mainUI["bgMc"];
         this._nonoMc = this._mainUI["nonoMc"];
         this._mainUI.mouseEnabled = false;
         this._txt.mouseEnabled = false;
         this._headMc.mouseEnabled = false;
         this._headMc.visible = false;
         this._nonoMc.visible = false;
         this._talkMc.visible = false;
         this._faceMc.mouseEnabled = false;
         this._faceMc.visible = false;
         this._bgMc.mouseEnabled = false;
         this._bgMc.visible = false;
         addChild(this._mainUI);
         this._teacherIcon = UIManager.getSprite("FriendList_Teacher_Icon");
         this._studentIcon = UIManager.getSprite("FriendList_Student_Icon");
      }
      
      protected function getMainUI() : Sprite
      {
         return UIManager.getSprite("IMListItem");
      }
      
      private function addTeacherIcon(param1:Boolean = false) : void
      {
         this._teacherIcon.x = 114;
         this._teacherIcon.y = 1.5;
         this._mainUI.addChild(this._teacherIcon);
         this._isMyTeacher = param1;
         if(param1)
         {
            ToolTipManager.add(this._teacherIcon,"我的教官");
         }
         else
         {
            ToolTipManager.add(this._teacherIcon,"申请他做我的教官");
            this._teacherIcon.visible = false;
            this._teacherIcon.buttonMode = true;
            this._teacherIcon.addEventListener(MouseEvent.CLICK,this.clickTeacherIcon);
         }
      }
      
      private function addStudentIcon(param1:Boolean = false) : void
      {
         this._studentIcon.x = 114;
         this._studentIcon.y = 1.5;
         this._mainUI.addChild(this._studentIcon);
         this._isMyStudent = param1;
         if(param1)
         {
            ToolTipManager.add(this._studentIcon,"我的学员");
         }
         else
         {
            ToolTipManager.add(this._studentIcon,"申请他做我的学员");
            this._studentIcon.visible = false;
            this._studentIcon.buttonMode = true;
            this._studentIcon.addEventListener(MouseEvent.CLICK,this.clickStudentIcon);
         }
      }
      
      private function clickTeacherIcon(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.teacherID == 0)
         {
            TeacherSysManager.addTeacher(this._info.userID);
         }
         else
         {
            Alarm.show("你已经有一个教官了，要珍惜哦！");
         }
      }
      
      private function clickStudentIcon(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.studentID == 0)
         {
            TeacherSysManager.addStudent(this._info.userID);
         }
         else
         {
            Alarm.show("你已经有一个学员了，要专心哦");
         }
      }
      
      public function set info(param1:UserInfo) : void
      {
         this._info = param1;
         name = this._info.userID.toString();
         if(Boolean(this._info.serverID))
         {
            this._headMc.visible = true;
            DisplayUtil.FillColor(this._headMc,this._info.color);
            this._txt.textColor = 0;
            if(Boolean(this._info.vip))
            {
               this._nonoMc.visible = true;
            }
         }
         else
         {
            this._headMc.visible = false;
            this._nonoMc.visible = false;
            this._txt.textColor = 10066329;
         }
         if(RelationManager.isFriend(this._info.userID))
         {
            this._talkMc.visible = true;
            this._talkMc.addEventListener(MouseEvent.CLICK,this.onTalk);
         }
         this._faceMc.visible = true;
         this._clickBtn.addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         if(!this._info.hasSimpleInfo)
         {
            this._txt.text = this._info.userID.toString();
            return;
         }
         this._txt.text = this._info.nick;
         this.check();
      }
      
      public function get info() : UserInfo
      {
         return this._info;
      }
      
      public function clear() : void
      {
         this._info = null;
         this._txt.text = "";
         this._headMc.visible = false;
         this._talkMc.visible = false;
         this._faceMc.visible = false;
         this._nonoMc.visible = false;
         this._clickBtn.removeEventListener(MouseEvent.CLICK,this.onClick);
         removeEventListener(MouseEvent.ROLL_OVER,this.onOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this._talkMc.removeEventListener(MouseEvent.CLICK,this.onTalk);
         DisplayUtil.removeForParent(this._teacherIcon);
         DisplayUtil.removeForParent(this._studentIcon);
         this._teacherIcon.buttonMode = false;
         this._studentIcon.buttonMode = false;
         this._teacherIcon.removeEventListener(MouseEvent.CLICK,this.clickTeacherIcon);
         this._studentIcon.removeEventListener(MouseEvent.CLICK,this.clickStudentIcon);
         ToolTipManager.remove(this._teacherIcon);
         ToolTipManager.remove(this._studentIcon);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         UserInfoController.show(this._info.userID);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this._bgMc.visible = true;
         if(Boolean(this._teacherIcon))
         {
            this._teacherIcon.visible = true;
         }
         if(Boolean(this._studentIcon))
         {
            this._studentIcon.visible = true;
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this._bgMc.visible = false;
         if(Boolean(this._teacherIcon) && this._isMyTeacher == false)
         {
            this._teacherIcon.visible = false;
         }
         if(Boolean(this._studentIcon) && this._isMyStudent == false)
         {
            this._studentIcon.visible = false;
         }
      }
      
      private function check() : void
      {
         if(TasksManager.getTaskStatus(201) == TasksManager.COMPLETE)
         {
            if(MainManager.actorInfo.studentID != 0)
            {
               if(this._info.userID == MainManager.actorInfo.studentID)
               {
                  this.addStudentIcon(true);
               }
               return;
            }
            if(!this._info.isCanBeTeacher && this._info.teacherID == 0)
            {
               this.addStudentIcon();
            }
         }
         else
         {
            if(MainManager.actorInfo.teacherID != 0)
            {
               if(this._info.userID == MainManager.actorInfo.teacherID)
               {
                  this.addTeacherIcon(true);
               }
               return;
            }
            if(Boolean(this._info.isCanBeTeacher) && this._info.studentID == 0)
            {
               this.addTeacherIcon();
            }
         }
      }
      
      protected function onTalk(param1:MouseEvent) : void
      {
         TalkPanelManager.showTalkPanel(this._info.userID);
      }
   }
}

