package com.robot.app.petUpdate.updatePanel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.skillBtn.BlackSkillBtn;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class SingleSkillPanel extends Sprite
   {
      
      private var panel:MovieClip;
      
      private var iconMC:Sprite;
      
      private var skillBtn:BlackSkillBtn;
      
      private var okBtn:SimpleButton;
      
      public function SingleSkillPanel()
      {
         super();
         this.panel = UIManager.getMovieClip("ui_PetUpdateSkillPanel");
         this.iconMC = new Sprite();
         this.iconMC.x = 108;
         this.iconMC.y = 135;
         this.iconMC.scaleX = this.iconMC.scaleY = 1.5;
         this.panel.addChild(this.iconMC);
         this.okBtn = this.panel["okBtn"];
         this.okBtn.addEventListener(MouseEvent.CLICK,this.okHandler);
         addChild(this.panel);
      }
      
      public function setInfo(param1:uint, param2:uint, param3:Boolean = true) : void
      {
         var _loc4_:* = 0;
         DisplayUtil.removeAllChild(this.iconMC);
         if(param3)
         {
            _loc4_ = uint(PetManager.getPetInfo(param1).id);
            this.panel["name_txt"].text = PetXMLInfo.getName(_loc4_);
         }
         else
         {
            _loc4_ = uint(PetManager.curEndPetInfo.id);
            this.panel["name_txt"].text = PetXMLInfo.getName(_loc4_);
         }
         ResourceManager.getResource(ClientConfig.getPetSwfPath(_loc4_),this.onShowComplete,"pet");
         this.skillBtn = new BlackSkillBtn(param2);
         this.skillBtn.x = 175;
         this.skillBtn.y = 100;
         this.panel.addChild(this.skillBtn);
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
      
      private function okHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}

