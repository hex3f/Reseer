package com.robot.app.spacesurvey
{
   import com.robot.app.task.control.TaskController_37;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class SpaceSurveyResult extends Sprite
   {
      
      private const PATH:String = "module/surveyPole/surveyResultPanel.swf";
      
      private const SPACE:uint = 80;
      
      private var mainMC:MovieClip;
      
      private var petContainer:MovieClip;
      
      private var energyContainer:MovieClip;
      
      private var iconContainer:MovieClip;
      
      private var closeBtn:SimpleButton;
      
      private var introlTxt:TextField;
      
      private var spaceNameTxt:TextField;
      
      private var sprite:Sprite;
      
      private var namestr:String = "";
      
      private var bgCls:Class;
      
      private var iconMC:MovieClip;
      
      public function SpaceSurveyResult()
      {
         super();
      }
      
      public function show(param1:String) : void
      {
         this.namestr = param1;
         this.loadUI();
      }
      
      private function loadUI() : void
      {
         var _loc1_:String = ClientConfig.getResPath(this.PATH);
         var _loc2_:MCLoader = new MCLoader(_loc1_,LevelManager.appLevel,1,"正在加载测绘报告");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         _loc2_.doLoad();
      }
      
      private function onLoadSuccess(param1:MCLoadEvent) : void
      {
         var _loc2_:MCLoader = param1.currentTarget as MCLoader;
         _loc2_.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         this.bgCls = param1.getApplicationDomain().getDefinition("bg") as Class;
         var _loc3_:Class = param1.getApplicationDomain().getDefinition("mainMC") as Class;
         this.mainMC = new _loc3_() as MovieClip;
         this.sprite = this.mainMC["ttMC"];
         var _loc4_:Class = param1.getApplicationDomain().getDefinition(SurveyResultXMLInfo.getIconName(this.namestr)) as Class;
         this.iconMC = new _loc4_() as MovieClip;
         this.closeBtn = this.mainMC["close_btn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.close);
         this.petContainer = this.mainMC["petContainer"];
         this.energyContainer = this.mainMC["energyContainer"];
         this.iconContainer = this.mainMC["iconContainer"];
         this.introlTxt = this.mainMC["introl_txt"];
         this.spaceNameTxt = this.mainMC["spaceName_txt"];
         _loc2_.clear();
         this.init();
      }
      
      private function init() : void
      {
         this.addChild(this.mainMC);
         this.iconContainer.addChild(this.iconMC);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(this);
         this.introlTxt.text = SurveyResultXMLInfo.getIntrolInfo(this.namestr);
         this.spaceNameTxt.text = this.namestr;
         this.loadPet();
         this.loadItem();
      }
      
      private function close(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         DisplayUtil.removeAllChild(this.petContainer);
         DisplayUtil.removeAllChild(this.iconContainer);
         DisplayUtil.removeAllChild(this.energyContainer);
         DisplayUtil.removeForParent(this);
         if(TasksManager.getTaskStatus(TaskController_37.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_37.TASK_ID,function(param1:Array):void
            {
               if((Boolean(param1[0]) || Boolean(param1[1]) || Boolean(param1[2]) || Boolean(param1[3]) || Boolean(param1[4]) || Boolean(param1[5]) || Boolean(param1[6]) || Boolean(param1[7]) || Boolean(param1[8])) && Boolean(param1[9]) && !param1[10])
               {
                  TaskController_37.showTaskPanel();
               }
            });
         }
      }
      
      private function loadPet() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:String = SurveyResultXMLInfo.getPetsByName(this.namestr);
         var _loc3_:Array = _loc2_.split("|");
         if(_loc3_.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _loc3_.length)
            {
               ResourceManager.getResource(ClientConfig.getPetSwfPath(uint(_loc3_[_loc1_])),this.onLoadPet(_loc1_,_loc3_),"pet");
               _loc1_++;
            }
         }
      }
      
      private function onLoadPet(param1:uint, param2:Array) : Function
      {
         var index:uint = param1;
         var petsArr:Array = param2;
         var func:Function = function(param1:DisplayObject):void
         {
            var bmpData:BitmapData = null;
            var ma:Matrix = null;
            var rect:Rectangle = null;
            var bmp:Bitmap = null;
            var _showMc:MovieClip = null;
            var o:DisplayObject = param1;
            _showMc = null;
            _showMc = o as MovieClip;
            var bg:MovieClip = new bgCls() as MovieClip;
            bg.x = SPACE * index;
            if(Boolean(_showMc))
            {
               _showMc.gotoAndStop("rightdown");
               _showMc.addEventListener(Event.ENTER_FRAME,function():void
               {
                  var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
                  if(Boolean(_loc2_))
                  {
                     _loc2_.gotoAndStop(1);
                     _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
               DisplayUtil.stopAllMovieClip(_showMc);
            }
            bmpData = new BitmapData(_showMc.width,_showMc.height,true,0);
            ma = new Matrix();
            rect = _showMc.getRect(_showMc);
            ma.translate(-rect.x,-rect.y);
            bmpData.draw(_showMc,ma);
            bmp = new Bitmap(bmpData);
            DisplayUtil.align(bmp,bg.getRect(bg),AlignType.MIDDLE_CENTER);
            bg.addChild(bmp);
            ToolTipManager.add(bg,PetXMLInfo.getName(petsArr[index]));
            petContainer.addChild(bg);
         };
         return func;
      }
      
      private function loadItem() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:String = SurveyResultXMLInfo.getEnergysByName(this.namestr);
         var _loc3_:Array = _loc2_.split("|");
         if(_loc3_.length >= 1 && _loc3_[0] != "")
         {
            _loc1_ = 0;
            while(_loc1_ < _loc3_.length)
            {
               ResourceManager.getResource(ItemXMLInfo.getIconURL(uint(_loc3_[_loc1_])),this.onLoadItem(_loc1_,_loc3_),"item");
               _loc1_++;
            }
            this.sprite.visible = true;
         }
         else
         {
            this.sprite.visible = false;
         }
      }
      
      private function onLoadItem(param1:uint, param2:Array) : Function
      {
         var index:uint = param1;
         var energysArr:Array = param2;
         var func:Function = function(param1:DisplayObject):void
         {
            var _loc2_:MovieClip = param1 as MovieClip;
            _loc2_.gotoAndStop(1);
            var _loc3_:MovieClip = new bgCls() as MovieClip;
            _loc3_.x = SPACE * index;
            _loc2_.x = _loc2_.x - _loc3_.width / 2 + 10;
            _loc2_.y = _loc2_.y - _loc3_.height + 10;
            _loc3_.addChild(_loc2_);
            ToolTipManager.add(_loc3_,ItemXMLInfo.getName(energysArr[index]));
            energyContainer.addChild(_loc3_);
            DisplayUtil.align(_loc2_,_loc3_.getRect(_loc3_),AlignType.MIDDLE_CENTER);
         };
         return func;
      }
   }
}

