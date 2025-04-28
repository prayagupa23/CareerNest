import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/home_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
          _AdminHomeTab(userName: userName ?? ''),
          _JobsTab(),
          _ReportsTab(),
          _AdminProfileTab(userName: userName ?? '', userEmail: userEmail ?? ''),
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
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.report_gmailerrorred_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatelessWidget {
  final String userName;
  const _AdminHomeTab({required this.userName});

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
                hintText: 'Search users',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No users found', style: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return _UserCard(
                        name: data['name'] ?? '',
                        email: data['email'] ?? '',
                        role: data['role'] ?? '',
                        status: data['status'] ?? '',
                      );
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

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String status;
  const _UserCard({required this.name, required this.email, required this.role, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(name.isNotEmpty ? name[0] : '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: GoogleFonts.montserrat(fontSize: 15)),
            const SizedBox(height: 2),
            Row(
              children: [
                Chip(
                  label: Text(role, style: const TextStyle(color: Colors.white)),
                  backgroundColor: role == 'Admin' ? Colors.deepPurple : role == 'Employer' ? Colors.blue : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: status == 'Active' ? Colors.green : Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0A1931)),
          onPressed: () {},
        ),
        onTap: () {},
      ),
    );
  }
}

class _JobsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _JobCard(title: 'UI/UX Designer', employer: 'Acme Corp', status: 'Open'),
          _JobCard(title: 'Backend Developer', employer: 'Beta Ltd', status: 'Closed'),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String employer;
  final String status;
  const _JobCard({required this.title, required this.employer, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0A1931))),
                const SizedBox(height: 6),
                Text('Employer: $employer', style: GoogleFonts.montserrat(fontSize: 15)),
                const SizedBox(height: 6),
                Text('Status: $status', style: GoogleFonts.montserrat(fontSize: 15, color: status == 'Open' ? Colors.green : Colors.red)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0A1931)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
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

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCard(type: 'Job', title: 'UI/UX Designer', reporter: 'Alice Smith'),
          _ReportCard(type: 'User', title: 'Bob Lee', reporter: 'Admin'),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String type;
  final String title;
  final String reporter;
  const _ReportCard({required this.type, required this.title, required this.reporter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Icon(type == 'Job' ? Icons.work_outline : Icons.person_outline, color: Color(0xFF0A1931)),
        title: Text('$type: $title', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        subtitle: Text('Reported by $reporter'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0A1931)),
          onPressed: () {},
        ),
        onTap: () {},
      ),
    );
  }
}

class _AdminProfileTab extends StatelessWidget {
  final String userName;
  final String userEmail;
  const _AdminProfileTab({required this.userName, required this.userEmail});

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
                    const Text('Role: Admin', style: TextStyle(fontSize: 15, color: Color(0xFF0A1931))),
                  ],
                ),
              ],
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