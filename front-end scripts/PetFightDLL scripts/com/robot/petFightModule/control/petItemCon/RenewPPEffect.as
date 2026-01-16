package com.robot.petFightModule.control.petItemCon
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.mode.PlayerMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.AbstractPetItemCategory;
   import com.robot.petFightModule.ui.controlPanel.subui.SkillBtnView;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.utils.DisplayUtil;
   
   public class RenewPPEffect
   {
      
      private var bottomMC:MovieClip;
      
      private var mode:BaseFighterMode;
      
      private var itemID:uint;
      
      private var effectMC:MovieClip;
      
      public function RenewPPEffect(param1:BaseFighterMode, param2:uint)
      {
         var timer:Timer = null;
         var mode:BaseFighterMode = param1;
         var itemID:uint = param2;
         super();
         this.mode = mode;
         this.itemID = itemID;
         this.resetPP();
         timer = new Timer(2500,1);
         timer.addEventListener(TimerEvent.TIMER,this.closeTxt);
         timer.start();
         if(!this.bottomMC)
         {
            this.bottomMC = new Item_PP_Bottom();
            this.bottomMC.x = BaseFighterPetWin.WIN_WIDTH / 2;
            this.bottomMC.y = BaseFighterPetWin.WIN_HEIGHT - 15;
            this.effectMC = new Item_PP_Effect();
            this.effectMC.x = this.bottomMC.x;
            this.effectMC.y = this.bottomMC.y;
         }
         this.bottomMC.gotoAndPlay(2);
         this.effectMC.gotoAndPlay(2);
         mode.petWin.petContainer.addChildAt(this.bottomMC,0);
         mode.petWin.petContainer.addChild(this.effectMC);
         this.effectMC.addFrameScript(60,function():void
         {
            effectMC.gotoAndStop(1);
            bottomMC.gotoAndStop(1);
            effectMC.addFrameScript(60,null);
            DisplayUtil.removeForParent(bottomMC);
            DisplayUtil.removeForParent(effectMC);
         });
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         AbstractPetItemCategory.dispatchOnUsePetItem();
      }
      
      private function resetPP() : void
      {
         var _loc1_:* = 0;
         var _loc2_:SkillBtnView = null;
         if(this.mode is PlayerMode)
         {
            _loc1_ = uint(ItemXMLInfo.getPP(this.itemID));
            for each(_loc2_ in PlayerMode(this.mode).skillBtnViews)
            {
               _loc2_.changePP(_loc1_);
            }
         }
      }
   }
}

