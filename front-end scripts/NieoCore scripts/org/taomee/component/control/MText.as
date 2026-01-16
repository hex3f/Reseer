package org.taomee.component.control
{
   import flash.text.TextFieldAutoSize;
   import org.taomee.component.ITextContentComponent;
   
   public class MText extends MLabel implements ITextContentComponent
   {
      
      public function MText(param1:String = "")
      {
         super(param1);
         txt.selectable = true;
         txt.wordWrap = true;
         txt.autoSize = TextFieldAutoSize.LEFT;
         if(param1 == "")
         {
            text = "";
         }
         txt.setTextFormat(tf);
         width = txt.width;
         height = txt.height;
      }
   }
}

