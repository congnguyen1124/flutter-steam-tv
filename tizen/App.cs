using Tizen.Flutter.Embedding;

namespace Runner
{
    public class App : FlutterApplication
    {
        public App()
        {
            // Keep texture frame delivery and platform-channel work off the Tizen app thread.
            // Flutter-Tizen 3.44 defaults to merging them, which can starve rendering on TV SoCs.
            UIThreadPolicy = FlutterUIThreadPolicy.RunOnSeparateThread;
        }

        protected override void OnCreate()
        {
            base.OnCreate();

            GeneratedPluginRegistrant.RegisterPlugins(this);
        }

        static void Main(string[] args)
        {
            var app = new App();
            app.Run(args);
        }
    }
}
