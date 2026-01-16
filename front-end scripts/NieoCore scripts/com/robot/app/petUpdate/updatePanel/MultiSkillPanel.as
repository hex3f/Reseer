package com.robot.app.petUpdate.updatePanel
{
   import com.robot.app.petUpdate.panel.SkillBtnController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.skillBtn.BlackSkillBtn;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.effect.ColorFilter;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MultiSkillPanel extends Sprite
   {
      
      private var panel:MovieClip;
      
      private var replaceBtn:SimpleButton;
      
      private var closeBtn:SimpleButton;
      
      private var skillBtns:Array;
      
      private var study:uint;
      
      private var drop:uint = 0;
      
      private var newSkillMC:BlackSkillBtn;
      
      private var _catchTime:uint;
      
      private var iconMC:Sprite;
      
      public function MultiSkillPanel()
      {
         super();
         this.panel = UIManager.getMovieClip("ui_PetUpdateMoreSkillPanel");
         addChild(this.panel);
         this.replaceBtn = this.panel["okBtn"];
         this.closeBtn = this.panel["closeBtn"];
         this.replaceBtn.addEventListener(MouseEvent.CLICK,this.replaceHandler);
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.closeHandler);
         SocketConnection.addCmdListener(CommandID.PET_STUDY_SKILL,this.onStudy);
         this.iconMC = new Sprite();
         this.iconMC.x = 104;
         this.iconMC.y = 150;
         this.panel.addChild(this.iconMC);
      }
      
      public function setInfo(param1:uint, param2:uint, param3:Boolean = true) : void
      {
         var petSkills:Array = null;
         var catchTime:uint = param1;
         var skillID:uint = param2;
         var isBag:Boolean = param3;
         petSkills = null;
         DisplayUtil.removeAllChild(this.iconMC);
         this._catchTime = catchTime;
         this.replaceBtn.mouseEnabled = false;
         this.replaceBtn.filters = [ColorFilter.setGrayscale()];
         DisplayUtil.removeForParent(this.newSkillMC);
         this.newSkillMC = new BlackSkillBtn(skillID);
         this.newSkillMC.x = 176;
         this.newSkillMC.y = 99;
         this.panel.addChild(this.newSkillMC);
         this.study = skillID;
         this.skillBtns = [];
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,function(param1:SocketEvent):void
         {
            var _loc4_:BlackSkillBtn = null;
            var _loc5_:SkillBtnController = null;
            var _loc3_:PetSkillInfo = null;
            _loc4_ = null;
            _loc5_ = null;
            SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,arguments.callee);
            var _loc6_:PetInfo = param1.data as PetInfo;
            petSkills = _loc6_.skillArray;
            var _loc7_:Number = 0;
            for each(_loc3_ in petSkills)
            {
               _loc4_ = new BlackSkillBtn(_loc3_.id,_loc3_.pp);
               _loc5_ = new SkillBtnController(_loc4_,_loc3_);
               _loc4_.x = 39 + _loc7_ % 2 * (_loc4_.width + 8);
               _loc4_.y = 190 + Math.floor(_loc7_ / 2) * (_loc4_.height + 3);
               _loc5_.addEventListener(SkillBtnController.CLICK,onClickSkillBtn);
               skillBtns.push(_loc5_);
               panel.addChild(_loc4_);
               _loc7_++;
            }
            ResourceManager.getResource(ClientConfig.getPetSwfPath(_loc6_.id),onShowComplete,"pet");
         });
         SocketConnection.send(CommandID.GET_PET_INFO,this._catchTime);
      }
      
      private function onClickSkillBtn(param1:Event) : void
      {
         var _loc2_:SkillBtnController = null;
         var _loc3_:SkillBtnController = param1.currentTarget as SkillBtnController;
         this.drop = _loc3_.skillID;
         for each(_loc2_ in this.skillBtns)
         {
            _loc2_.checkIsOwner(_loc3_);
         }
         this.replaceBtn.mouseEnabled = true;
         this.replaceBtn.filters = [];
      }
      
      private function replaceHandler(param1:MouseEvent) : void
      {
         var okBtn:SimpleButton = null;
         var closeBtn:SimpleButton = null;
         var alarm:MovieClip = null;
         var event:MouseEvent = param1;
         alarm = null;
         alarm = UIManager.getMovieClip("ui_MultiSkillAlarm");
         var newMC:BlackSkillBtn = new BlackSkillBtn(this.study);
         var oldMC:BlackSkillBtn = new BlackSkillBtn(this.drop);
         newMC.x = 39;
         oldMC.x = 195;
         newMC.y = oldMC.y = 102;
         alarm.addChild(newMC);
         alarm.addChild(oldMC);
         DisplayUtil.align(alarm,null,AlignType.MIDDLE_CENTER);
         okBtn = alarm["okBtn"];
         closeBtn = alarm["closeBtn"];
         okBtn.addEventListener(MouseEvent.CLICK,function():void
         {
            DisplayUtil.removeForParent(alarm);
            SocketConnection.send(CommandID.PET_STUDY_SKILL,_catchTime,1,1,drop,study);
         });
         closeBtn.addEventListener(MouseEvent.CLICK,function():void
         {
            DisplayUtil.removeForParent(alarm);
         });
         MainManager.getStage().addChild(alarm);
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function onStudy(param1:SocketEvent) : void
      {
         var sprite:Sprite = null;
         var event:SocketEvent = param1;
         PetManager.upDate();
         sprite = Alarm.show("恭喜你，宠物学习技能成功！",function():void
         {
            dispatchEvent(new Event(Event.CLOSE));
         });
         MainManager.getStage().addChild(sprite);
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         var _showMc:MovieClip = null;
         var o:DisplayObject = param1;
         _showMc = null;
         _showMc = o as MovieClip;
         if(Boolean(_showMc))
         {
            _showMc.gotoAndStop("rightdown");
            _showMc.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            this.iconMC.addChild(_showMc);
         }
      }
   }
}

