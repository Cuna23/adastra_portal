import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import '../../model/incident_model.dart';

void exportIncidentsToExcel(List<IncidentModel> incidents) {
  final excel = Excel.createExcel();
  final sheet = excel['Incidents'];

  // ── Header — ikut susunan IncidentModel ──────────────────────────────
  final headers = [
    'Ticket No',
    'Subject',
    'Issuer',
    'Category',
    'Priority',
    'Status',
    'Assigned To',
    'Description',
    'Resolution',
    'Created At',
    'Updated At',
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

  // ── Rows — ikut susunan field dalam IncidentModel ────────────────────
  for (var i = 0; i < incidents.length; i++) {
    final inc = incidents[i];
    final rowIndex = i + 1;

    final assignedLabel = inc.assignedUser == null
        ? 'Pending'
        : (inc.assignedUser!.role == 'super_admin'
            ? 'IT'
            : inc.assignedUser!.name);

    final values = [
      inc.ticketNo,
      inc.subject,
      inc.user?.name ?? '',
      inc.category,
      inc.priority,
      inc.status,
      assignedLabel,
      inc.description,
      inc.resolution ?? '',
      inc.createdAt,
      inc.updatedAt,
    ];

    for (var j = 0; j < values.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex))
          .value = TextCellValue(values[j]);
    }
  }

  // ── Auto column width ─────────────────────────────────────────────────
  final widths = [14.0, 24.0, 16.0, 14.0, 12.0, 14.0, 16.0, 36.0, 30.0, 20.0, 20.0];
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
    ..setAttribute('download', 'incidents_export.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}