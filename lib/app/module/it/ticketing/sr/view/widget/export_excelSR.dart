import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import '../../model/sr_model.dart';

void exportServiceRequestsToExcel(List<ServiceRequestModel> requests) {
  final excel = Excel.createExcel();
  final sheet = excel['Service Requests'];

  final headers = [
    'SR Number',
    'Request Title',
    'Employee',
    'Department',
    'Request Type',
    'Category',
    'Quantity',
    'Priority',
    'Status',
    'Description',
    'Needed By',
    'Approver',
    'Reviewed At',
    'Rejection Reason',
    'Submitted At',
  ];

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

  const typeLabels = {
    'asset_request': 'Asset request',
    'software_installation': 'Software installation',
    'account_access': 'Account access',
    'other': 'Other',
  };

  for (var i = 0; i < requests.length; i++) {
    final sr = requests[i];
    final rowIndex = i + 1;

    final values = [
      sr.srNumber,
      sr.requestTitle,
      sr.requesterName ?? '',
      sr.requesterDepartment ?? '',
      typeLabels[sr.requestType] ?? sr.requestType,
      sr.category,
      sr.quantity.toString(),
      sr.priority,
      sr.status,
      sr.description,
      sr.neededByDate.toIso8601String().split('T').first,
      sr.approverName ?? '',
      sr.reviewedAt?.toIso8601String() ?? '',
      sr.rejectionReason ?? '',
      sr.createdAt.toIso8601String(),
    ];

    for (var j = 0; j < values.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex))
          .value = TextCellValue(values[j]);
    }
  }

  final widths = [14.0, 26.0, 18.0, 16.0, 20.0, 16.0, 10.0, 12.0, 12.0, 36.0, 14.0, 16.0, 18.0, 30.0, 20.0];
  for (var i = 0; i < widths.length; i++) {
    sheet.setColumnWidth(i, widths[i]);
  }

  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [Uint8List.fromList(bytes)],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..setAttribute('download', 'service_requests_export.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}