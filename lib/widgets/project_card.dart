import 'package:flutter/material.dart';
import '../models/project.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تدرجات اللون الأزرق
    final blueGradient = LinearGradient(
      colors: [
        Color(0xFF2196F3),
        Color(0xFF0D47A1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // عنوان المشروع مع أيقونة
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: blueGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              project.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // حالة المشروع
                    _buildStatusChip(project.status),
                  ],
                ),
                if (project.description != null && project.description!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 14, bottom: 14, right: 38),
                    child: Text(
                      project.description!,
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFE0E0E0),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // تاريخ البدء
                    _buildDateInfo(
                      icon: Icons.calendar_today_rounded,
                      label: 'البدء',
                      date: project.startDate,
                      blueGradient: blueGradient,
                    ),
                    // تاريخ الانتهاء
                    _buildDateInfo(
                      icon: Icons.event_available_rounded,
                      label: 'الانتهاء',
                      date: project.endDate,
                      blueGradient: blueGradient,
                    ),
                  ],
                ),
                // شريط التقدم في أسفل البطاقة
                if (project.status == ProjectStatus.inProgress)
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 200, // يمكن استبدالها بقيمة نسبة التقدم الفعلية
                          decoration: BoxDecoration(
                            gradient: blueGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    // تحديد اللون والنص حسب حالة المشروع
    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case ProjectStatus.notStarted:
        chipColor = Colors.grey;
        statusText = 'لم يبدأ';
        statusIcon = Icons.hourglass_empty;
        break;
      case ProjectStatus.inProgress:
        chipColor = Color(0xFF3498DB); // لون أزرق متناسق مع التدرج
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.loop;
        break;
      case ProjectStatus.completed:
        chipColor = Color(0xFF2ECC71);
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle;
        break;
      case ProjectStatus.delayed:
        chipColor = Color(0xFFE74C3C);
        statusText = 'متأخر';
        statusIcon = Icons.warning;
        break;
      case ProjectStatus.cancelled:
        chipColor = Color(0xFF7F8C8D);
        statusText = 'ملغي';
        statusIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'غير معروف';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required DateTime? date,
    required LinearGradient blueGradient,
  }) {
    final dateFormatter = DateFormat.yMd('ar');
    final formattedDate = date != null
        ? dateFormatter.format(date)
        : 'غير محدد';

    return Row(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return blueGradient.createShader(bounds);
          },
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495E),
          ),
        ),
        SizedBox(width: 4),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }
}