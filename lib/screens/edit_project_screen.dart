import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart'; // تغيير إلى مزود المشاريع الحقيقي
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class EditProjectScreen extends StatefulWidget {
  static const routeName = '/edit-project';

  final Project project;

  const EditProjectScreen({Key? key, required this.project}) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // حقول النموذج
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _teamController;
  late TextEditingController _costController;
  
  late DateTime? _startDate;
  late DateTime? _endDate;
  late ProjectStatus _status;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    // تعبئة النموذج ببيانات المشروع الحالي
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _teamController = TextEditingController(text: ''); // يمكن إضافة الفريق لاحقًا
    _costController = TextEditingController(text: ''); // يمكن إضافة التكلفة لاحقًا
    
    _startDate = widget.project.startDate;
    _endDate = widget.project.endDate;
    _status = widget.project.status;
    _isCompleted = widget.project.status == ProjectStatus.completed;
  }

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

    // إنشاء كائن المشروع المُحدّث
    final updatedProject = widget.project.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      updatedAt: DateTime.now(),
    );

    try {
      // تحديث المشروع باستخدام مزود المشاريع
      final success = await Provider.of<ProjectsProvider>(context, listen: false)
          .updateProject(updatedProject);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث المشروع بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.of(context).pop(true); // العودة مع إشارة إلى التحديث الناجح
      } else {
        final provider = Provider.of<ProjectsProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'فشل تحديث المشروع'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: AppColors.errorColor,
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
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryTextColor,
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
          // إذا كان تاريخ البدء بعد تاريخ الانتهاء، قم بتعديل تاريخ الانتهاء
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
        title: const Text('تعديل المشروع'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المشروع
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'اسم المشروع',
                  hintText: 'أدخل اسم المشروع',
                  prefixIcon: Icon(Icons.title_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المشروع';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // تفاصيل المشروع
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'تفاصيل المشروع',
                  hintText: 'أدخل وصف المشروع',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // حالة الاكتمال
              SwitchListTile(
                title: Text('المشروع مكتمل'),
                subtitle: Text(_isCompleted 
                    ? 'سيتم تعيين حالة المشروع كمكتمل' 
                    : 'اترك هذا الخيار إذا كان المشروع غير مكتمل'),
                value: _isCompleted,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // حالة المشروع (إذا لم يكن مكتملاً)
              if (!_isCompleted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة المشروع',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildStatusSelector(),
                    SizedBox(height: 20),
                  ],
                ),

              // أسماء فريق المشروع
              TextFormField(
                controller: _teamController,
                decoration: InputDecoration(
                  labelText: 'أسماء فريق المشروع',
                  hintText: 'أدخل أسماء أعضاء الفريق مفصولة بفواصل',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
              SizedBox(height: 20),

              // تكلفة المشروع
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: 'تكلفة المشروع',
                  hintText: 'أدخل تكلفة المشروع',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // تاريخ البدء والانتهاء
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'تاريخ البدء',
                      value: _startDate,
                      onTap: () => _selectDate(context, true),
                      icon: Icons.calendar_today,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'تاريخ الانتهاء',
                      value: _endDate,
                      onTap: () => _selectDate(context, false),
                      icon: Icons.event_available,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // زر الحفظ
              CustomButton(
                text: 'حفظ التغييرات',
                isLoading: _isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildStatusOption(
            title: 'لم يبدأ',
            status: ProjectStatus.notStarted,
            color: Colors.grey,
          ),
          Divider(height: 1),
          _buildStatusOption(
            title: 'قيد التنفيذ',
            status: ProjectStatus.inProgress,
            color: AppColors.statusInProgress,
          ),
          Divider(height: 1),
          _buildStatusOption(
            title: 'متأخر',
            status: ProjectStatus.delayed,
            color: AppColors.statusDelayed,
          ),
          Divider(height: 1),
          _buildStatusOption(
            title: 'ملغي',
            status: ProjectStatus.cancelled,
            color: AppColors.statusCancelled,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String title,
    required ProjectStatus status,
    required Color color,
  }) {
    return RadioListTile<ProjectStatus>(
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: _status == status ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      value: status,
      groupValue: _status,
      activeColor: color,
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
    );
  }

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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.inputFillColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  value != null ? dateFormat.format(value) : 'اختر التاريخ',
                  style: TextStyle(
                    color: value != null
                        ? AppColors.primaryTextColor
                        : AppColors.secondaryTextColor,
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