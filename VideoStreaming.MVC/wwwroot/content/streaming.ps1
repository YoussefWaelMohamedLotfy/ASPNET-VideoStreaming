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