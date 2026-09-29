import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hfatdxywgotymiajrxbq.supabase.co',
    publishableKey: 'sb_publishable_tGktLOOuB4MNT8BcbDj4XA_mOyAActH',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تسجيل الطالب',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StudentAuthPage(),
    );
  }
}

class StudentAuthPage extends StatefulWidget {
  const StudentAuthPage({super.key});

  @override
  State<StudentAuthPage> createState() => _StudentAuthPageState();
}

class _StudentAuthPageState extends State<StudentAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _universityIdController = TextEditingController();

  bool _isSignUp = true;
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _universityIdController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final universityId = _universityIdController.text.trim();

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,

          // يجب أن تتطابق هذه المفاتيح مع ما يقرأه
          // trigger الموجود في قاعدة البيانات.
          data: {
            'account_type': 'student',
            'university_id': universityId,
          },
        );

        if (response.session == null) {
          _showMessage(
            'تم إرسال طلب التسجيل. افتح رسالة التأكيد في بريدك، '
                'ثم ارجع إلى التطبيق وسجّل الدخول.',
          );
        } else if (response.user != null) {
          await _checkStudentProfile(response.user!.id);
        }
      } else {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user == null) {
          _showMessage('تم تسجيل الدخول، لكن لم يرجع حساب المستخدم.');
          return;
        }

        await _checkStudentProfile(response.user!.id);
      }
    } on AuthException catch (error) {
      _showMessage('تعذّر إتمام العملية: ${error.message}');
    } catch (error) {
      _showMessage('حدث خطأ غير متوقع: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkStudentProfile(String userId) async {
    final profile = await supabase
        .from('profiles')
        .select('name, university_id, department_id, batch_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (!mounted) return;

    if (profile == null) {
      _showMessage(
        'تم تسجيل الدخول، لكن لم يظهر ملف الطالب. '
            'تأكد من تأكيد البريد، وأن الرقم الجامعي موجود وغير مربوط بحساب آخر.',
      );
      return;
    }

    final studentName = profile['name'] ?? 'الطالب';

    _showMessage('أهلًا $studentName، تم تسجيل الدخول وربط ملفك بنجاح.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'إنشاء حساب طالب' : 'تسجيل دخول الطالب'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.school, size: 72),
                    const SizedBox(height: 24),

                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _universityIdController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'الرقم الجامعي',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isSignUp &&
                              (value == null || value.trim().isEmpty)) {
                            return 'أدخل الرقم الجامعي';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'أدخل البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'تحقق من صيغة البريد الإلكتروني';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'أدخل كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _isSignUp
                            ? 'إنشاء الحساب'
                            : 'تسجيل الدخول',
                      ),
                    ),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        setState(() => _isSignUp = !_isSignUp);
                      },
                      child: Text(
                        _isSignUp
                            ? 'لدي حساب بالفعل؟ تسجيل الدخول'
                            : 'ليس لدي حساب؟ إنشاء حساب طالب',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




