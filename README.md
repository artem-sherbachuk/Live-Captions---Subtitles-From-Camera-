# This is demo project for live captions while recording video from camera using SFSpeechRecognizer https://developer.apple.com/documentation/speech/sfspeechrecognizer
 
 I thought to create a complete app with live subtitles features, add some subtitle customizations, colors, fonts, animations etc. But found few problem with SFSpeechRecognizer: 
 - don't recognize punctuations, and questions, intonations. Need additional CoreML layer for punctuations etc.
 - delays while live recording. Find problematic then to sync with video using timestamps from SFTranscriptionSegment, it's possible to play and adjust later with synchronization, but I decide to just close this project since it's required more time than I thought.
