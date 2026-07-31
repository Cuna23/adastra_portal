import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view model/calendar_vm.dart';
import 'reminder_dialog.dart';

class CalendarWidget extends StatelessWidget {
  final String token;
  const CalendarWidget({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel()..fetchEvents(token),
      child: _CalendarBody(token: token),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  final String token;
  const _CalendarBody({required this.token});

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final today = DateTime.now();

    final firstOfMonth = vm.focusedMonth;
    final daysInMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7; // Sun=0

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF185FA5), Color(0xFF2E7BC6)], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => vm.previousMonth(token), icon: const Icon(Icons.chevron_left_rounded, size: 20, color: Colors.white), splashRadius: 18),
                Text('${_months[vm.focusedMonth.month - 1]} ${vm.focusedMonth.year}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                IconButton(onPressed: () => vm.nextMonth(token), icon: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white), splashRadius: 18),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: vm.isLoading
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
                : Column(
                    children: [
                      Row(
                        children: _weekdays
                            .map((w) => Expanded(
                                  child: Center(child: Text(w, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9AA5B1)))),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                      ..._buildWeeks(context, vm, today, daysInMonth, startWeekday),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(BuildContext context, CalendarViewModel vm, DateTime today, int daysInMonth, int startWeekday) {
    final weeks = <Widget>[];
    var dayCounter = 1 - startWeekday;

    while (dayCounter <= daysInMonth) {
      final cells = <Widget>[];
      for (int i = 0; i < 7; i++) {
        if (dayCounter < 1 || dayCounter > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 44)));
        } else {
          final date = DateTime(vm.focusedMonth.year, vm.focusedMonth.month, dayCounter);
          final dayEvents = vm.eventsOn(date);
          final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          final hasOverdue = dayEvents.any((e) => e.overdue);

          cells.add(Expanded(
            child: InkWell(
              onTap: () {
                if (dayEvents.isEmpty) {
                  _promptAddReminder(context, vm, date);
                } else {
                  ReminderDialogs.showDayEvents(context, date, dayEvents, onDeleteReminder: (id) => vm.deleteReminder(token, id));
                }
              },
              onLongPress: () => _promptAddReminder(context, vm, date),
              child: SizedBox(
                height: 44,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? const Color(0xFF185FA5) : Colors.transparent,
                        border: (!isToday && dayEvents.isNotEmpty) ? Border.all(color: const Color(0xFF185FA5), width: 1) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayCounter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? Colors.white : const Color(0xFF1B1E28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (dayEvents.isNotEmpty)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: hasOverdue ? const Color(0xFFD64545) : const Color(0xFFD64545)),
                      )
                    else
                      const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ));
        }
        dayCounter++;
      }
      weeks.add(Row(children: cells));
    }
    return weeks;
  }

  Future<void> _promptAddReminder(BuildContext context, CalendarViewModel vm, DateTime date) async {
    final result = await ReminderDialogs.addReminderForm(context, date);
    if (result == null) return;
    final ok = await vm.addReminder(token, result['title']!, result['note'], date);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Reminder added.' : 'Failed to add reminder.'),
        backgroundColor: ok ? const Color(0xFF2E7D52) : const Color(0xFFD64545),
      ),
    );
  }
}