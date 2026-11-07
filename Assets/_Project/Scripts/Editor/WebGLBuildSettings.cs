using UnityEditor;

namespace VandalSim.EditorTools
{
    /// <summary>
    /// Hlídá nastavení WebGL buildu pro GitHub Pages.
    /// GitHub Pages neposílá hlavičku Content-Encoding, proto používáme Gzip
    /// s Decompression Fallback (rozbalení v prohlížeči přes JavaScript).
    /// Běží při každém načtení editoru – i v CI (GameCI), takže build je vždy správně.
    /// </summary>
    [InitializeOnLoad]
    public static class WebGLBuildSettings
    {
        static WebGLBuildSettings()
        {
            // Měníme jen když se hodnota liší, ať zbytečně nešpiníme ProjectSettings.
            if (PlayerSettings.WebGL.compressionFormat != WebGLCompressionFormat.Gzip)
            {
                PlayerSettings.WebGL.compressionFormat = WebGLCompressionFormat.Gzip;
            }

            if (!PlayerSettings.WebGL.decompressionFallback)
            {
                PlayerSettings.WebGL.decompressionFallback = true;
            }
        }
    }
}
