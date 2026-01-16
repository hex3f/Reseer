package org.taomee.component
{
   import org.taomee.component.bgFill.IBgFillStyle;
   import org.taomee.component.event.MComponentEvent;
   import org.taomee.component.manager.IToolTipManager;
   import org.taomee.component.tips.ToolTip;
   
   [Event(name="onUpdate",type="org.taomee.component.event.MComponentEvent")]
   public class UIComponent extends MSprite implements IToolTipManager
   {
      
      private var _bgFillStyle:IBgFillStyle;
      
      public function UIComponent()
      {
         super();
      }
      
      override public function destroy() : void
      {
         if(Boolean(this._bgFillStyle))
         {
            this._bgFillStyle.clear();
         }
         this._bgFillStyle = null;
         super.destroy();
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.mouseChildren = param1;
         this.mouseEnabled = param1;
         if(param1)
         {
            this.alpha = 1;
         }
         else
         {
            this.alpha = 0.5;
         }
      }
      
      override protected function revalidate() : void
      {
         super.revalidate();
         if(Boolean(this._bgFillStyle))
         {
            this._bgFillStyle.reDraw();
         }
         dispatchEvent(new MComponentEvent(MComponentEvent.UPDATE));
      }
      
      public function setSizeWH(param1:int, param2:int) : void
      {
         if(param1 == width && param2 == height)
         {
            return;
         }
         width = param1;
         height = param2;
      }
      
      public function set toolTip(param1:String) : void
      {
         ToolTip.add(this,param1);
      }
      
      public function clearTip() : void
      {
         ToolTip.remove(this);
      }
      
      public function set bgFillStyle(param1:IBgFillStyle) : void
      {
         if(param1 == null)
         {
            if(Boolean(this._bgFillStyle))
            {
               this._bgFillStyle.clear();
            }
            this._bgFillStyle = null;
         }
         else
         {
            if(Boolean(this._bgFillStyle))
            {
               this._bgFillStyle.clear();
            }
            this._bgFillStyle = param1;
            this._bgFillStyle.draw(bgMC);
         }
      }
   }
}

