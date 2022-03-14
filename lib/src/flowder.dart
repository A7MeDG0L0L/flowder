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
  static Future<DownloaderCore> download(
      String url, DownloaderUtils options) async {
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
  static Future<StreamSubscription> initDownload(
      String url, DownloaderUtils options) async {
    var lastProgress = await options.progress.getProgress(url);
    final client = options.client ?? Dio(BaseOptions(sendTimeout: 60));
    // ignore: cancel_subscriptions
    StreamSubscription? subscription;
    try {
      isDownloading = true;
      final file = await options.file.create(recursive: true);
      final response = await client.get(
        url,
        options: Options(responseType: ResponseType.stream, headers: {
          HttpHeaders.rangeHeader: 'bytes=$lastProgress-',
          "Bearer":
              "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5MzcxNTciLCJqdGkiOiIzNjg3M2Y2NDMwYjI3OGRhMmRkOWYzMzkyMGNiMTRhMmJlODU4YjVlOTIwNGZlY2I4Yjk0Njk5ZGU2YjQxZjE2NjQ3NDUxNzgxY2I5ZjExZSIsImlhdCI6MTY0NzI1MDk1OSwibmJmIjoxNjQ3MjUwOTU5LCJleHAiOjE2NDk5MjU3NTksInN1YiI6IlVzZXIuMmZkODQ5NzAtMDU3Ni0xMWVjLTlmYTAtY2RkODY4MGNmZjM2Iiwic2NvcGVzIjpbXX0.ika4orAWHGvhQYpbnuBqjgQYM37fN5rMBo92KOhJRTM1z8WYRbdUVBLBAxaBAacrAkFk0cgA68clPuYEDR3andof8VMEuhyDiE-lKSZhY_9V2C0aVNyTvtlquh8L_hVSZLVpEXmuqI9j5zqmgrLVzpIDaV5HMNaV6AQSgDkFRhPcy2lzzABSIfJ2cAjy8AgP0KVW_UK2-weQ8MJ9iduyuw28kxlMuyyUAYojDMftEtmvm44KKexT7PkaQtl_i5T7RylV-GE6X8yBe8YZgBygzkaQ8u41zLdynJY1MAfATq_CMEh_0AGKAGjwcBGzsO1_HqqgggrN0zPydsISFGICgrqJdPVrPmGxKBqeg5nDLP_oUBVQlXAqd26Gn96L3lQvY4c64SVpu4aVepSB2lK0FY0Fyn7k1mVjYGIP8B50cHfsN8TqKM5_7Yvisq1gjW3305kTq-WlCm47327wdN6BNttMTnfgz_7isldC7UTC5JNQFWAQ0aUAT_oFW23Ishxv3zm3uvGBSF2LO4QvcN3yiQZ--QsZkgxO7oPKh4XCyDnW5srvzo0DJgwWWO7gy2iRhP3Ib33yt8t-d2Gk-m2ktN_Xd1lHg2DkMISaqZJ6jEMkC1zPWDYQE4qrsLmdHKop5lNyWecZo83wT9WaXkv1ZBo1LDUp149rVGjucXj0jEg"
        }),
      );
      final _total = int.tryParse(
              response.headers.value(HttpHeaders.contentLengthHeader)!) ??
          0;
      final sink = await file.open(mode: FileMode.writeOnlyAppend);
      subscription = response.data.stream.listen(
        (Uint8List data) async {
          subscription!.pause();
          await sink.writeFrom(data);
          final currentProgress = lastProgress + data.length;
          await options.progress.setProgress(url, currentProgress.toInt());
          options.progressCallback.call(currentProgress, _total);
          lastProgress = currentProgress;
          subscription.resume();
        },
        onDone: () async {
          options.onDone.call();
          await sink.close();
          if (options.client != null) client.close();
        },
        onError: (error) async => subscription!.pause(),
      );
      return subscription!;
    } catch (e) {
      rethrow;
    }
  }
}
