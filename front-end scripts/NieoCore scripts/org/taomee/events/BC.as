package org.taomee.events
{
   public class BC
   {
      
      public function BC()
      {
         super();
      }
      
      public static function addEvent(param1:*, param2:*, param3:String, param4:Function, param5:Boolean = false, param6:int = 0, param7:Boolean = false) : void
      {
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         var _loc10_:Boolean = false;
         var _loc11_:Number = 0;
         param2.addEventListener(param3,param4,param5,param6,param7);
         if(!param1.BC_List)
         {
            param1.BC_List = new Object();
         }
         _loc8_ = param1.BC_List;
         if(!_loc8_[param3])
         {
            _loc8_[param3] = new Object();
         }
         if(param5)
         {
            if(!_loc8_[param3].EventList1)
            {
               _loc8_[param3].EventList1 = new Array();
            }
            _loc9_ = _loc8_[param3].EventList1;
         }
         else
         {
            if(!_loc8_[param3].EventList2)
            {
               _loc8_[param3].EventList2 = new Array();
            }
            _loc9_ = _loc8_[param3].EventList2;
         }
         if(Boolean(_loc9_.length))
         {
            _loc10_ = true;
            _loc11_ = 0;
            while(_loc11_ < _loc9_.length)
            {
               if(_loc9_[_loc11_].p == param2 && _loc9_[_loc11_].e == param3 && _loc9_[_loc11_].f == param4 && _loc9_[_loc11_].u == param5)
               {
                  _loc10_ = false;
                  break;
               }
               _loc11_++;
            }
            if(_loc10_)
            {
               _loc9_.push({
                  "a":param1,
                  "p":param2,
                  "e":param3,
                  "f":param4,
                  "u":param5
               });
            }
         }
         else
         {
            _loc9_.push({
               "a":param1,
               "p":param2,
               "e":param3,
               "f":param4,
               "u":param5
            });
         }
      }
      
      public static function removeEvent(param1:*, param2:* = null, param3:String = null, param4:Function = null, param5:Boolean = false) : void
      {
         var j:* = undefined;
         var tempObj:Array = null;
         var a:* = param1;
         var p:* = param2;
         var event:String = param3;
         var func:Function = param4;
         var useCapture:Boolean = param5;
         var myobj:Object = null;
         var i:* = undefined;
         j = undefined;
         tempObj = null;
         if(a.BC_List != null)
         {
            myobj = a.BC_List;
            if(p == null && event == null && func == null)
            {
               for(i in myobj)
               {
                  if(myobj[i]["EventList1"] != null)
                  {
                     tempObj = myobj[i]["EventList1"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        try
                        {
                           tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                           tempObj.splice(j,1);
                           j--;
                        }
                        catch(E:Error)
                        {
                           tempObj.splice(j,1);
                           j--;
                        }
                        j++;
                     }
                  }
                  if(myobj[i]["EventList2"] != null)
                  {
                     tempObj = myobj[i]["EventList2"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        try
                        {
                           tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                           tempObj.splice(j,1);
                           j--;
                        }
                        catch(E:Error)
                        {
                           tempObj.splice(j,1);
                           j--;
                        }
                        j++;
                     }
                  }
               }
            }
            else if(p == null && event == null && func != null)
            {
               if(useCapture)
               {
                  for(i in myobj)
                  {
                     if(myobj[i]["EventList1"] != null)
                     {
                        tempObj = myobj[i]["EventList1"];
                        j = 0;
                        while(j < tempObj.length)
                        {
                           if(func == tempObj[j].f)
                           {
                              try
                              {
                                 tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                              }
                           }
                           j++;
                        }
                     }
                  }
               }
               else
               {
                  for(i in myobj)
                  {
                     if(myobj[i]["EventList2"] != null)
                     {
                        tempObj = myobj[i]["EventList2"];
                        j = 0;
                        while(j < tempObj.length)
                        {
                           if(func == tempObj[j].f)
                           {
                              try
                              {
                                 tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                              }
                           }
                           j++;
                        }
                     }
                  }
               }
            }
            else if(p == null && event != null && func == null)
            {
               if(myobj[event] != null)
               {
                  if(myobj[event]["EventList1"] != null)
                  {
                     tempObj = myobj[event]["EventList1"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(event == tempObj[j].e)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
                  if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(event == tempObj[j].e)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
               }
            }
            else if(p != null && event == null && func == null)
            {
               for(i in myobj)
               {
                  if(myobj[i]["EventList1"] != null)
                  {
                     tempObj = myobj[i]["EventList1"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(p == tempObj[j].p)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
                  if(myobj[i]["EventList2"] != null)
                  {
                     tempObj = myobj[i]["EventList2"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(p == tempObj[j].p)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
               }
            }
            else if(p == null && event != null && func != null)
            {
               if(myobj[event] != null)
               {
                  if(useCapture)
                  {
                     if(myobj[event]["EventList1"] != null)
                     {
                        tempObj = myobj[event]["EventList1"];
                        j = 0;
                        while(j < tempObj.length)
                        {
                           if(func == tempObj[j].f && event == tempObj[j].e)
                           {
                              try
                              {
                                 tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                              }
                           }
                           j++;
                        }
                     }
                  }
                  else if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(func == tempObj[j].f && event == tempObj[j].e)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
               }
            }
            else if(p != null && event != null && func == null)
            {
               if(myobj[event] != null)
               {
                  if(myobj[event]["EventList1"] != null)
                  {
                     tempObj = myobj[event]["EventList1"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(p == tempObj[j].p && event == tempObj[j].e)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
                  if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     j = 0;
                     while(j < tempObj.length)
                     {
                        if(p == tempObj[j].p && event == tempObj[j].e)
                        {
                           try
                           {
                              tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                           }
                        }
                        j++;
                     }
                  }
               }
            }
            else if(p != null && event == null && func != null)
            {
               if(useCapture)
               {
                  for(i in myobj)
                  {
                     if(myobj[i]["EventList1"] != null)
                     {
                        tempObj = myobj[i]["EventList1"];
                        j = 0;
                        while(j < tempObj.length)
                        {
                           if(func == tempObj[j].f && p == tempObj[j].p)
                           {
                              try
                              {
                                 tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,true);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                              }
                           }
                           j++;
                        }
                     }
                  }
               }
               else
               {
                  for(i in myobj)
                  {
                     if(myobj[i]["EventList2"] != null)
                     {
                        tempObj = myobj[i]["EventList2"];
                        j = 0;
                        while(j < tempObj.length)
                        {
                           if(func == tempObj[j].f && p == tempObj[j].p)
                           {
                              try
                              {
                                 tempObj[j].p.removeEventListener(tempObj[j].e,tempObj[j].f,false);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                              }
                           }
                           j++;
                        }
                     }
                  }
               }
            }
            else if(p != null && event != null && func != null)
            {
               if(myobj[event] != null)
               {
                  if(useCapture)
                  {
                     if(myobj[event]["EventList1"] != null)
                     {
                        tempObj = myobj[event]["EventList1"];
                        j = 0;
                        for(; j < tempObj.length; j++)
                        {
                           if(!(func == tempObj[j].f && p == tempObj[j].p))
                           {
                              continue;
                           }
                           try
                           {
                              p.removeEventListener(event,func,useCapture);
                              tempObj.splice(j,1);
                              j--;
                              break;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                              break;
                           }
                        }
                     }
                  }
                  else if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     j = 0;
                     for(; j < tempObj.length; j++)
                     {
                        if(!(func == tempObj[j].f && p == tempObj[j].p))
                        {
                           continue;
                        }
                        try
                        {
                           p.removeEventListener(event,func,useCapture);
                           tempObj.splice(j,1);
                           j--;
                           break;
                        }
                        catch(E:Error)
                        {
                           tempObj.splice(j,1);
                           j--;
                           break;
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

