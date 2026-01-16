package com.robot.petFightModule.control.petItemCon
{
   import com.robot.core.manager.MainManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.AbstractPetItemCategory;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import gs.TweenLite;
   import org.taomee.utils.DisplayUtil;
   
   public class RenewBloodEffect
   {
      
      private var txt:TextField;
      
      private var bottomMC:MovieClip;
      
      private var effectMC:MovieClip;
      
      private var tf:TextFormat;
      
      private var _oldMode:BaseFighterMode;
      
      public function RenewBloodEffect(param1:BaseFighterMode, param2:uint, param3:int)
      {
         var timer:Timer = null;
         var mode:BaseFighterMode = param1;
         var itemID:uint = param2;
         var changeHp:int = param3;
         super();
         this.tf = new TextFormat();
         this.tf.font = "Arial";
         this.tf.color = 52224;
         this.tf.size = 45;
         this.tf.bold = true;
         this.tf.align = TextFormatAlign.CENTER;
         this.txt = new TextField();
         this.txt.filters = [new GlowFilter(16777215,1,6,6,5)];
         this.txt.width = 150;
         this.txt.height = 50;
         this.txt.x = param1.userID != MainManager.actorID ? 15 : 100;
         if(changeHp < 0)
         {
            this.txt.text = "-" + Math.abs(changeHp);
         }
         else
         {
            this.txt.text = "+" + Math.abs(changeHp);
         }
         this.txt.setTextFormat(this.tf);
         mode.petWin.petContainer.addChild(this.txt);
         TweenLite.to(this.txt,1,{"y":-30});
         timer = new Timer(2500,1);
         timer.addEventListener(TimerEvent.TIMER,this.closeTxt);
         timer.start();
         if(!this.bottomMC)
         {
            this.bottomMC = new Item_Blood_Bottom();
            this.bottomMC.x = BaseFighterPetWin.WIN_WIDTH / 2;
            this.bottomMC.y = BaseFighterPetWin.WIN_HEIGHT - 15;
            this.effectMC = new Item_Blood_Effect();
            this.effectMC.x = this.bottomMC.x;
            this.effectMC.y = this.bottomMC.y;
         }
         this.bottomMC.gotoAndPlay(2);
         this.effectMC.gotoAndPlay(2);
         mode.petWin.petContainer.addChildAt(this.bottomMC,0);
         mode.petWin.petContainer.addChild(this.effectMC);
         this.effectMC.addFrameScript(71,function():void
         {
            effectMC.gotoAndStop(1);
            bottomMC.gotoAndStop(1);
            effectMC.addFrameScript(71,null);
            DisplayUtil.removeForParent(bottomMC);
            DisplayUtil.removeForParent(effectMC);
         });
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         if(Boolean(this.txt))
         {
            DisplayUtil.removeForParent(this.txt);
            this.txt = null;
         }
         AbstractPetItemCategory.dispatchOnUsePetItem();
      }
   }
}

