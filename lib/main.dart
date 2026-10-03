import 'package:flutter/material.dart';

void main() {
  runApp(const FlexiblePackagingApp());
}

class FlexiblePackagingApp extends StatelessWidget {
  const FlexiblePackagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexible Packaging',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = <String>[
    'Flexible Packaging',
    'Jobs',
    'Knowledge',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const JobsPage(),
      const KnowledgePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Knowledge',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _WelcomeCard(),
        const SizedBox(height: 16),
        Text(
          'Quick access',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        const _FeatureCard(
          icon: Icons.work_outline,
          title: 'Find packaging jobs',
          subtitle: 'Browse sample vacancies and job categories.',
        ),
        const _FeatureCard(
          icon: Icons.school_outlined,
          title: 'Technical knowledge',
          subtitle: 'Learn about flexible packaging processes.',
        ),
        const _FeatureCard(
          icon: Icons.info_outline,
          title: 'About the app',
          subtitle: 'A clean foundation ready for later backend integration.',
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.inventory_2_outlined, size: 42, color: scheme.primary),
            const SizedBox(height: 14),
            Text(
              'Welcome to Flexible Packaging',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A simple starting point for packaging jobs, learning resources, and professional information.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
      ),
    );
  }
}

class Job {
  const Job({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
  });

  final String title;
  final String company;
  final String location;
  final String type;
}

const jobs = <Job>[
  Job(
    title: 'Flexible Packaging Operator',
    company: 'Sample Packaging Ltd.',
    location: 'Dhaka',
    type: 'Full time',
  ),
  Job(
    title: 'Production Supervisor',
    company: 'Sample Films & Printing',
    location: 'Gazipur',
    type: 'Full time',
  ),
  Job(
    title: 'Quality Control Executive',
    company: 'Sample Flexible Pack',
    location: 'Narayanganj',
    type: 'Full time',
  ),
];

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final filtered = jobs.where((job) {
      if (normalized.isEmpty) {
        return true;
      }
      return '${job.title} ${job.company} ${job.location} ${job.type}'
          .toLowerCase()
          .contains(normalized);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search jobs',
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No jobs found.')),
          )
        else
          ...filtered.map((job) => _JobCard(job: job)),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(job.company),
            const SizedBox(height: 4),
            Text('${job.location} • ${job.type}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(job.title),
                      content: const Text(
                        'This is a demo job listing. Application and account features can be connected later.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KnowledgePage extends StatelessWidget {
  const KnowledgePage({super.key});

  static const topics = <Map<String, String>>[
    {
      'title': 'Film structure',
      'text':
          'Understand common single-layer and multilayer flexible packaging structures.',
    },
    {
      'title': 'Printing',
      'text':
          'Learn the basic workflow of gravure and flexographic printing.',
    },
    {
      'title': 'Lamination',
      'text':
          'Review the purpose of adhesive and extrusion lamination.',
    },
    {
      'title': 'Slitting and pouch making',
      'text':
          'Explore common finishing operations used after printing and lamination.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Technical knowledge',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...topics.map(
          (topic) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(topic['title']!),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [Text(topic['text']!)],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 42,
          child: Icon(Icons.person, size: 44),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Guest User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 20),
        const Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Account'),
            subtitle: Text(
              'Authentication can be added after the base build is stable.',
            ),
          ),
        ),
        const Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
            subtitle: Text(
              'Application settings will be added in a later step.',
            ),
          ),
        ),
      ],
    );
  }
}
