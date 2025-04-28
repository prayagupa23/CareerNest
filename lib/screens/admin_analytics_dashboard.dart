import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdminAnalyticsDashboard extends StatelessWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Users by Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _UsersByRoleChart(),
          const SizedBox(height: 32),
          const Text('Listings by Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _ListingsByTypeChart(),
          const SizedBox(height: 32),
          const Text('Applications Over Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _ApplicationsOverTimeChart(),
        ],
      ),
    );
  }
}

class _UsersByRoleChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs;
        final roles = <String, int>{};
        for (var doc in docs) {
          final role = doc['role'] ?? 'Unknown';
          roles[role] = (roles[role] ?? 0) + 1;
        }
        final data = roles.entries.map((e) => charts.SeriesDatum(e.key, e.value)).toList();
        final series = [
          charts.Series<charts.SeriesDatum, String>(
            id: 'Roles',
            domainFn: (datum, _) => datum.label,
            measureFn: (datum, _) => datum.value,
            data: data,
            labelAccessorFn: (datum, _) => '${datum.label}: ${datum.value}',
          ),
        ];
        return SizedBox(
          height: 180,
          child: charts.PieChart<String>(
            series,
            animate: true,
            defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [charts.ArcLabelDecorator()]),
          ),
        );
      },
    );
  }
}

class _ListingsByTypeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs;
        final types = <String, int>{};
        for (var doc in docs) {
          final type = doc['type'] ?? 'Other';
          types[type] = (types[type] ?? 0) + 1;
        }
        final data = types.entries.map((e) => charts.SeriesDatum(e.key, e.value)).toList();
        final series = [
          charts.Series<charts.SeriesDatum, String>(
            id: 'Types',
            domainFn: (datum, _) => datum.label,
            measureFn: (datum, _) => datum.value,
            data: data,
            labelAccessorFn: (datum, _) => '${datum.label}: ${datum.value}',
          ),
        ];
        return SizedBox(
          height: 180,
          child: charts.PieChart<String>(
            series,
            animate: true,
            defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [charts.ArcLabelDecorator()]),
          ),
        );
      },
    );
  }
}

class _ApplicationsOverTimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('applications').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs;
        final byDate = <String, int>{};
        for (var doc in docs) {
          final date = (doc['dateApplied'] ?? '').toString().split('T').first;
          if (date.isNotEmpty) byDate[date] = (byDate[date] ?? 0) + 1;
        }
        final sorted = byDate.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
        final data = sorted.map((e) => _DateCount(e.key, e.value)).toList();
        final series = [
          charts.Series<_DateCount, String>(
            id: 'Applications',
            domainFn: (datum, _) => datum.date,
            measureFn: (datum, _) => datum.count,
            data: data,
          ),
        ];
        return SizedBox(
          height: 180,
          child: charts.BarChart(
            series,
            animate: true,
          ),
        );
      },
    );
  }
}

class _DateCount {
  final String date;
  final int count;
  _DateCount(this.date, this.count);
} 