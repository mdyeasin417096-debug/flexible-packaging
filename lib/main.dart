import 'package:flutter/material.dart';

const brandBlue = Color(0xFF0877C9);
const brandGreen = Color(0xFF21B66F);
const darkText = Color(0xFF18324B);
const lightBg = Color(0xFFF4F8FB);

void main() => runApp(const FlexiblePackagingApp());

class FlexiblePackagingApp extends StatelessWidget {
  const FlexiblePackagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexible Packaging',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBg,
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brandBlue, width: 1.5),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class FPLogo extends StatelessWidget {
  final double size;
  const FPLogo({super.key, this.size = 82});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .23),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6))
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.eco, size: size * .58, color: brandGreen),
            Positioned(
              left: size * .18,
              top: size * .18,
              child: Icon(Icons.bolt, size: size * .45, color: brandBlue),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  final String title;
  final bool back;
  const BrandHeader({super.key, required this.title, this.back = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 18,
        right: 18,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [brandBlue, Color(0xFF0B92D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          if (back)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          if (!back) const FPLogo(size: 44),
          if (back) const SizedBox(width: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: brandBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [brandBlue, Color(0xFF0B91D6), brandGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FPLogo(size: 116),
              const SizedBox(height: 26),
              const Text(
                'Flexible Packaging',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find Your Next Opportunity',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Better Jobs  •  Better Future',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Language
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const FPLogo(size: 100),
              const SizedBox(height: 22),
              const Text('Welcome to Flexible Packaging',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: darkText)),
              const SizedBox(height: 10),
              const Text('Choose your preferred language',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'English',
                icon: Icons.language,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  icon: const Icon(Icons.translate),
                  label: const Text('বাংলা', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const Spacer(),
              const Text('Professional jobs for the flexible packaging industry',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black45)),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 35, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: const FPLogo(size: 76)),
              const SizedBox(height: 20),
              const Center(child: Text('Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkText))),
              const SizedBox(height: 28),
              const Text('Email / Phone Number'),
              const SizedBox(height: 7),
              const TextField(decoration: InputDecoration(hintText: 'Enter email or phone')),
              const SizedBox(height: 16),
              const Text('Password'),
              const SizedBox(height: 7),
              const TextField(obscureText: true, decoration: InputDecoration(hintText: 'Enter password')),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Forgot password?')),
                ],
              ),
              PrimaryButton(
                text: 'Login',
                icon: Icons.login,
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const HomeScreen())),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('New here? Create an account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Registration
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: FPLogo(size: 72)),
            const SizedBox(height: 18),
            const Text('Full Name'),
            const SizedBox(height: 7),
            const TextField(decoration: InputDecoration(hintText: 'Your full name')),
            const SizedBox(height: 14),
            const Text('Email or Phone Number'),
            const SizedBox(height: 7),
            const TextField(decoration: InputDecoration(hintText: 'Email / phone')),
            const SizedBox(height: 14),
            const Text('Password'),
            const SizedBox(height: 7),
            const TextField(obscureText: true),
            const SizedBox(height: 14),
            const Text('Confirm Password'),
            const SizedBox(height: 7),
            const TextField(obscureText: true),
            const SizedBox(height: 22),
            PrimaryButton(
              text: 'Register',
              icon: Icons.person_add,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OtpScreen())),
            ),
            const SizedBox(height: 10),
            Center(child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            )),
          ],
        ),
      ),
    );
  }
}

// 5. OTP
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Icon(Icons.verified_user, size: 76, color: brandBlue),
            const SizedBox(height: 18),
            const Text('Verify your account',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: darkText)),
            const SizedBox(height: 8),
            const Text('Enter the 6-digit code sent to your phone or email.',
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            const TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(fontSize: 26, letterSpacing: 12, fontWeight: FontWeight.w800),
              decoration: InputDecoration(counterText: '', hintText: '••••••'),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              text: 'Verify',
              icon: Icons.check_circle,
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen())),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () {}, child: const Text('Resend code in 00:45')),
          ],
        ),
      ),
    );
  }
}

// 6. Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const BrandHeader(title: 'Flexible Packaging'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [brandBlue, brandGreen]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find your next opportunity',
                            style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                        SizedBox(height: 7),
                        Text('Jobs, careers and industry opportunities in one place.',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _QuickCard('Search Jobs', Icons.search, () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SearchJobsScreen())))),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickCard('My Applications', Icons.assignment, () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ApplicationsScreen())))),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Latest Jobs', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: darkText)),
                  const SizedBox(height: 10),
                  ...sampleJobs.take(3).map((j) => JobCard(job: j)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomBar(selected: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchJobsScreen())),
        backgroundColor: brandGreen,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickCard(this.title, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: brandBlue.withOpacity(.1), child: Icon(icon, color: brandBlue)),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

// 7. Search
class SearchJobsScreen extends StatefulWidget {
  const SearchJobsScreen({super.key});
  @override
  State<SearchJobsScreen> createState() => _SearchJobsScreenState();
}
class _SearchJobsScreenState extends State<SearchJobsScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = sampleJobs.where((j) => '${j.title} ${j.company} ${j.location}'
        .toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search Jobs')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Job title, company or keyword'),
          ),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.location_on), hintText: 'Location')),
          const SizedBox(height: 22),
          const Text('Popular Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: ['Production Manager', 'QA', 'Printing', 'Sales', 'Operator']
              .map((x) => ActionChip(label: Text(x), onPressed: () => setState(() => query = x))).toList()),
          const SizedBox(height: 22),
          const Text('Job Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: ['Production', 'Quality', 'Design', 'Engineering', 'Sales']
              .map((x) => Chip(label: Text(x))).toList()),
          const SizedBox(height: 22),
          ...filtered.map((j) => JobCard(job: j)),
        ],
      ),
    );
  }
}

// 8. Listings
class JobListingsScreen extends StatelessWidget {
  const JobListingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Listings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(spacing: 8, children: ['All', 'Full Time', 'Part Time', 'Contract']
              .map((x) => FilterChip(label: Text(x), selected: x == 'All', onSelected: (_) {})).toList()),
          const SizedBox(height: 12),
          ...sampleJobs.map((j) => JobCard(job: j)),
        ],
      ),
    );
  }
}

// 9. Job Details
class JobDetailsScreen extends StatelessWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: PrimaryButton(
          text: 'Apply Now',
          icon: Icons.send,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ApplyJobScreen(job: job))),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Container(
            height: 125,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [brandBlue, brandGreen]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Icon(Icons.factory, color: Colors.white, size: 65)),
          ),
          const SizedBox(height: 18),
          Text(job.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: darkText)),
          const SizedBox(height: 6),
          Text(job.company, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: brandBlue)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _InfoChip(Icons.location_on, job.location),
            _InfoChip(Icons.payments, job.salary),
            _InfoChip(Icons.work, job.type),
          ]),
          const SizedBox(height: 24),
          const Text('Job Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(job.description),
          const SizedBox(height: 20),
          const Text('Requirements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...job.requirements.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [const Icon(Icons.check_circle, color: brandGreen, size: 20), const SizedBox(width: 8), Expanded(child: Text(r))]),
          )),
        ],
      ),
    );
  }
}
class _InfoChip extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoChip(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 17), label: Text(text));
}

// 10. Apply
class ApplyJobScreen extends StatelessWidget {
  final Job job;
  const ApplyJobScreen({super.key, required this.job});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Job')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
          Text(job.company, style: const TextStyle(color: brandBlue)),
          const SizedBox(height: 22),
          const Text('CV / Resume', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12)),
            child: const Row(children: [
              Icon(Icons.picture_as_pdf, color: brandBlue, size: 32),
              SizedBox(width: 12),
              Expanded(child: Text('Upload your latest CV / Resume')),
              Icon(Icons.upload_file, color: brandBlue),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Message (optional)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Write a short message to the employer')),
          const SizedBox(height: 22),
          PrimaryButton(
            text: 'Submit Application',
            icon: Icons.send,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Application Submitted'),
                content: const Text('Your application has been recorded in this demo app.'),
                actions: [TextButton(onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child: const Text('Done'))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 11. Applications
class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(children: [
            Expanded(child: _StatusTab('Applied', true)),
            Expanded(child: _StatusTab('Shortlisted', false)),
            Expanded(child: _StatusTab('Rejected', false)),
          ]),
          const SizedBox(height: 14),
          ...sampleJobs.take(3).map((j) => _ApplicationCard(job: j)),
        ],
      ),
    );
  }
}
class _StatusTab extends StatelessWidget {
  final String text; final bool selected;
  const _StatusTab(this.text, this.selected);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: selected ? brandBlue : Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(color: selected ? Colors.white : darkText, fontWeight: FontWeight.w800)),
  );
}
class _ApplicationCard extends StatelessWidget {
  final Job job;
  const _ApplicationCard({required this.job});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFFE5F3FC), child: Icon(Icons.work, color: brandBlue)),
      title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${job.company}\nApplied • 02 Oct 2026'),
      isThreeLine: true,
      trailing: const Chip(label: Text('Applied')),
    ),
  );
}

// 12. Saved Jobs
class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sampleJobs.take(2).map((j) => JobCard(job: j, saved: true)).toList(),
      ),
    );
  }
}

// 13. Notifications
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      ['Application Update', 'Your application is under review.', Icons.assignment_turned_in],
      ['New Job Match', 'A new Production Manager role matches your profile.', Icons.work],
      ['Interview Invitation', 'You have a new interview invitation.', Icons.event],
      ['Job Alert', '5 new jobs were posted in Production.', Icons.notifications_active],
      ['Profile Reminder', 'Complete your profile to improve visibility.', Icons.person],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: brandBlue.withOpacity(.1),
              child: Icon(items[i][2] as IconData, color: brandBlue),
            ),
            title: Text(items[i][0] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(items[i][1] as String),
          ),
        ),
      ),
    );
  }
}

// 14. Profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Center(child: CircleAvatar(radius: 48, backgroundColor: brandBlue,
              child: Icon(Icons.person, size: 55, color: Colors.white))),
          const SizedBox(height: 12),
          const Center(child: Text('Guest User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          const Center(child: Text('Complete your profile', style: TextStyle(color: Colors.black54))),
          const SizedBox(height: 22),
          _ProfileTile(Icons.person_outline, 'My Profile'),
          _ProfileTile(Icons.description_outlined, 'My CV / Resume'),
          _ProfileTile(Icons.assignment_outlined, 'Applied Jobs'),
          _ProfileTile(Icons.bookmark_outline, 'Saved Jobs'),
          _ProfileTile(Icons.settings_outlined, 'Settings', onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    );
  }
}
class _ProfileTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback? onTap;
  const _ProfileTile(this.icon, this.title, {this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(leading: Icon(icon, color: brandBlue), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );
}

// 15. Settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText)),
          _SettingTile(Icons.edit, 'Edit Profile'),
          _SettingTile(Icons.lock_outline, 'Change Password'),
          _SettingTile(Icons.security, 'Privacy & Security'),
          const SizedBox(height: 18),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText)),
          const _SwitchTile('Job Alerts', true),
          const _SwitchTile('Push Notifications', true),
          const _SwitchTile('Email Notifications', false),
          const SizedBox(height: 18),
          const Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText)),
          _SettingTile(Icons.help_outline, 'Help & Support'),
          _SettingTile(Icons.info_outline, 'About Us'),
          _SettingTile(Icons.logout, 'Logout', danger: true),
        ],
      ),
    );
  }
}
class _SettingTile extends StatelessWidget {
  final IconData icon; final String title; final bool danger;
  const _SettingTile(this.icon, this.title, {this.danger = false});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(leading: Icon(icon, color: danger ? Colors.red : brandBlue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: danger ? Colors.red : darkText)),
      trailing: const Icon(Icons.chevron_right)),
  );
}
class _SwitchTile extends StatelessWidget {
  final String title; final bool value;
  const _SwitchTile(this.title, this.value);
  @override
  Widget build(BuildContext context) => Card(
    child: SwitchListTile(title: Text(title), value: value, onChanged: (_) {}),
  );
}

// Shared job widgets/data
class Job {
  final String title, company, location, salary, type, description;
  final List<String> requirements;
  const Job({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.requirements,
  });
}

const sampleJobs = [
  Job(
    title: 'Production Manager',
    company: 'ABC Flexible Packaging Ltd.',
    location: 'Dhaka',
    salary: '৳60K - ৳90K',
    type: 'Full Time',
    description: 'Lead production planning, manufacturing operations, quality coordination and team performance for flexible packaging products.',
    requirements: ['5+ years production experience', 'Flexible packaging industry knowledge', 'Strong leadership and communication'],
  ),
  Job(
    title: 'Quality Assurance Officer',
    company: 'PackPro Industries',
    location: 'Gazipur',
    salary: '৳35K - ৳50K',
    type: 'Full Time',
    description: 'Monitor quality systems, inspection processes and customer specifications across the production floor.',
    requirements: ['2+ years QA experience', 'Knowledge of ISO systems', 'Good documentation skills'],
  ),
  Job(
    title: 'Printing Machine Operator',
    company: 'GreenPack Ltd.',
    location: 'Narayanganj',
    salary: '৳25K - ৳35K',
    type: 'Full Time',
    description: 'Operate and maintain flexographic printing machinery while maintaining production and quality standards.',
    requirements: ['Machine operation experience', 'Shift flexibility', 'Safety awareness'],
  ),
  Job(
    title: 'Sales Executive',
    company: 'Flexible Solutions',
    location: 'Dhaka',
    salary: '৳30K - ৳45K',
    type: 'Contract',
    description: 'Develop customer relationships and support sales of flexible packaging solutions.',
    requirements: ['Sales experience', 'Customer communication', 'Willingness to travel'],
  ),
];

class JobCard extends StatelessWidget {
  final Job job;
  final bool saved;
  const JobCard({super.key, required this.job, this.saved = false});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    child: InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job))),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 27,
              backgroundColor: Color(0xFFE7F4FC),
              child: Icon(Icons.factory, color: brandBlue, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(job.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: darkText)),
                const SizedBox(height: 4),
                Text(job.company, style: const TextStyle(color: brandBlue, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Text('${job.location}  •  ${job.type}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 5),
                Text(job.salary, style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w800)),
              ]),
            ),
            Icon(saved ? Icons.bookmark : Icons.chevron_right,
                color: saved ? brandBlue : Colors.black38),
          ],
        ),
      ),
    ),
  );
}

// Navigation helpers
class _BottomBar extends StatelessWidget {
  final int selected;
  const _BottomBar({required this.selected});
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selected,
    onDestinationSelected: (i) {
      if (i == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else if (i == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JobListingsScreen()));
      } else if (i == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      }
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
      NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ],
  );
}
