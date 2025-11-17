import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'dashboard_screen.dart';
import 'upload_screen.dart';
import 'library_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isAdmin = appState.currentUser?.isAdmin == true;
        final currentTab = appState.currentTab;

        final screens = [
          const DashboardScreen(),
          const UploadScreen(),
          const LibraryScreen(),
          if (isAdmin) const AdminScreen(),
        ];

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('PaperLink'),
                backgroundColor: Colors.blue.withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                        appState.isOffline ? Icons.offline_bolt : Icons.cloud),
                    onPressed: () => appState.toggleOfflineMode(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      appState.logout();
                    },
                  ),
                ],
              ),
              body: currentTab < screens.length
                  ? screens[currentTab]
                  : screens[0],
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.white.withOpacity(0.9),
                currentIndex: currentTab.clamp(0, screens.length - 1),
                onTap: (index) => appState.setCurrentTab(index),
                items: [
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard), label: 'Dashboard'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.upload), label: 'Upload'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.library_books), label: 'Library'),
                  if (isAdmin)
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
                ],
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ],
        );
      },
    );
  }
}
