package org.taomee.tmf
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class TmfByteArray extends ByteArray
   {
      
      public function TmfByteArray(param1:IDataInput)
      {
         super();
         param1.readBytes(this,bytesAvailable);
      }
   }
}

