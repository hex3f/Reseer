package org.taomee.component.bgFill
{
   import flash.display.Sprite;
   import org.taomee.component.UIComponent;
   
   public class SoildFillStyle implements IBgFillStyle
   {
      
      private var fillColor:uint = 16777215;
      
      private var elipseWidth:Number;
      
      private var bgAlpha:Number;
      
      private var bgMC:Sprite;
      
      private var elipseHeight:Number;
      
      public function SoildFillStyle(param1:uint = 16777215, param2:Number = 1, param3:Number = 0, param4:Number = 0)
      {
         super();
         this.fillColor = param1;
         this.bgAlpha = param2;
         this.elipseHeight = param4;
         this.elipseWidth = param3;
      }
      
      public function draw(param1:Sprite) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this.bgMC = param1;
         this.bgMC.graphics.beginFill(this.fillColor,this.bgAlpha);
         _loc2_ = UIComponent(this.bgMC.parent).width;
         _loc3_ = UIComponent(this.bgMC.parent).height;
         this.bgMC.graphics.drawRoundRect(0,0,_loc2_,_loc3_,this.elipseWidth,this.elipseHeight);
         this.bgMC.graphics.endFill();
      }
      
      public function clear() : void
      {
         this.bgMC.graphics.clear();
         this.bgMC = null;
      }
      
      public function reDraw() : void
      {
         if(Boolean(this.bgMC))
         {
            this.bgMC.graphics.clear();
         }
         this.draw(this.bgMC);
      }
   }
}

