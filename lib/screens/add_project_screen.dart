import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class AddProjectScreen extends StatefulWidget {
  static const routeName = '/add-project';

  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // حقول النموذج
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _teamController = TextEditingController();
  final _costController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  ProjectStatus _status = ProjectStatus.notStarted;
  bool _isCompleted = false;

  // تدرجات اللون الأزرق - متناسقة مع ProjectCard
  LinearGradient get blueGradient => LinearGradient(
    colors: [
      Color(0xFF2196F3),
      Color(0xFF0D47A1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ألوان متناسقة مع التصميم الجديد
  Color get primaryBlue => Color(0xFF2196F3);
  Color get darkBlue => Color(0xFF0D47A1);
  Color get textColor => Color(0xFF2C3E50);
  Color get secondaryTextColor => Color(0xFF7F8C8D);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _teamController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // تحديث حالة المشروع بناءً على اكتمال المشروع
    if (_isCompleted) {
      _status = ProjectStatus.completed;
    }

    // الحصول على معرف المستخدم الحالي
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 1;
    
    // إنشاء كائن المشروع الجديد
    final newProject = Project(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      userId: userId,
      createdAt: DateTime.now(),
    );

    try {
      // إضافة المشروع باستخدام مزود المشاريع
      final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
      
      if (projectsProvider.getCurrentUserId() == null) {
        projectsProvider.setCurrentUserId(userId);
      }
      
      final success = await projectsProvider.addProject(newProject);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة المشروع بنجاح'),
            backgroundColor: Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(projectsProvider.errorMessage ?? 'فشل إضافة المشروع'),
            backgroundColor: Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartDate 
        ? _startDate ?? now 
        : _endDate ?? (_startDate != null ? _startDate!.add(Duration(days: 7)) : now);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(now.year - 1) : (_startDate ?? DateTime(now.year - 1)),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && picked.isAfter(_endDate!)) {
            _endDate = picked.add(Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مشروع جديد'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: blueGradient,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان الصفحة
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) => blueGradient.createShader(bounds),
                    child: Text(
                      'بيانات المشروع الجديد',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // بطاقة المعلومات الأساسية
                _buildCard(
                  title: 'المعلومات الأساسية',
                  icon: Icons.info_outline,
                  children: [
                    // اسم المشروع
                    _buildTextField(
                      controller: _titleController,
                      labelText: 'اسم المشروع',
                      hintText: 'أدخل اسم المشروع',
                      prefixIcon: Icons.title_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المشروع';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // تفاصيل المشروع
                    _buildTextField(
                      controller: _descriptionController,
                      labelText: 'تفاصيل المشروع',
                      hintText: 'أدخل وصف المشروع',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // بطاقة الحالة
                _buildCard(
                  title: 'حالة المشروع',
                  icon: Icons.assignment_outlined,
                  children: [
                    // حالة الاكتمال
                    _buildCompletionSwitch(),
                    
                    // حالة المشروع (إذا لم يكن مكتملاً)
                    if (!_isCompleted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر حالة المشروع:',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildStatusSelector(),
                        ],
                      ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // بطاقة المعلومات الإضافية
                _buildCard(
                  title: 'معلومات إضافية',
                  icon: Icons.more_horiz,
                  children: [
                    // أسماء فريق المشروع
                    _buildTextField(
                      controller: _teamController,
                      labelText: 'أسماء فريق المشروع',
                      hintText: 'أدخل أسماء أعضاء الفريق مفصولة بفواصل',
                      prefixIcon: Icons.people_outline,
                    ),
                    SizedBox(height: 16),

                    // تكلفة المشروع
                    _buildTextField(
                      controller: _costController,
                      labelText: 'تكلفة المشروع',
                      hintText: 'أدخل تكلفة المشروع',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // بطاقة التواريخ
                _buildCard(
                  title: 'تواريخ المشروع',
                  icon: Icons.date_range,
                  children: [
                    // تاريخ البدء والانتهاء
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'تاريخ البدء',
                            value: _startDate,
                            onTap: () => _selectDate(context, true),
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            label: 'تاريخ الانتهاء',
                            value: _endDate,
                            onTap: () => _selectDate(context, false),
                            icon: Icons.event_available_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 40),

                // زر الحفظ
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    gradient: blueGradient,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'حفظ المشروع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء بطاقة محتوى
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان البطاقة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: blueGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // محتوى البطاقة
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // بناء حقل نصي
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => blueGradient.createShader(bounds),
          child: Icon(
            prefixIcon,
            color: Colors.white,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE74C3C), width: 1),
        ),
        labelStyle: TextStyle(color: textColor),
        hintStyle: TextStyle(color: secondaryTextColor),
        alignLabelWithHint: maxLines > 1,
      ),
      style: TextStyle(color: textColor),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // بناء مفتاح الاكتمال
  Widget _buildCompletionSwitch() {
    return Container(
      margin: EdgeInsets.only(bottom: _isCompleted ? 0 : 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isCompleted 
            ? Color(0xFF2ECC71).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCompleted 
              ? Color(0xFF2ECC71).withOpacity(0.5)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Switch(
              value: _isCompleted,
              activeColor: Color(0xFF2ECC71),
              activeTrackColor: Color(0xFF2ECC71).withOpacity(0.5),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المشروع مكتمل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCompleted 
                        ? Color(0xFF2ECC71)
                        : textColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _isCompleted 
                      ? 'سيتم تعيين حالة المشروع كمكتمل' 
                      : 'اترك هذا الخيار إذا كان المشروع غير مكتمل',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء اختيار الحالة
  Widget _buildStatusSelector() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusOption(
            title: 'لم يبدأ',
            subtitle: 'المشروع في مرحلة التخطيط ولم يبدأ بعد',
            status: ProjectStatus.notStarted,
            color: Colors.grey,
            icon: Icons.hourglass_empty,
          ),
          _buildStatusDivider(),
          _buildStatusOption(
            title: 'قيد التنفيذ',
            subtitle: 'بدأ العمل على المشروع',
            status: ProjectStatus.inProgress,
            color: Color(0xFF3498DB),
            icon: Icons.loop,
          ),
          _buildStatusDivider(),
          _buildStatusOption(
            title: 'متأخر',
            subtitle: 'المشروع متأخر عن الجدول الزمني',
            status: ProjectStatus.delayed,
            color: Color(0xFFE74C3C),
            icon: Icons.warning_rounded,
          ),
          _buildStatusDivider(),
          _buildStatusOption(
            title: 'ملغي',
            subtitle: 'تم إلغاء المشروع',
            status: ProjectStatus.cancelled,
            color: Color(0xFF7F8C8D),
            icon: Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  // فاصل بين خيارات الحالة
  Widget _buildStatusDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade200,
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  // خيار من خيارات الحالة
  Widget _buildStatusOption({
    required String title,
    required String subtitle,
    required ProjectStatus status,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _status == status;
    
    return RadioListTile<ProjectStatus>(
      title: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
        ),
      ),
      value: status,
      groupValue: _status,
      activeColor: color,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
    );
  }

  // حقل التاريخ
  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final dateFormat = DateFormat.yMd('ar');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => blueGradient.createShader(bounds),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  value != null ? dateFormat.format(value) : 'اختر التاريخ',
                  style: TextStyle(
                    color: value != null
                        ? textColor
                        : secondaryTextColor,
                    fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}