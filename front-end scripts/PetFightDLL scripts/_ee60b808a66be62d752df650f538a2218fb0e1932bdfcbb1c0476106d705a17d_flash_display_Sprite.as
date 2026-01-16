package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   public class _ee60b808a66be62d752df650f538a2218fb0e1932bdfcbb1c0476106d705a17d_flash_display_Sprite extends Sprite
   {
      
      public function _ee60b808a66be62d752df650f538a2218fb0e1932bdfcbb1c0476106d705a17d_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain.apply(null,rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain.apply(null,rest);
      }
   }
}

