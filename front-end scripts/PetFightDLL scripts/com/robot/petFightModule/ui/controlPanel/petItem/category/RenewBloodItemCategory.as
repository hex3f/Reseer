package com.robot.petFightModule.ui.controlPanel.petItem.category
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.petFightModule.control.FighterModeFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import org.taomee.utils.DisplayUtil;
   
   public class RenewBloodItemCategory extends AbstractPetItemCategory implements IPetItemCategory
   {
      
      private var txt:TextField;
      
      private var bottomMC:MovieClip;
      
      private var effectMC:MovieClip;
      
      private var tf:TextFormat;
      
      public function RenewBloodItemCategory(param1:uint)
      {
         super(param1);
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
         this.txt.x = 15;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         DisplayUtil.removeForParent(this.txt);
         this.txt = null;
         if(Boolean(this.bottomMC))
         {
            DisplayUtil.removeForParent(this.bottomMC);
            DisplayUtil.removeForParent(this.effectMC);
         }
         this.bottomMC = null;
         this.effectMC = null;
      }
      
      override protected function useItem(param1:MouseEvent) : void
      {
         super.useItem(param1);
         SocketConnection.send(CommandID.USE_PET_ITEM,FighterModeFactory.playerMode.catchTime,_itemID,0);
         --_itemNum;
         --ItemManager.getCollectionInfo(_itemID).itemNum;
         refreshInfo();
      }
   }
}

