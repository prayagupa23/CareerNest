import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_details_screen.dart';
import 'post_job_screen.dart';
import 'applicant_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/home_screen.dart';
import 'package:job_app/models/job.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
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
          _EmployerHomeTab(userName: userName ?? ''),
          _PostJobTab(),
          _ApplicantsTab(),
          _EmployerProfileTab(userName: userName ?? '', userEmail: userEmail ?? ''),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF0A1931),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Post Job'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Applicants'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _EmployerHomeTab extends StatelessWidget {
  final String userName;
  const _EmployerHomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Hi, $userName', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search your jobs',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}', style: GoogleFonts.montserrat(color: Colors.red)));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No jobs posted yet', style: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return _JobCard(job: Job.fromMap(data));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  const _JobCard({required this.job});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 6),
                Text('Applicants: ${job.applicants.length}', style: GoogleFonts.montserrat(fontSize: 15)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Chip(
                      label: Text(job.status, style: GoogleFonts.montserrat(color: Colors.white)),
                      backgroundColor: job.status == 'Open' ? Colors.green : Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0A1931)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsScreen(
                          job: job,
                          isEmployer: true,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF0A1931)),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostJobTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Post a New Job', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A1931))),
            const SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostJobScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1931),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text('Post Job', style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ApplicantCard(name: 'Alice Smith', job: 'UI/UX Designer', status: 'Pending'),
          _ApplicantCard(name: 'Bob Lee', job: 'Backend Developer', status: 'Accepted'),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final String name;
  final String job;
  final String status;
  const _ApplicantCard({required this.name, required this.job, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(name.isNotEmpty ? name[0] : '', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        subtitle: Text('Applied for $job', style: GoogleFonts.montserrat(fontSize: 15)),
        trailing: Chip(
          label: Text(status, style: GoogleFonts.montserrat(color: Colors.white)),
          backgroundColor: status == 'Accepted' ? Colors.green : Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicantDetailsScreen(name: name, job: job),
            ),
          );
        },
      ),
    );
  }
}

class _EmployerProfileTab extends StatelessWidget {
  final String userName;
  final String userEmail;
  const _EmployerProfileTab({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : '',
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(userName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(userEmail, style: GoogleFonts.montserrat(color: Colors.black54)),
                    const SizedBox(height: 8),
                    const Text('Role: Employer', style: TextStyle(fontSize: 15, color: Color(0xFF0A1931))),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 