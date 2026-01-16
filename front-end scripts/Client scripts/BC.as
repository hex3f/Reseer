package
{
   public class BC
   {
      
      public function BC()
      {
         super();
      }
      
      public static function addEvent(a:*, p:*, event:String, func:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         var myobj:Object = null;
         var EventList:Array = null;
         var __addBool:Boolean = false;
         var i:uint = 0;
         p.addEventListener(event,func,useCapture,priority,useWeakReference);
         if(!a.BC_List)
         {
            a.BC_List = new Object();
         }
         myobj = a.BC_List;
         if(!myobj[event])
         {
            myobj[event] = new Object();
         }
         if(useCapture)
         {
            if(!myobj[event].EventList1)
            {
               myobj[event].EventList1 = new Array();
            }
            EventList = myobj[event].EventList1;
         }
         else
         {
            if(!myobj[event].EventList2)
            {
               myobj[event].EventList2 = new Array();
            }
            EventList = myobj[event].EventList2;
         }
         if(Boolean(EventList.length))
         {
            __addBool = true;
            for(i = 0; i < EventList.length; i++)
            {
               if(EventList[i].p == p && EventList[i].e == event && EventList[i].f == func && EventList[i].u == useCapture)
               {
                  __addBool = false;
                  break;
               }
            }
            if(__addBool)
            {
               EventList.push({
                  "a":a,
                  "p":p,
                  "e":event,
                  "f":func,
                  "u":useCapture
               });
            }
         }
         else
         {
            EventList.push({
               "a":a,
               "p":p,
               "e":event,
               "f":func,
               "u":useCapture
            });
         }
      }
      
      public static function removeEvent(a:*, p:* = null, event:String = null, func:Function = null, useCapture:Boolean = false) : void
      {
         var myobj:Object = null;
         var i:* = undefined;
         var j:* = undefined;
         var tempObj:Array = null;
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
                     for(j = 0; j < tempObj.length; j++)
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
                  }
                  if(myobj[i]["EventList2"] != null)
                  {
                     tempObj = myobj[i]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
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
                     for(j = 0; j < tempObj.length; j++)
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
                     }
                  }
                  if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
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
                     for(j = 0; j < tempObj.length; j++)
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
                     }
                  }
                  if(myobj[i]["EventList2"] != null)
                  {
                     tempObj = myobj[i]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
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
                        }
                     }
                  }
                  else if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
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
                     for(j = 0; j < tempObj.length; j++)
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
                     }
                  }
                  if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
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
                        for(j = 0; j < tempObj.length; j++)
                        {
                           if(func == tempObj[j].f && p == tempObj[j].p)
                           {
                              try
                              {
                                 p.removeEventListener(event,func,useCapture);
                                 tempObj.splice(j,1);
                                 j--;
                              }
                              catch(E:Error)
                              {
                                 tempObj.splice(j,1);
                                 j--;
                                 break;
                              }
                              break;
                           }
                        }
                     }
                  }
                  else if(myobj[event]["EventList2"] != null)
                  {
                     tempObj = myobj[event]["EventList2"];
                     for(j = 0; j < tempObj.length; j++)
                     {
                        if(func == tempObj[j].f && p == tempObj[j].p)
                        {
                           try
                           {
                              p.removeEventListener(event,func,useCapture);
                              tempObj.splice(j,1);
                              j--;
                           }
                           catch(E:Error)
                           {
                              tempObj.splice(j,1);
                              j--;
                              break;
                           }
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

