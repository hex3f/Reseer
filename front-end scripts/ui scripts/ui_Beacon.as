package
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.globalization.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.sensors.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol249")]
   public dynamic class ui_Beacon extends MovieClip
   {
      
      public var mc:MovieClip;
      
      public function ui_Beacon()
      {
         super();
         addFrameScript(15,this.frame16);
      }
      
      internal function frame16() : *
      {
         stop();
         this.r = Math.floor(Math.random() * this.mc.numChildren);
         this.i = 0;
         while(this.i < this.mc.numChildren)
         {
            this.d = this.mc.getChildAt(this.i);
            if(this.i != this.r)
            {
               this.d.visible = false;
            }
            ++this.i;
         }
      }
   }
}

