package com.robot.petFightModule.loadUI
{
   import com.robot.core.config.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import org.taomee.manager.*;
   
   public class PetWarLoadingUI extends Sprite
   {
      
      private var _petIdA:Array;
      
      private var _petMcA:Array = new Array();
      
      private var _iconMc:Sprite;
      
      private const point:Point = new Point(-154.4,-53.1);
      
      private var _curIndex:uint = 0;
      
      private var _pointA:Array = [new Point(140,200),new Point(140,355),new Point(140,490),new Point(780,200),new Point(780,355),new Point(780,490)];
      
      private var loadMc:PetWarLoadingMc;
      
      public function PetWarLoadingUI(param1:Array)
      {
         super();
         this._petIdA = param1;
         this._curIndex = 0;
         this.loadMc = new PetWarLoadingMc();
         this.loadMc["mc1"].gotoAndStop(1);
         this.loadMc["mc2"].gotoAndStop(1);
         this.loadMc["mc3"].gotoAndStop(1);
         this.addChild(this.loadMc);
         this.loadMc.x = this.point.x;
         this.loadMc.y = this.point.y;
      }
      
      public function startLoad() : void
      {
         this._curIndex = 0;
         this.loadPet(this._petIdA[this._curIndex]);
      }
      
      private function onSucHandler(param1:DisplayObject) : void
      {
         this._petMcA.push(param1);
         ++this._curIndex;
         if(this._curIndex < this._petIdA.length)
         {
            this.loadPet(this._petIdA[this._curIndex]);
         }
         else
         {
            this.onPlayHandler();
         }
      }
      
      private function closeHandler() : void
      {
         this._iconMc.visible = true;
         this.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function loadPet(param1:uint) : void
      {
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),this.onSucHandler,"pet");
      }
      
      private function onPlayHandler() : void
      {
         var i1:int = 0;
         var mc:MovieClip = null;
         this._iconMc = new Sprite();
         this.addChild(this._iconMc);
         this.loadMc["mc1"].gotoAndPlay(2);
         this.loadMc["mc2"].gotoAndPlay(2);
         this.loadMc["mc3"].gotoAndPlay(2);
         i1 = 0;
         while(i1 < this._petIdA.length)
         {
            mc = this._petMcA[i1] as MovieClip;
            if(i1 < 3)
            {
               mc.gotoAndStop(Direction.RIGHT_DOWN);
            }
            else
            {
               mc.gotoAndStop(Direction.LEFT_DOWN);
            }
            this._iconMc.addChild(mc);
            mc.x = (this._pointA[i1] as Point).x;
            mc.y = (this._pointA[i1] as Point).y;
            mc.scaleX = mc.scaleY = 3;
            i1++;
         }
         this._iconMc.visible = false;
         setTimeout(function():void
         {
            closeHandler();
         },6500);
      }
   }
}

