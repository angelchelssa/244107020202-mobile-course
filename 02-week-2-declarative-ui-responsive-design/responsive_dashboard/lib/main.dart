import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AngelBoard'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 4),
              Semantics(
                label: isDark
                    ? 'Mode gelap aktif, ketuk untuk beralih ke mode terang'
                    : 'Mode terang aktif, ketuk untuk beralih ke mode gelap',
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 2 : 1;
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          final aspectRatio = isLandscape ? 3.2 : 2.6;

          return SingleChildScrollView(         
            padding: const EdgeInsets.all(16),
            child: Column(                        
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Semantics(
                    label: 'Profil siswa: Angel Chelssa, D-IV Teknik Informatika',
                    container: true,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue.shade700 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: isDark ? Colors.blue.shade300 : Colors.blue,
                            child: const ExcludeSemantics(
                              child: Text(
                                'AC',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: ExcludeSemantics(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Angel Chelssa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'D-IV Teknik Informatika, 244107020202',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),       

                GridView.count(                  
                  shrinkWrap: true,              
                  physics: const NeverScrollableScrollPhysics(), 
                  padding: EdgeInsets.zero,                      
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                  children: const [
                    DashboardCard(title: 'Assignments', value: '8'),
                    DashboardCard(title: 'Attendance', value: '92%'),
                    DashboardCard(title: 'Portfolio', value: 'Ready'),
                    DashboardCard(title: 'Current week', value: '02'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis, 
                ),
              ),
            ),
            ExcludeSemantics(
              child: Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ),
          ]),
        ),
      ),
    );
  }
}