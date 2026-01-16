package com.robot.core.ui.skillBtn
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   [Event(name="click",type="flash.events.MouseEvent")]
   public class NormalSkillBtn extends Sprite
   {
      
      private var _mc:MovieClip;
      
      public var skillID:uint;
      
      private var currentPP:int;
      
      public function NormalSkillBtn(param1:uint = 0, param2:int = -1)
      {
         super();
         this._mc = this.getMC();
         this._mc.gotoAndStop(1);
         this._mc["iconMC"].gotoAndStop(1);
         this._mc["nameTxt"].mouseEnabled = false;
         this._mc["migTxt"].mouseEnabled = false;
         this._mc["ppTxt"].mouseEnabled = false;
         addChild(this._mc);
         this.init(param1,param2);
      }
      
      protected function getMC() : MovieClip
      {
         return UIManager.getMovieClip("ui_Normal_PetSkilBtn");
      }
      
      public function init(param1:uint, param2:int = -1) : void
      {
         this.skillID = param1;
         this.currentPP = param2;
         if(this.skillID <= 0)
         {
            return;
         }
         this._mc["nameTxt"].text = SkillXMLInfo.getName(param1);
         var _loc3_:String = SkillXMLInfo.getTypeEN(param1);
         this._mc["iconMC"].gotoAndStop(_loc3_);
         this._mc["migTxt"].text = "威力:" + SkillXMLInfo.getDamage(param1).toString();
         var _loc4_:String = SkillXMLInfo.getPP(param1).toString();
         if(param2 == -1)
         {
            this._mc["ppTxt"].text = "PP:" + _loc4_ + "/" + _loc4_;
         }
         else
         {
            this._mc["ppTxt"].text = "PP:" + param2.toString() + "/" + _loc4_;
         }
         addEventListener(MouseEvent.ROLL_OVER,this.overHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.outHandler);
      }
      
      public function get mc() : Sprite
      {
         return this._mc;
      }
      
      public function setSelect(param1:Boolean) : void
      {
         if(param1)
         {
            this._mc.gotoAndStop(2);
         }
         else
         {
            this._mc.gotoAndStop(1);
         }
      }
      
      public function clear() : void
      {
         this._mc["iconMC"].gotoAndStop(1);
         this._mc["nameTxt"].text = "";
         this._mc["migTxt"].text = "";
         this._mc["ppTxt"].text = "";
         removeEventListener(MouseEvent.ROLL_OVER,this.overHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.outHandler);
      }
      
      public function destroy() : void
      {
         this.clear();
         DisplayUtil.removeForParent(this);
         this._mc = null;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         SkillInfoTip.show(this.skillID);
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         SkillInfoTip.hide();
      }
   }
}

