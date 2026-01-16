package com.robot.app.petUpdate.updatePanel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.update.UpdatePropInfo;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gs.TweenLite;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class UpdateLevelPanel extends Sprite
   {
      
      private var levelPanel:MovieClip;
      
      private var iconMC:Sprite;
      
      private var btn:SimpleButton;
      
      private var isEvolution:Boolean;
      
      private var oldPetMC:MovieClip;
      
      private var evoPetMC:MovieClip;
      
      private var arrowArray:Array = [];
      
      private var txtArray:Array = [];
      
      private var txtArray2:Array = [];
      
      private var effectMC:MovieClip;
      
      public function UpdateLevelPanel()
      {
         super();
         this.levelPanel = UIManager.getMovieClip("ui_PetUpdateLevelPanel");
         this.iconMC = new Sprite();
         this.iconMC.x = 105;
         this.iconMC.y = 215;
         this.iconMC.scaleX = this.iconMC.scaleY = 1.5;
         this.levelPanel.addChild(this.iconMC);
         this.btn = this.levelPanel["okBtn"];
         this.btn.addEventListener(MouseEvent.CLICK,this.clickHandler);
         addChild(this.levelPanel);
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.clearArrow();
         this.txtArray = [];
         this.txtArray2 = [];
         this.arrowArray = [];
         DisplayUtil.removeForParent(this);
         DisplayUtil.removeForParent(this.effectMC);
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this,true);
         this.btn.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         this.levelPanel = null;
         this.iconMC = null;
         this.btn = null;
         this.oldPetMC = null;
         this.evoPetMC = null;
         this.effectMC = null;
      }
      
      public function setInfo(param1:UpdatePropInfo, param2:PetInfo) : void
      {
         this.clearArrow();
         this.txtArray.push(this.levelPanel["level_txt"],this.levelPanel["hp_txt"],this.levelPanel["a_txt"],this.levelPanel["d_txt"],this.levelPanel["sa_txt"],this.levelPanel["sd_txt"],this.levelPanel["sp_txt"]);
         this.txtArray2.push(this.levelPanel["level_txt2"],this.levelPanel["hp_txt2"],this.levelPanel["a_txt2"],this.levelPanel["d_txt2"],this.levelPanel["sa_txt2"],this.levelPanel["sd_txt2"],this.levelPanel["sp_txt2"]);
         this.levelPanel["name_txt"].text = PetXMLInfo.getName(param2.id);
         this.levelPanel["exp_info_txt"].htmlText = "赛尔精灵获得经验：<font color=\'#ff0000\'>" + (param1.exp - param2.exp) + "\r</font>成功升级到了<font color=\'#ff0000\'>" + param1.level + "</font>级";
         var _loc3_:Array = [param2.level,param2.maxHp,param2.attack,param2.defence,param2.s_a,param2.s_d,param2.speed];
         var _loc4_:Array = [param1.level,param1.maxHp,param1.attack,param1.defence,param1.sa,param1.sd,param1.sp];
         this.isEvolution = param2.id < param1.id;
         this.showInfo(_loc3_,_loc4_);
         if(this.isEvolution)
         {
            ResourceManager.getResource(ClientConfig.getPetSwfPath(param2.id),this.onLoadOld,"pet");
         }
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1.id),this.onLevelComplete,"pet");
      }
      
      private function showInfo(param1:Array, param2:Array) : void
      {
         var _loc4_:TextField = null;
         var _loc3_:Number = 0;
         _loc4_ = null;
         var _loc5_:TextField = null;
         var _loc6_:int = 0;
         var _loc7_:MovieClip = null;
         var _loc8_:Number = 0;
         for each(_loc3_ in param1)
         {
            _loc4_ = this.txtArray[_loc8_];
            _loc5_ = this.txtArray2[_loc8_];
            _loc6_ = param2[_loc8_] - param1[_loc8_];
            _loc4_.text = "+" + _loc6_;
            _loc5_.text = param2[_loc8_];
            if(_loc6_ > 0)
            {
               _loc4_.textColor = 16711680;
               _loc7_ = UIManager.getMovieClip("UpdateArrow");
               _loc7_.x = _loc4_.x + _loc4_.width;
               _loc7_.y = _loc4_.y;
               this.levelPanel.addChild(_loc7_);
               this.arrowArray.push(_loc7_);
            }
            _loc8_++;
         }
      }
      
      private function clearArrow() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:TextField = null;
         if(Boolean(this.iconMC))
         {
            DisplayUtil.removeAllChild(this.iconMC);
         }
         for each(_loc1_ in this.arrowArray)
         {
            DisplayUtil.removeForParent(_loc1_);
         }
         this.arrowArray = [];
         for each(_loc2_ in this.txtArray)
         {
            _loc2_.textColor = 26112;
         }
      }
      
      private function onLoadOld(param1:DisplayObject) : void
      {
         var o:DisplayObject = param1;
         this.oldPetMC = o as MovieClip;
         if(Boolean(this.oldPetMC))
         {
            this.oldPetMC.gotoAndStop("rightdown");
            this.oldPetMC.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = oldPetMC.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  oldPetMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            this.oldPetMC.scaleX = 1.5;
            this.oldPetMC.scaleY = 1.5;
            if(this.isEvolution)
            {
               this.iconMC.addChild(this.oldPetMC);
            }
         }
      }
      
      private function onLevelComplete(param1:DisplayObject) : void
      {
         var o:DisplayObject = param1;
         this.evoPetMC = o as MovieClip;
         if(Boolean(this.evoPetMC))
         {
            this.evoPetMC.gotoAndStop("rightdown");
            this.evoPetMC.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = evoPetMC.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  evoPetMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            this.evoPetMC.scaleX = 1.5;
            this.evoPetMC.scaleY = 1.5;
            this.iconMC.addChild(this.evoPetMC);
            if(this.isEvolution)
            {
               this.evoPetMC.alpha = 0;
               this.showEvolution();
            }
         }
      }
      
      private function showEvolution() : void
      {
         TweenLite.to(this.oldPetMC,1,{
            "alpha":0,
            "onComplete":this.onComp
         });
         this.effectMC = UIManager.getMovieClip("ui_PetEvolution_MC");
         this.effectMC.x = 61;
         this.effectMC.y = 190;
         this.levelPanel.addChild(this.effectMC);
      }
      
      private function onComp() : void
      {
         TweenLite.to(this.evoPetMC,1,{"alpha":1});
      }
   }
}

