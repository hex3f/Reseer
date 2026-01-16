package tip
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class TipPanel extends Sprite
   {
      
      private static var tipPanel:TipPanel;
      
      private static var _fun:Function;
      
      public var tipMain:alertPanel;
      
      public function TipPanel()
      {
         super();
         this.tipMain = new alertPanel();
         this.tipMain.x = 0;
         this.tipMain.y = 0;
         addChild(this.tipMain);
         this.tipMain.tipContent.wordWrap = true;
         this.tipMain.tipContent.width = 240;
         this.tipMain.tipContent.multiline = true;
         this.tipMain.knowBtn.addEventListener(MouseEvent.CLICK,this.onOk);
      }
      
      public static function createTipPanel(param1:String, param2:Function = null) : void
      {
         if(tipPanel == null)
         {
            tipPanel = new TipPanel();
         }
         _fun = param2;
         tipPanel.x = 279;
         tipPanel.y = 126;
         tipPanel.tipMain.tipContent.text = param1;
         Login.loginRoot.addChild(tipPanel);
      }
      
      private function onOk(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         if(_fun != null)
         {
            _fun();
         }
      }
   }
}

