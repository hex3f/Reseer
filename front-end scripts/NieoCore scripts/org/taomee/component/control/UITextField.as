package org.taomee.component.control
{
   import flash.text.TextField;
   import org.taomee.component.UIComponent;
   
   internal class UITextField extends UIComponent
   {
      
      public var txt:TextField;
      
      public function UITextField(param1:TextField)
      {
         super();
         this.txt = param1;
         addChild(param1);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.txt = null;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.txt.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.txt.height = param1;
      }
   }
}

