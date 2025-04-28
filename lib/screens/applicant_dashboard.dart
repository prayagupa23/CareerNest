import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_details_screen.dart';
import 'application_status_screen.dart';
import 'bookmark_list_screen.dart';
import 'resume_upload_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/home_screen.dart';
import 'package:job_app/models/job.dart';
import 'package:job_app/screens/job_details_screen.dart';

class ApplicantDashboard extends StatefulWidget {
  const ApplicantDashboard({super.key});

  @override
  State<ApplicantDashboard> createState() => _ApplicantDashboardState();
}

class _ApplicantDashboardState extends State<ApplicantDashboard> {
  int _selectedIndex = 0;
  String? userName;
  String? userEmail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      userName = doc.data()?['name'] ?? '';
      userEmail = doc.data()?['email'] ?? '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ModernHomeTab(userName: userName ?? ''),
          BookmarkListScreen(),
          ApplicationStatusScreen(),
          ModernProfileTab(userName: userName ?? '', userEmail: userEmail ?? ''),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class ModernHomeTab extends StatefulWidget {
  final String userName;
  const ModernHomeTab({required this.userName});

  @override
  State<ModernHomeTab> createState() => _ModernHomeTabState();
}

class _ModernHomeTabState extends State<ModernHomeTab> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              Text('CareerNest', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text('Hi, ${widget.userName}', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search jobs or companies',
              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            ),
            onChanged: (v) => setState(() => search = v),
          ),
          const SizedBox(height: 24),
          Text('Certification courses for you', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').where('type', isEqualTo: 'certification').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => doc['title'].toLowerCase().contains(search.toLowerCase())).toList();
                if (docs.isEmpty) {
                  // Modern default cards for certification
                  final defaultCerts = [
                    {
                      'title': 'Flutter Development',
                      'duration': '3 months',
                    //   'type': 'certification',
                      'icon': Icons.flutter_dash,
                      'color': Colors.blueAccent,
                    },
                    {
                      'title': 'Data Science Bootcamp',
                      'duration': '6 months',
                      //'type': 'certification',
                      'icon': Icons.analytics_outlined,
                      'color': Colors.deepPurpleAccent,
                    },
                  ].where((c) => (c['title'] as String).toLowerCase().contains(search.toLowerCase())).toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: defaultCerts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => _ModernCourseCard(data: defaultCerts[i]),
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => CourseCard(
                    data: docs[i].data() as Map<String, dynamic>,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsScreen(data: docs[i].data() as Map<String, dynamic>),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Placement guarantee courses', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').where('type', isEqualTo: 'placement').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => doc['title'].toLowerCase().contains(search.toLowerCase())).toList();
                if (docs.isEmpty) {
                  // Modern default cards for placement
                  final defaultPlacements = [
                    {
                      'title': 'Full Stack Placement',
                      'duration': '4 months',
                      'type': 'placement',
                      'icon': Icons.web_asset,
                      'color': Colors.amber,
                    },
                    {
                      'title': 'AI/ML Placement',
                      'duration': '5 months',
                      'type': 'placement',
                      'icon': Icons.memory,
                      'color': Colors.teal,
                    },
                  ].where((c) => (c['title'] as String).toLowerCase().contains(search.toLowerCase())).toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: defaultPlacements.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => _ModernCourseCard(data: defaultPlacements[i]),
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => CourseCard(
                    data: docs[i].data() as Map<String, dynamic>,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsScreen(data: docs[i].data() as Map<String, dynamic>),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Latest Internships for you', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('jobs').orderBy('postedAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => (doc['title'] ?? '').toLowerCase().contains(search.toLowerCase())).toList();
                if (docs.isEmpty) {
                  // Modern default cards for internships
                  final defaultInternships = [
                    {
                      'title': 'Mobile App Intern',
                      'company': 'TechNova',
                      'duration': '2 months',
                      'stipend': '₹10,000',
                      'icon': Icons.phone_android,
                      'color': Colors.indigo,
                    },
                    {
                      'title': 'Marketing Intern',
                      'company': 'Brandify',
                      'duration': '3 months',
                      'stipend': '₹8,000',
                      'icon': Icons.campaign,
                      'color': Colors.pinkAccent,
                    },
                  ].where((c) => (c['title'] as String).toLowerCase().contains(search.toLowerCase())).toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: defaultInternships.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => _ModernInternshipCard(data: defaultInternships[i]),
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => _ModernInternshipCard(data: {
                    'title': docs[i]['title'] ?? '',
                    'company': docs[i]['company'] ?? '',
                    // 'duration': docs[i]['duration'] ?? '',
                    //'stipend': docs[i]['stipend'] ?? '',
                    'icon': Icons.work_outline,
                    'color': Colors.teal,
                  }),
                );
              },
            ),
          ),
          // TODO: To show internships posted by employers in the applicant dashboard, fetch from the 'jobs' or 'internships' collection and display here.
        ],
      ),
    );
  }
}

class _ModernCourseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ModernCourseCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (data['color'] as Color).withOpacity(0.85),
            (data['color'] as Color).withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: (data['color'] as Color).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(data['icon'] as IconData, color: data['color'] as Color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(data['title'] ?? '', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(data['duration'] ?? '', style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data['type'] == 'certification' ? 'Certification' : 'Placement',
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const CourseCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data['title'] ?? '', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(data['duration'] ?? '', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)),
              const SizedBox(height: 8),
              if (data['type'] == 'certification')
                Chip(label: const Text('Certification', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
              if (data['type'] == 'placement')
                Chip(label: const Text('Placement', style: TextStyle(color: Colors.white)), backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernProfileTab extends StatelessWidget {
  final String userName;
  final String userEmail;
  const ModernProfileTab({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Profile', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A1931))),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(radius: 32, backgroundColor: Color(0xFF0A1931), child: Text(userName.isNotEmpty ? userName[0] : '', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                    //const SizedBox(height: 4),
                    //Text(userEmail, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 4),
                    const Text('Role: Applicant', style: TextStyle(fontSize: 15, color: Color(0xFF0A1931))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text('Logout', style: GoogleFonts.montserrat(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumeUploadScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Resume (Optional)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1931),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.bookmark_border, 'label': 'Bookmarks'},
      {'icon': Icons.assignment_outlined, 'label': 'Applications'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i]['icon'] as IconData, color: selected ? const Color(0xFF0A1931) : Colors.grey, size: 28),
                    const SizedBox(height: 2),
                    Text(
                      items[i]['label'] as String,
                      style: GoogleFonts.montserrat(
                        color: selected ? const Color(0xFF0A1931) : Colors.grey,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ModernInternshipCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ModernInternshipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: Job.fromMap(data)),
          ),
        );
      },
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (data['color'] as Color).withOpacity(0.85),
              (data['color'] as Color).withOpacity(0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: (data['color'] as Color).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(data['icon'] as IconData, color: data['color'] as Color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(data['title'] ?? '', style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(data['company'] ?? '', style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white70)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(data['duration'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white70)),
                  const SizedBox(width: 12),
                  Icon(Icons.attach_money, color: Colors.white70, size: 16),
                  const SizedBox(width: 2),
                  Text(data['stipend'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 