# Video Streaming in HTML5

This repo shows how you can add Video Streaming to your ASP.NET Core App.

## Table of Contents

+ [Understanding Video Streaming](#understanding-video-streaming)
+ [Video Content Preparation for streaming](#video-content-preparation-for-streaming)
  + [Example Script for an `HLS+MPEG-DASH` Content](#example-script-for-an-hlsmpeg-dash-content)
+ [Enabling MIME Types for Streamed Content in ASP.NET Core](#enabling-mime-types-for-streamed-content-in-aspnet-core)
+ [References](#references)

## Understanding Video Streaming

Normal MP4 (MPEG-4) videos are rendered in one resolution only, depending on the quality of camera and recording. The resolution can be converted with tools made for this purpose.

When you put a video in an HTML5 `<video>` `src` attribute, The video is being loaded as a whole. Unlike in Adaptive Streaming, the video is loaded in chunks "Segments" that adjust to user's bandwidth.

MPEG-DASH (Moving Picture Experts Group-Dynamic Adaptive Streaming over Hypertext Transport) is a streaming protocol. It's an international standard and delivers video content over the internet. MPEG-DASH utilizes adaptive bitrate streaming, meaning that if a user has an unstable internet connection, MPEG-DASH will adjust the quality of the video stream to match their connection speed. This prevents buffering issues from occurring or makes them less likely to occur.

> For more info on MPEG-DASH, Check the references section below.

## Video Content Preparation for streaming

In order to prepare the content for streaming, I used [FFmpeg](https://ffmpeg.org/) for this task in this demo. FFmpeg (Fast Forward MPEG) is an Free Open-Source Media Manipulation tool for various content preparation tasks, such as Image and Audio Processing, Video Editing and Streaming. It is also compatible with many popular media protocols and encodings, such as HLS, MPEG-DASH, MP4, OGG, MP3, AAC, and much more...

If you are new to Media Manipulation using FFmpeg and want to know more about what Media is and its details, I highly recommend taking this Udemy course '[FFmpeg - The Complete Guide](https://www.udemy.com/course/ffmpeg-the-complete-guide/)' to learn more about FFmpeg.

### Example Script for an `HLS+MPEG-DASH` Content

The following PowerShell Script allows you to prepare an FHD (Full High Definition) [1920x1080] `mp4` video, recorded at 30 FPS (Frames per Second), to produce segments for supporting 4 different resolutions: `1080p`, `720p`, `480p`, `240p`.

```powershell
ffmpeg -y -i ./nature.mp4 -to 30 `
-filter_complex "split=4[1080_in][720_in][480_in][240_in];[1080_in]scale=-2:1080,drawtext=fontfile='c\:/Windows/Fonts/courbd.ttf':text=1080p:fontsize=50[1080_out];[720_in]scale=-2:720,drawtext=fontfile='c\:/Windows/Fonts/courbd.ttf':text=720p:fontsize=50[720_out];[480_in]scale=-2:480,drawtext=fontfile='c\:/Windows/Fonts/courbd.ttf':text=480p:fontsize=50[480_out];[240_in]scale=-2:240,drawtext=fontfile='c\:/Windows/Fonts/courbd.ttf':text=240p:fontsize=50[240_out]" `
-map [1080_out] -map [720_out] -map [480_out] -map [240_out] -map 0:a `
-b:v:0 7500k -maxrate:v:0 7500k -bufsize:v:0 7500k `
-b:v:1 3500k -maxrate:v:1 3500k -bufsize:v:1 3500k `
-b:v:2 1690k -maxrate:v:2 1690k -bufsize:v:2 1690k `
-b:v:3 326k -maxrate:v:3 326k -bufsize:v:3 326k `
-b:a:0 128k `
-x264-params "keyint=60:min-keyint=60:scenecut=0" `
-hls_playlist 1 `
-hls_master_name nature.m3u8 `
-seg_duration 2 `
./NatureStream/nature.mpd
```

When the content is prepared, the files that are used in the code are `nature.mpd` and `nature.m3u8`. The output file names can be changed to your needs.

> For extra reading on the procedures of delivering Video Streaming to millions of users worldwide, read [Chapter 14 "Design YouTube" in System Design Interview Book](https://printige.net/product/system-design-interview-an-insider-guide/).

To display the Video Stream on your website, a MPEG-DASH client is required for playback of the stream. [Google Shaka Player](https://github.com/shaka-project/shaka-player) is used for this task. [dash.js](https://github.com/Dash-Industry-Forum/dash.js) can be used as an alternative. [dash.js Samples can be found on their website](https://reference.dashif.org/dash.js/latest/samples/index.html).

## Enabling MIME Types for Streamed Content in ASP.NET Core

If you have prepared your content, added it to the HTML and run your app, the video will not work. Open the "Network" Tab of your browser's Dev Tools and you will find a bunch of `404 Not Found` responses of the streamed files. That's because the app cannot identify the file formats of the Segmented Video and `mpd` manifest file. You need to enable support for the streamed files format in your app.

> Check this [Github issue #25](https://github.com/Dash-Industry-Forum/Ingest/issues/25) for MIME types of Streamed Content files.

In ASP.NET Core, add the following snippet to add the MIME types of the files by configuring the Request Pipeline.

```c#
// Set up custom content types - associating file extension to MIME type
var provider = new FileExtensionContentTypeProvider();

// Add new mappings
provider.Mappings[".mpd"] = "application/dash+xml";
provider.Mappings[".m4s"] = "video/iso.segment";
provider.Mappings[".vtt"] = "text/vtt";

app.UseStaticFiles(new StaticFileOptions 
{ 
    ContentTypeProvider = provider
});
```

> The snippet should be placed before `app.UseRouting();` and after `app.UseHttpsRedirection();` as per [ASP.NET Middleware order](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/?view=aspnetcore-6.0#order).

With this configuration, you can view your Adaptive Streamed Content in your app.

## References

+ [KeyCDN Article "MPEG-DASH - Dynamic Adaptive Streaming Over HTTP" Explained](https://www.keycdn.com/support/mpeg-dash)
+ [What is MPEG-DASH Video Streaming Protocol? How Does MPEG-DASH Work? by OTTVerse](https://ottverse.com/mpeg-dash-video-streaming-the-complete-guide/)
+ [FFmpeg Recipes](https://ottverse.com/recipes-in-ffmpeg/)
