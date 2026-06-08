import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import '../../model/asset_model.dart';

void exportAssetsToExcel(List<AssetModel> assets) {
  final excel = Excel.createExcel();
  final sheet = excel['Assets'];

  // ── Header — ikut susunan AssetModel ──────────────────────────────────
  final headers = [
    'ID',
    'Asset Tag',
    'Serial Number',
    'Brand',
    'Model',
    'Category',
    'Status',
    'Assigned To',
    'Department',
    'Employee ID',
    'Approved By',
    'Purchased By',
    'Remark',
  ];

  // Style header
  for (var i = 0; i < headers.length; i++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
    );
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#185FA5'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  // ── Rows — ikut susunan field dalam AssetModel ─────────────────────────
  for (var i = 0; i < assets.length; i++) {
    final a = assets[i];
    final rowIndex = i + 1;

    final values = [
      a.id.toString(),
      a.assetTag,
      a.serialNumber ?? '',
      a.brand ?? '',
      a.model ?? '',
      a.categoryName ?? '',
      a.status ?? '',
      a.assignedTo ?? '',
      a.department ?? '',
      a.empId ?? '',
      a.approvedBy ?? '',
      a.purchasedBy ?? '',
      a.remark ?? '',
    ];

    for (var j = 0; j < values.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex))
          .value = TextCellValue(values[j]);
    }
  }

  // ── Auto column width ─────────────────────────────────────────────────
  final widths = [6.0, 12.0, 18.0, 14.0, 18.0, 14.0, 14.0,
                  20.0, 16.0, 14.0, 18.0, 18.0, 30.0];
  for (var i = 0; i < widths.length; i++) {
    sheet.setColumnWidth(i, widths[i]);
  }

  // ── Download ──────────────────────────────────────────────────────────
  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [Uint8List.fromList(bytes)],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url  = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..setAttribute('download', 'assets_export.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}