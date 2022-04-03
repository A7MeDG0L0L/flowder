import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowder/src/core/downloader_core.dart';
import 'package:flowder/src/utils/constants.dart';
import 'package:flowder/src/utils/downloader_utils.dart';

export 'core/downloader_core.dart';
export 'progress/progress.dart';
export 'utils/utils.dart';

/// Global [typedef] that returns a `int` with the current byte on download
/// and another `int` with the total of bytes of the file.
typedef ProgressCallback = void Function(int count, int total);
typedef VoidCallback = void Function();

/// Class used as a Static Handler
/// you can call the folowwing functions.
/// - Flowder.download: Returns an instance of [DownloaderCore]
/// - Flowder.initDownload -> this used at your own risk.
class Flowder {
  /// Start a new Download progress.
  /// Returns a [DownloaderCore]
  static Future<DownloaderCore> download(String url,
      DownloaderUtils options) async {
    try {
      // ignore: cancel_subscriptions
      final subscription = await initDownload(url, options);
      return DownloaderCore(subscription, options, url);
    } catch (e) {
      rethrow;
    }
  }


  /// Init a new Download, however this returns a [StreamSubscription]
  /// use at your own risk.
  static Future<CancelToken> initDownload(String url, DownloaderUtils options) async {
    var lastProgress = await options.progress.getProgress(url);
    final client = options.client ?? Dio(BaseOptions(sendTimeout: 60),);
    final token = options.accessToken;

    CancelToken cancelToken = CancelToken();
    try {
      final response = await client.get(
        url,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.stream, headers: {
          HttpHeaders.rangeHeader: 'bytes=$lastProgress-',
          "Authorization":
          "Bearer $token"
        }),
      );
      final _total = int.tryParse(
          response.headers.value(HttpHeaders.contentLengthHeader)!) ??
          0;

      double received = 0;

      await for (final value in response.data.stream) {
        received += value.length;
        options.progressCallback.call(received.toInt(), _total);

        print('received value is $received');
      }

      options.onDone.call();

    } catch (e) {
      rethrow;
    }

    return cancelToken;
  }
}
