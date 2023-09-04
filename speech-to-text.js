// NOTE: the microsoft speech-to-text nodejs SDK only supports WAV file in the following format:
// Property	Value
// File format	RIFF(WAV)
// Sample rate	8, 000 Hz or 16, 000 Hz
// Channels	1(mono)
// Maximum length per audio	2 hours
// Sample format	PCM, 16 - bit
// Archive format .zip
// Maximum archive size	2 GB
// @see https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/how-to-custom-speech-test-and-train#audio-data-for-testing
(function () {
  "use strict";

  try { require('dotenv').config(); } catch (err) {};
  const sdk = require("microsoft-cognitiveservices-speech-sdk");
  const fs = require("fs");
  const JSONStream = require("JSONStream");

  const filename = process.argv[2];
  let language = '';

  if (!filename) {
    exitLog(`
      usage: node speech-to-text.js <path_to_wav_file> [<language>]

      <path_to_wav_file>: required. it's the path to the wav file to be transcribed.
      <language>: optional. e.g. en-US
        Language may be inferred from filename if it contains text matching locale-(locale).
    `);
  }

  const languageMatches = filename.match(/locale-([a-z]+-[A-Z]+)/);
  if (process.argv[3]) {
    language = process.argv[3];
  } else if (languageMatches) {
    language = languageMatches[1];
  }

  const recognizer = recognizerFor(streamAudio(filename));
  setup(recognizer);
  recognizer.startContinuousRecognitionAsync();

  function streamAudio(filename) {
    const pushStream = sdk.AudioInputStream.createPushStream();

    fs.createReadStream(filename)
      .on('data', function (arrayBuffer) {
        pushStream.write(arrayBuffer.slice());
      }).on('end', function () {
        pushStream.close();
      }).on('error', function (error) {
        exitLog(error.message);
      });

    return pushStream;
  }

  function recognizerFor(pushStream) {
    const subscriptionKey = process.env.SPEECH_TO_TEXT_KEY;
    const serviceRegion = process.env.SPEECH_TO_TEXT_REGION;

    const audioConfig = sdk.AudioConfig.fromStreamInput(pushStream);
    const speechConfig = sdk.SpeechConfig.fromSubscription(subscriptionKey, serviceRegion);
    if (language.length > 0) {
      speechConfig.speechRecognitionLanguage = language;
    }
    speechConfig.enableDictation();

    return new sdk.SpeechRecognizer(speechConfig, audioConfig);
  }

  function setup(recognizer) {
    const lines = [];

    recognizer.recognized = (s, e) => {
      // NOTE: we only capture the recognized text. everything else will be ignored.
      if (e.result.reason === sdk.ResultReason.RecognizedSpeech) {
        lines.push({
          start_time: e.result.offset / 10000, // in milliseconds
          end_time: (e.result.offset + e.result.duration) / 10000, // in milliseconds
          original_text: e.result.text,
          sequence: lines.length
        })
      }
    };

    recognizer.canceled = (s, e) => {
      recognizer.stopContinuousRecognitionAsync();

      if (e.reason === sdk.CancellationReason.Error) {
        exitLog(`${e.errorCode}: ${e.errorDetails}`);
      } else {
        // it ends without any error
        // we need to stream the output as it might get pretty huge
        const stringifyStream = JSONStream.stringify();
        stringifyStream.pipe(process.stdout);
        lines.forEach(line => stringifyStream.write(line));
        stringifyStream.end();
        process.exit();
      }
    };
  }

  function exitLog(message, exitCode) {
    console.log(message);
    process.exit(exitCode || 1);
  }
}());
