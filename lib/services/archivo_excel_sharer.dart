import 'package:share_plus/share_plus.dart';

import 'movimientos_excel_exporter.dart';

class ArchivoExcelSharer {
  const ArchivoExcelSharer();

  Future<void> compartir(ArchivoExcelMovimientos archivo) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            archivo.bytes,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        fileNameOverrides: [archivo.nombre],
        subject: 'Reporte de Economía del Hogar',
      ),
    );
  }
}
