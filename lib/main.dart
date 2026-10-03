import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final store = await AppStore.create();
  runApp(FlexiblePackagingApp(store: store));
}

class AppStore extends ChangeNotifier {
  AppStore._();

  final FirebaseService firebase = FirebaseService.instance;
  late SharedPreferences prefs;
  StreamSubscription<User?>? _authSubscription;

  String language = 'বাংলা';
  String? userName;
  String? userEmail;
  String? userPhone;
  bool loggedIn = false;
  bool isAdmin = false;

  final List<Job> jobs = List<Job>.from(demoJobs);
  final Set<String> saved = <String>{};
  final List<ApplicationItem> applications = <ApplicationItem>[];
  final List<NewsItem> news = List<NewsItem>.from(demoNews);

  bool get isBangla => language == 'বাংলা';

  static Future<AppStore> create() async {
    final store = AppStore._();
    store.prefs = await SharedPreferences.getInstance();
    store.language = store.prefs.getString('language') ?? 'বাংলা';
    store.userName = store.prefs.getString('name');
    store.userEmail = store.prefs.getString('email');
    store.userPhone = store.prefs.getString('phone');
    store.saved.addAll(store.prefs.getStringList('saved') ?? <String>[]);

    final user = store.firebase.auth.currentUser;
    if (user != null) {
      await store._syncUser(user);
    }

    store._authSubscription = store.firebase.auth.authStateChanges().listen(
      (user) async {
        if (user == null) {
          store.loggedIn = false;
          store.isAdmin = false;
        } else {
          await store._syncUser(user);
        }
        await store.persist();
      },
    );

    return store;
  }

  Future<void> _syncUser(User user) async {
    loggedIn = true;
    userEmail = user.email;
    try {
      final profile = await firebase.getUserProfile(user.uid);
      final data = profile.data();
      if (data != null) {
        userName = data['name']?.toString() ?? userName;
        userPhone = data['phone']?.toString() ?? userPhone;
      }
    } catch (_) {
      // Local profile remains available if Firestore is temporarily unavailable.
    }

    try {
      final token = await user.getIdTokenResult(true);
      isAdmin = token.claims?['admin'] == true;
    } catch (_) {
      isAdmin = false;
    }

    try {
      await firebase.registerMessagingToken(user.uid);
    } catch (_) {
      // Notifications are optional and must not block login.
    }
  }

  Future<void> registerAccount({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final credential = await firebase.register(email, password);
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-null', message: 'Account creation failed.');
    }

    userName = name;
    userEmail = email;
    userPhone = phone;
    loggedIn = true;
    isAdmin = false;

    await firebase.saveUserProfile(user.uid, <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firebase.sendEmailVerification();
    await persist();
  }

  Future<void> loginWithPassword(String email, String password) async {
    final credential = await firebase.login(email, password);
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-null', message: 'Login failed.');
    }
    await _syncUser(user);
    await persist();
  }

  Future<void> resetPassword(String email) => firebase.sendPasswordReset(email);

  Future<void> resendVerification() => firebase.sendEmailVerification();

  Future<void> logout() async {
    await firebase.logout();
    loggedIn = false;
    isAdmin = false;
    await persist();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    await persist();
  }

  Future<void> toggleSaved(String jobId) async {
    if (saved.contains(jobId)) {
      saved.remove(jobId);
    } else {
      saved.add(jobId);
    }
    await persist();
  }

  void addApplication(String jobId) {
    if (!applications.any((item) => item.jobId == jobId)) {
      applications.add(
        ApplicationItem(
          jobId: jobId,
          date: DateTime.now(),
          status: 'Under Review',
        ),
      );
      notifyListeners();
    }
  }

  void addJob(Job job) {
    jobs.insert(0, job);
    notifyListeners();
  }

  void removeJob(String id) {
    jobs.removeWhere((job) => job.id == id);
    notifyListeners();
  }

  Future<void> persist() async {
    await prefs.setString('language', language);
    await prefs.setStringList('saved', saved.toList());
    if (userName != null) {
      await prefs.setString('name', userName!);
    }
    if (userEmail != null) {
      await prefs.setString('email', userEmail!);
    }
    if (userPhone != null) {
      await prefs.setString('phone', userPhone!);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class Job {
  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.posted,
    required this.deadline,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final DateTime posted;
  final DateTime deadline;

  int get remainingDays => max(0, deadline.difference(DateTime.now()).inDays);
}

class ApplicationItem {
  ApplicationItem({
    required this.jobId,
    required this.date,
    required this.status,
  });

  final String jobId;
  final DateTime date;
  final String status;
}

class NewsItem {
  const NewsItem(this.title, this.text);

  final String title;
  final String text;
}

final List<Job> demoJobs = <Job>[
  Job(
    id: 'job-1',
    title: 'Production Operator',
    company: 'Global Packaging Ltd.',
    location: 'Dhaka, Bangladesh',
    salary: '25,000 - 35,000',
    type: 'Full Time',
    description: 'Operate and monitor production machines while maintaining product quality and workplace safety.',
    posted: DateTime.now().subtract(const Duration(hours: 2)),
    deadline: DateTime.now().add(const Duration(days: 14)),
  ),
  Job(
    id: 'job-2',
    title: 'Warehouse Assistant',
    company: 'Fresh Foods Ltd.',
    location: 'Chattogram, Bangladesh',
    salary: '18,000 - 25,000',
    type: 'Full Time',
    description: 'Support warehouse receiving, storage and dispatch operations.',
    posted: DateTime.now().subtract(const Duration(hours: 4)),
    deadline: DateTime.now().add(const Duration(days: 9)),
  ),
  Job(
    id: 'job-3',
    title: 'Sales Executive',
    company: 'ABC Trading Co.',
    location: 'Sylhet, Bangladesh',
    salary: '20,000 - 30,000',
    type: 'Full Time',
    description: 'Manage customers, sales targets and daily reports.',
    posted: DateTime.now().subtract(const Duration(hours: 5)),
    deadline: DateTime.now().add(const Duration(days: 6)),
  ),
  Job(
    id: 'job-4',
    title: 'Quality Control Inspector',
    company: 'Packaging Pack Ltd.',
    location: 'Narayanganj, Bangladesh',
    salary: '22,000 - 30,000',
    type: 'Full Time',
    description: 'Inspect printed film, lamination and pouch quality against specifications.',
    posted: DateTime.now().subtract(const Duration(days: 1)),
    deadline: DateTime.now().add(const Duration(days: 3)),
  ),
];

const List<NewsItem> demoNews = <NewsItem>[
  NewsItem('Breaking News', 'নতুন চাকরির বিজ্ঞপ্তি প্রকাশ হয়েছে। আজই আবেদন করুন।'),
  NewsItem('New Job Alert', 'Flexible Packaging sector-এ নতুন Production Operator পদ যুক্ত হয়েছে।'),
];

class FlexiblePackagingApp extends StatelessWidget {
  const FlexiblePackagingApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flexible Packaging',
          theme: appTheme,
          home: store.loggedIn
              ? (store.isAdmin ? AdminPage(store: store) : HomePage(store: store))
              : SplashPage(store: store),
        );
      },
    );
  }
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF7FAFC),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5CAB)),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  cardTheme: const CardThemeData(
    elevation: 1,
    margin: EdgeInsets.symmetric(vertical: 6),
  ),
);

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 52, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/flexible_packaging_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0B5CAB),
          borderRadius: BorderRadius.circular(size * .22),
        ),
        child: Text(
          'FP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * .32,
          ),
        ),
      ),
    );

    if (!showName) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        logo,
        const SizedBox(height: 8),
        const Text(
          'Flexible\nPackaging',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF073B75),
            fontWeight: FontWeight.w900,
            height: .95,
          ),
        ),
      ],
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.store});

  final AppStore store;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => LanguagePage(store: widget.store)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppLogo(size: 78),
            SizedBox(height: 28),
            Text('Better Jobs • Better Future', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const AppLogo(size: 60),
                const SizedBox(height: 36),
                const Text('Select Language', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                _languageButton(context, 'বাংলা'),
                const SizedBox(height: 12),
                _languageButton(context, 'English', outline: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context, String value, {bool outline = false}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: outline ? Colors.white : const Color(0xFF0B75D1),
          foregroundColor: outline ? const Color(0xFF073B75) : Colors.white,
          side: outline ? const BorderSide(color: Color(0xFF0B75D1)) : null,
        ),
        onPressed: () async {
          await store.setLanguage(value);
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(builder: (_) => LoginPage(store: store)),
          );
        },
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.store});

  final AppStore store;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await widget.store.loginWithPassword(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => HomePage(store: widget.store)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Login failed.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bn = widget.store.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(bn ? 'লগইন' : 'Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: AppLogo(size: 58)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: bn ? 'ইমেইল' : 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: bn ? 'পাসওয়ার্ড' : 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: loading ? null : _login,
                        child: loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(bn ? 'লগইন করুন' : 'Login'),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_email.text.trim().isEmpty) {
                          _showError('Enter your email first.');
                          return;
                        }
                        try {
                          await widget.store.resetPassword(_email.text.trim());
                          _showError('Password reset email sent.');
                        } catch (e) {
                          _showError(e.toString());
                        }
                      },
                      child: Text(bn ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot password?'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute<void>(builder: (_) => RegisterPage(store: widget.store)));
                      },
                      child: Text(bn ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'Create a new account'),
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.store});

  final AppStore store;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await widget.store.registerAccount(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => HomePage(store: widget.store)),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.store.isBangla ? 'অ্যাকাউন্ট তৈরি' : 'Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: _required),
              const SizedBox(height: 12),
              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)')),
              const SizedBox(height: 12),
              TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: loading ? null : _register, child: loading ? const CircularProgressIndicator() : const Text('Create account'))),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final AppStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardTab(store: widget.store),
      JobsPage(store: widget.store),
      ApplicationsPage(store: widget.store),
      TechnicalPage(store: widget.store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flexible Packaging', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => NotificationsPage(store: widget.store))),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      drawer: AppDrawer(store: widget.store),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Applications'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learn'),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0B5CAB)),
            child: Align(alignment: Alignment.bottomLeft, child: AppLogo(size: 50)),
          ),
          ListTile(leading: const Icon(Icons.person_outline), title: Text(store.userName ?? 'Profile'), onTap: () => _open(context, ProfilePage(store: store))),
          ListTile(leading: const Icon(Icons.description_outlined), title: const Text('CV / Resume'), onTap: () => _open(context, CvPage(store: store))),
          ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () => _open(context, SettingsPage(store: store))),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: store.logout),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final featured = store.jobs.take(3).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Hello, ${store.userName ?? 'there'}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Find your next opportunity in the packaging industry.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                const CircleAvatar(radius: 26, child: Icon(Icons.work_outline)),
                const SizedBox(width: 14),
                Expanded(child: Text('${store.jobs.length} active jobs\n${store.applications.length} applications', style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Latest Jobs', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...featured.map((job) => JobCard(store: store, job: job)),
        const SizedBox(height: 12),
        const Text('News', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        ...store.news.map((item) => Card(child: ListTile(leading: const Icon(Icons.campaign_outlined), title: Text(item.title), subtitle: Text(item.text)))),
      ],
    );
  }
}

class JobsPage extends StatelessWidget {
  const JobsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(6, 8, 6, 10),
          child: Text('Available Jobs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ),
        ...store.jobs.map((job) => JobCard(store: store, job: job)),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.store, required this.job});

  final AppStore store;
  final Job job;

  @override
  Widget build(BuildContext context) {
    final isSaved = store.saved.contains(job.id);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => JobDetailsPage(store: store, job: job))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CircleAvatar(child: Icon(Icons.business_center_outlined)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(job.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(job.company),
                    Text(job.location, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('৳ ${job.salary} • ${job.type}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(onPressed: () => store.toggleSaved(job.id), icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border)),
            ],
          ),
        ),
      ),
    );
  }
}

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key, required this.store, required this.job});

  final AppStore store;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Text(job.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(job.company, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _info(Icons.location_on_outlined, job.location),
          _info(Icons.payments_outlined, '৳ ${job.salary}'),
          _info(Icons.schedule_outlined, '${job.remainingDays} days remaining'),
          const Divider(height: 30),
          const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(job.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                store.addApplication(job.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application saved locally.')));
              },
              icon: const Icon(Icons.send),
              label: const Text('Apply Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: <Widget>[Icon(icon, size: 21), const SizedBox(width: 10), Expanded(child: Text(text))]),
    );
  }
}

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (store.applications.isEmpty) {
      return const Center(child: Text('No applications yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: store.applications.map((application) {
        final matches = store.jobs.where((item) => item.id == application.jobId);
        final job = matches.isEmpty ? null : matches.first;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.assignment_turned_in_outlined)),
            title: Text(job?.title ?? 'Job'),
            subtitle: Text('Applied ${DateFormat('dd MMM yyyy').format(application.date)}'),
            trailing: Text(application.status),
          ),
        );
      }).toList(),
    );
  }
}

class TechnicalPage extends StatelessWidget {
  const TechnicalPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    const topics = <String>[
      'Packaging Calculator',
      'Film Database',
      'Printing Guide',
      'Lamination Guide',
      'Slitting Guide',
      'Sealing Guide',
      'Multilayer Pouch',
      'Quality Control',
      'Problems & Solutions',
      'Safety',
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: topics
          .map((topic) => Card(child: ListTile(leading: const Icon(Icons.menu_book_outlined), title: Text(topic), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => GuideDetailPage(title: topic))))))
          .toList(),
    );
  }
}

class GuideDetailPage extends StatelessWidget {
  const GuideDetailPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Technical content for $title will be maintained by the admin team. Always follow your workplace SOP, equipment manual, SDS and trained-supervisor instructions.',
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: store.news.map((item) => ListTile(leading: const Icon(Icons.notifications_none), title: Text(item.title), subtitle: Text(item.text))).toList(),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          const Center(child: CircleAvatar(radius: 42, child: Icon(Icons.person, size: 44))),
          const SizedBox(height: 20),
          ListTile(title: const Text('Name'), subtitle: Text(store.userName ?? 'Not set')),
          ListTile(title: const Text('Email'), subtitle: Text(store.userEmail ?? 'Not set')),
          ListTile(title: const Text('Phone'), subtitle: Text(store.userPhone?.isEmpty == false ? store.userPhone! : 'Not set')),
        ],
      ),
    );
  }
}

class CvPage extends StatelessWidget {
  const CvPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CV / Resume')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          const Icon(Icons.description_outlined, size: 70),
          const SizedBox(height: 16),
          const Text('Your CV can be uploaded here in a future Firebase Storage flow.', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Choose CV File')),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Language / ভাষা'),
            trailing: DropdownButton<String>(
              value: store.language,
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'বাংলা', child: Text('বাংলা')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) store.setLanguage(value);
              },
            ),
          ),
          const SwitchListTile(value: true, onChanged: null, title: Text('Job Alerts')),
          const SwitchListTile(value: true, onChanged: null, title: Text('Push Notifications')),
        ],
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.store});

  final AppStore store;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: <Widget>[IconButton(onPressed: widget.store.logout, icon: const Icon(Icons.logout))],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(child: AppLogo(size: 48)),
            ...<String>['Dashboard', 'Jobs', 'Applications', 'Users', 'News', 'Analytics'].asMap().entries.map(
              (entry) => ListTile(
                selected: tab == entry.key,
                title: Text(entry.value),
                onTap: () {
                  setState(() => tab = entry.key);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(title: const Text('Logout'), leading: const Icon(Icons.logout), onTap: widget.store.logout),
          ],
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    switch (tab) {
      case 1:
        return AdminJobs(store: widget.store);
      case 2:
        return AdminApplications(store: widget.store);
      case 3:
        return const AdminUsers();
      case 4:
        return AdminNews(store: widget.store);
      case 5:
        return AdminAnalytics(store: widget.store);
      default:
        return AdminDashboard(store: widget.store);
    }
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final metrics = <Map<String, Object>>[
      {'label': 'Jobs', 'value': store.jobs.length, 'icon': Icons.work_outline},
      {'label': 'Applications', 'value': store.applications.length, 'icon': Icons.assignment_outlined},
      {'label': 'Expiring ≤ 3 days', 'value': store.jobs.where((job) => job.remainingDays <= 3).length, 'icon': Icons.timer_outlined},
      {'label': 'Active jobs', 'value': store.jobs.length, 'icon': Icons.check_circle_outline},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final item = metrics[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Icon(item['icon'] as IconData),
              const Spacer(),
              Text('${item['value']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              Text(item['label'] as String, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
        );
      },
    );
  }
}

class AdminJobs extends StatelessWidget {
  const AdminJobs({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        FilledButton.icon(onPressed: () => _newJob(context), icon: const Icon(Icons.add), label: const Text('Add New Job')),
        ...store.jobs.map(
          (job) => Card(
            child: ListTile(
              title: Text(job.title),
              subtitle: Text('${job.company} • ${job.remainingDays} days left'),
              trailing: IconButton(onPressed: () => store.removeJob(job.id), icon: const Icon(Icons.delete_outline)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _newJob(BuildContext context) async {
    final title = TextEditingController();
    final company = TextEditingController();
    final location = TextEditingController();
    final salary = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Job'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Job title')),
            const SizedBox(height: 10),
            TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
            const SizedBox(height: 10),
            TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 10),
            TextField(controller: salary, decoration: const InputDecoration(labelText: 'Salary')),
          ]),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty || company.text.trim().isEmpty) return;
              store.addJob(
                Job(
                  id: 'admin-${Random().nextInt(999999)}',
                  title: title.text.trim(),
                  company: company.text.trim(),
                  location: location.text.trim(),
                  salary: salary.text.trim(),
                  type: 'Full Time',
                  description: 'Added by admin.',
                  posted: DateTime.now(),
                  deadline: DateTime.now().add(const Duration(days: 30)),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    title.dispose();
    company.dispose();
    location.dispose();
    salary.dispose();
  }
}

class AdminApplications extends StatelessWidget {
  const AdminApplications({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (store.applications.isEmpty) return const Center(child: Text('No applications.'));
    return ListView(
      padding: const EdgeInsets.all(12),
      children: store.applications.map((item) {
        final matches = store.jobs.where((j) => j.id == item.jobId);
        final job = matches.isEmpty ? null : matches.first;
        return Card(child: ListTile(title: Text(job?.title ?? 'Job'), subtitle: Text(DateFormat('dd MMM yyyy').format(item.date)), trailing: Text(item.status)));
      }).toList(),
    );
  }
}

class AdminUsers extends StatelessWidget {
  const AdminUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListView(
      padding: EdgeInsets.all(18),
      children: <Widget>[
        Card(child: ListTile(title: Text('Total Users'), trailing: Text('—'))),
        Card(child: ListTile(title: Text('Online Now'), trailing: Text('—'))),
        Card(child: ListTile(title: Text('New Users Today'), trailing: Text('—'))),
      ],
    );
  }
}

class AdminNews extends StatelessWidget {
  const AdminNews({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Breaking News')),
        ...store.news.map((item) => Card(child: ListTile(title: Text(item.title), subtitle: Text(item.text)))),
      ],
    );
  }
}

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text('Analytics / হিসাব', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        _metric('Jobs', store.jobs.length),
        _metric('Applications', store.applications.length),
        _metric('Jobs expiring ≤ 3 days', store.jobs.where((job) => job.remainingDays <= 3).length),
      ],
    );
  }

  Widget _metric(String label, int value) {
    return Card(child: ListTile(title: Text(label), trailing: Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))));
  }
}
