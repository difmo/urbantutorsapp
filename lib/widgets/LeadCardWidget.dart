// import 'package:flutter/material.dart';
// import 'package:urbantutorsapp/models/lead__model.dart';
// import '../theme/theme_constants.dart';

// class LeadCardWidget extends StatelessWidget {
//   final StudentLead lead;
//   final VoidCallback onTap;

//   const LeadCardWidget({
//     super.key,
//     required this.lead,
//     required this.onTap,
//   });

//   // ---------- helpers ----------
//   String _s(dynamic v, [String fallback = '—']) {
//     if (v == null) return fallback;
//     final t = v.toString().trim();
//     return t.isEmpty ? fallback : t;
//   }

//   int _i(dynamic v) {
//     if (v == null) return 0;
//     if (v is num) return v.toInt();
//     return int.tryParse(v.toString()) ?? 0;
//   }

//   double _d(dynamic v) {
//     if (v == null) return 0;
//     if (v is num) return v.toDouble();
//     return double.tryParse(v.toString()) ?? 0;
//   }

//   String _dateIsoToPretty(dynamic v) {
//     final raw = _s(v, '');
//     if (raw.isEmpty) return '—';
//     final dt = DateTime.tryParse(raw);
//     if (dt == null) return raw;
//     const m = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
//   }

//   String _priceOrCoins(dynamic price, dynamic coins) {
//     final c = _s(coins, '');
//     if (c.isNotEmpty && c != 'null') return c;
//     final p = _d(price);
//     if (p == 0) return '0';
//     return p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primary = AppColors.primaryColor;
//     final accent = AppColors.accentColor;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: const [
//             BoxShadow(
//                 color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------- Header ----------
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: primary.withOpacity(.12),
//                   child: Text(
//                     (lead.studentName.isNotEmpty ? lead.studentName[0] : 'S')
//                         .toUpperCase(),
//                     style:
//                         TextStyle(color: primary, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: -6,
//                         crossAxisAlignment: WrapCrossAlignment.center,
//                         children: [
//                           Text(
//                             lead.studentName,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           _ChipPill(
//                             text: 'Lead #${lead.id}',
//                             icon: Icons.confirmation_number,
//                             color: accent,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         lead.createdAt.toString(),
//                         style: TextStyle(
//                             fontSize: 12, color: Colors.grey.shade600),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 _ModeBadge(mode: lead.mode),
//               ],
//             ),

//             const SizedBox(height: 10),

//             // ---------- Details chips (Wrap prevents overflow) ----------
//             Wrap(
//               spacing: 12,
//               runSpacing: 8,
//               children: [
//                 _InfoRow(
//                     icon: Icons.menu_book,
//                     label: 'Subject',
//                     value: lead.subjectName),
//                 _InfoRow(
//                     icon: Icons.school, label: 'Class', value: lead.courseName),
//                 _InfoRow(
//                     icon: Icons.badge, label: 'Board', value: lead.boardName),
//                 _InfoRow(
//                     icon: Icons.location_on,
//                     label: 'Location',
//                     value: lead.location,
//                     maxWidth: 280),
//                 _InfoRow(
//                     icon: Icons.groups_2,
//                     label: 'Teachers',
//                     value: '${lead.typeOfTeacher} connected'),
//                 _InfoRow(
//                     icon: Icons.countertops,
//                     label: 'Responded',
//                     value: '${lead.userId} / 3'),
//                 _InfoRow(
//                     icon: Icons.verified,
//                     label: 'Status',
//                     value: _statusText(
//                         lead.status!.toInt(), lead.status!.toInt())),
//               ],
//             ),

//             Text('ℹ️ ${lead.remark.toString()}',
//                 style: const TextStyle(fontSize: 13, color: Colors.black87)),
//             if (lead.remark.toString() != "")
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text('${lead.remark.toString()}',
//                     style:
//                         const TextStyle(fontSize: 13, color: Colors.black87)),
//               ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   String _statusText(int leadStatus, int fakeStatus) {
//     if (fakeStatus == 1) return 'Flagged';
//     switch (leadStatus) {
//       case 0:
//         return 'New';
//       case 1:
//         return 'Assigned';
//       case 2:
//         return 'Closed';
//       default:
//         return 'Unknown';
//     }
//   }
// }

// // ---------------- small UI parts ----------------

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.maxWidth,
//   });

//   final IconData icon;
//   final String label;
//   final String value;
//   final double? maxWidth;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: Colors.blueGrey),
//           const SizedBox(width: 6),
//           ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: maxWidth ?? 220),
//             child: Text.rich(
//               TextSpan(
//                 children: [
//                   const TextSpan(
//                     text: '',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   TextSpan(
//                     text: '$label: ',
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   TextSpan(
//                     text: value,
//                     style: const TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                 ],
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ModeBadge extends StatelessWidget {
//   const _ModeBadge({required this.mode});
//   final String mode;

//   @override
//   Widget build(BuildContext context) {
//     final isOnline = mode.toLowerCase() == 'online';
//     final color = isOnline ? Colors.green : Colors.deepOrange;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.12),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: color.withOpacity(.35)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(isOnline ? Icons.wifi : Icons.home_work_outlined,
//               size: 14, color: color),
//           const SizedBox(width: 6),
//           Text(mode,
//               style: TextStyle(
//                   color: color, fontWeight: FontWeight.w700, fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

// class _CoinsBadge extends StatelessWidget {
//   const _CoinsBadge({required this.text, required this.accent});
//   final String text;
//   final Color accent;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: accent.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: accent.withOpacity(.35)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.monetization_on, size: 16, color: accent),
//           const SizedBox(width: 4),
//           Text('$text coins',
//               style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   const _ActionButton(
//       {required this.icon, required this.label, required this.onTap});
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       style: OutlinedButton.styleFrom(
//         visualDensity: VisualDensity.compact,
//         side: BorderSide(color: Colors.blueGrey.shade200),
//         foregroundColor: Colors.blueGrey.shade800,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       onPressed: onTap,
//       icon: Icon(icon, size: 16),
//       label: Text(label),
//     );
//   }
// }

// class _ChipPill extends StatelessWidget {
//   const _ChipPill(
//       {required this.text, required this.icon, required this.color});
//   final String text;
//   final IconData icon;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.12),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: color.withOpacity(.35)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(text,
//               style: TextStyle(
//                   color: color, fontSize: 11, fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
// }
