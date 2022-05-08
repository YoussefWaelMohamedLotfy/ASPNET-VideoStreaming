# Video Streaming in HTML5
This repo shows how you can add Video Streaming to your ASP.NET Core App.

## Understanding Video Streaming
Normal MP4 (MPEG-4) videos are rendered in one resolution only, depending on the quality of camera and recording. The resolution can be converted with tools made for this purpose.

When you put a video in `<video>` `src` attribute, The video is being loaded as a whole. Unlike in Streaming, the video is loaded in chunks "Segments" that adjust to user's connection speed.

MPEG-DASH (Moving Picture Experts Group-Dynamic Adaptive Streaming over Hypertext Transport) is a streaming protocol. It's an international standard and delivers video content over the internet.

MPEG-DASH utilizes adaptive bitrate streaming, meaning that if a user has an unstable internet connection, MPEG-DASH will adjust the quality of the video stream to match their connection speed. This prevents buffering issues from occurring or makes them less likely to occur.

> For more info on MPEG-DASH, Check the references below.

## Video Content Preparation for streaming
In order to prepare the content for streaming, I used [Bento4](https://www.bento4.com/) for this task in this demo. There are others out in the internet as well with varying pricing plans and capabilities, such as [GPAC](https://gpac.wp.imt.fr/).

Steps of Content Preparation are [in this article](https://ottverse.com/bento4-mp4dash-for-mpeg-dash-packaging/). You are expecting to have an `output` folder with the video segmented and an `MPD` manifest file, ready to be delivered to your viewers.

> For extra reading on the procedures of delivering Video Streaming to users, read [Chapter 14 "Design YouTube" in System Design Interview Book](https://printige.net/product/system-design-interview-an-insider-guide/).

To display the Video Stream, a MPEG-DASH client is required for playback of the stream. [dash.js](https://github.com/Dash-Industry-Forum/dash.js) is used for this task. [Samples can be found on their website](https://reference.dashif.org/dash.js/latest/samples/index.html).

## Enabling MIME Types for Streamed Content
If you have prepared your content, added it to the HTML and run your app, the video will not work. Open the "Network" Tab of your browser's Dev Tools and you will find a bunch of `404 Not Found` responses of the streamed files. That's because the app cannot identify the file formats of the Segmented Video and manifest file. You need to enable support for the streamed files format in your app.

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

With this configuration, you can view your Streamed Video in your app.

## References
+ [KeyCDN Article "MPEG-DASH - Dynamic Adaptive Streaming Over HTTP" Explained](https://www.keycdn.com/support/mpeg-dash)
+ [What is MPEG-DASH Video Streaming Protocol? How Does MPEG-DASH Work? by OTTVerse](https://ottverse.com/mpeg-dash-video-streaming-the-complete-guide/)
+ [How to Package MPEG-DASH using Bento4’s mp4dash? by OTTVerse](https://ottverse.com/bento4-mp4dash-for-mpeg-dash-packaging/)
+ [Bento4's MPEG DASH Adaptive Streaming Documentation](https://www.bento4.com/developers/dash/)