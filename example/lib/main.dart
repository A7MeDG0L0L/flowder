import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flowder/flowder.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DownloaderUtils options;
  late DownloaderCore core;
  late final String path;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _setPath();
    if (!mounted) return;
  }

  void _setPath() async {
    path = (await getExternalStorageDirectory())!.path;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('TERI TERI'),
            Text('Audio'),
            ElevatedButton(
              onPressed: () async {
                options = DownloaderUtils(
                  progressCallback: (current, total) {
                    final progress = (current / total) * 100;
                    print('Downloading: $progress');
                  },
                  file: File('$path/200MB.zip'),
                  progress: ProgressImplementation(),
                  onDone: () => print('COMPLETE'),
                  deleteOnCancel: true, accessToken: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5MzcxNTciLCJqdGkiOiIwMTIyYzkxZDE1NzY4ZTA4YzQ3YzMyZTJmZjczYWE1MjgxZWE0NmRkZWI3NzYwODNkMjdiMTc0ZWYyYWM4NmFjYTg3NjgyN2I3MDNjMTk0MyIsImlhdCI6MTY0ODk2Nzk4OSwibmJmIjoxNjQ4OTY3OTg5LCJleHAiOjE2NTE1NTk5ODksInN1YiI6IlVzZXIuMmZkODQ5NzAtMDU3Ni0xMWVjLTlmYTAtY2RkODY4MGNmZjM2Iiwic2NvcGVzIjpbXX0.3JAeX78kd_q7wDcFBk8uLuKDPxoQ-GAV_E2hNx8bZzfrPKozF2lPAdvbstGn3x42nfGEup5ZUo4rJxNaNqrjdGhcljRA5HaRwUukkJvmHa4-XPR0Ziru625exGeJlAbz_MZa4_sc4_13aUOFyrHwZzurmmWbsBanIf6OY4Y10-idFNgaNyDGzpXY8J8ZVPke5MI7plVl42JChdpeKj-ungbUx4EaDY4AS-gTAYjFFOEIWlcWTfE3TgZgJ5RDffE5Lh1voaHFBYxcmH5b51GMwryzti-z-ChqF25b2qlvxzOfB3sHEptJB1453mLvTKEs_xHKVTBtvNM3HdNxe3WU9nrWHo9WYTxGWjSyNHrL5bEKtLss4xhTbyVejp08P_aMczRrxVtl9K1_ilyDxnO3tDpSxSUPJVmHVvwfNkSH6cbXqIukIAnCl-SKd6HCIdAFZvSrewDcEOvU_CVMoAfjxPuVgirYSsbbUUZumL4Efsb-QXaiIUcAJGoUBoLRjxTpOulr5i4gCnZjaVsd5Yz1tBsS_4IkCNXl761-L7gXdRNqj06EkHh9ROVk7dFBEHAo_dxqADvwpIGzHpD9b0e8TT1vFJVooo46TntHgedMi6yHpzdz5fZc7J_EUGW9mq6pT8zd_umFyPiTwXa9FPMzso5eg2cYfI9Wp3n8-EIb70s',
                );
                core = await Flowder.download(
                    'https://api.b-amooz.com/kids/download?version=1',
                    options);
              },
              child: Text('DOWNLOAD'),
            ),
            ElevatedButton(
              onPressed: () async => core.resume(),
              child: Text('RESUME'),
            ),
            ElevatedButton(
              onPressed: () async => core.cancel(),
              child: Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async => core.pause(),
              child: Text('PAUSE'),
            ),
          ],
        ),
      ),
    );
  }
}
