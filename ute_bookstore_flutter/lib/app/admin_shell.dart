// import 'package:flutter/material.dart';
//
// import '../features/dashboard/presentation/dashboard_screen.dart';
// import '../features/orders/presentation/orders_screen.dart';
// import '../features/products/presentation/products_screen.dart';
// import '../features/management/presentation/management_screen.dart';
// import '../theme/admin_theme.dart';
//
// class AdminShell extends StatefulWidget {
//   const AdminShell({super.key});
//
//   @override
//   State<AdminShell> createState() => _AdminShellState();
// }
//
// class _AdminShellState extends State<AdminShell> {
//   int _index = 0;
//
//   final _pages = const [
//     DashboardScreen(),
//     ProductsScreen(),
//     OrdersScreen(),
//     ManagementScreen(),
//   ];
//
//   final _destinations = const [
//     _NavDestination(label: 'Bảng điều khiển', icon: Icons.dashboard_rounded),
//     _NavDestination(label: 'Sản phẩm', icon: Icons.inventory_2_rounded),
//     _NavDestination(label: 'Đơn hàng', icon: Icons.receipt_long_rounded),
//     _NavDestination(label: 'Khác', icon: Icons.more_horiz_rounded),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final useRail = constraints.maxWidth >= 960;
//         final body = AnimatedSwitcher(
//           duration: const Duration(milliseconds: 250),
//           child: _pages[_index],
//           transitionBuilder: (child, animation) {
//             final offset = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation);
//             return FadeTransition(
//               opacity: animation,
//               child: SlideTransition(position: offset, child: child),
//             );
//           },
//         );
//
//         if (useRail) {
//           return Scaffold(
//             backgroundColor: AdminColors.background,
//             body: Row(
//               children: [
//                 NavigationRail(
//                   selectedIndex: _index,
//                   onDestinationSelected: (value) => setState(() => _index = value),
//                   extended: true,
//                   minExtendedWidth: 220,
//                   leading: Padding(
//                     padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
//                     child: Row(
//                       children: const [
//                         CircleAvatar(
//                           backgroundColor: AdminColors.primary,
//                           child: Icon(Icons.storefront_rounded, color: Colors.white),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'UTE Admin',
//                             style: TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   destinations: _destinations
//                       .map(
//                         (item) => NavigationRailDestination(
//                           icon: Icon(item.icon),
//                           label: Text(item.label),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 const VerticalDivider(width: 1),
//                 Expanded(child: SafeArea(child: body)),
//               ],
//             ),
//           );
//         }
//
//         return Scaffold(
//           backgroundColor: AdminColors.background,
//           body: SafeArea(child: body),
//           bottomNavigationBar: NavigationBar(
//             selectedIndex: _index,
//             onDestinationSelected: (value) => setState(() => _index = value),
//             destinations: _destinations
//                 .map(
//                   (item) => NavigationDestination(
//                     icon: Icon(item.icon),
//                     label: item.label,
//                   ),
//                 )
//                 .toList(),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _NavDestination {
//   final String label;
//   final IconData icon;
//
//   const _NavDestination({required this.label, required this.icon});
// }
import 'package:flutter/material.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/management/presentation/management_screen.dart';
import '../theme/admin_theme.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ProductsScreen(),
    OrdersScreen(),
    ManagementScreen(),
  ];

  final _destinations = const [
    _NavDestination(label: 'Bảng điều khiển', icon: Icons.dashboard_rounded),
    _NavDestination(label: 'Sản phẩm', icon: Icons.inventory_2_rounded),
    _NavDestination(label: 'Đơn hàng', icon: Icons.receipt_long_rounded),
    _NavDestination(label: 'Khác', icon: Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 960;
        final body = AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _pages[_index],
          transitionBuilder: (child, animation) {
            final offset =
            Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
        );

        if (useRail) {
          return Scaffold(
            backgroundColor: AdminColors.background,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                  extended: true,
                  minExtendedWidth: 220,
                  leading: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 12,
                      right: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(
                          backgroundColor: AdminColors.primary,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'UTE Admin',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SafeArea(
                    child: KeyedSubtree(
                      key: ValueKey(_index),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AdminColors.background,
          body: SafeArea(
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: body,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: _destinations
                .map(
                  (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
                .toList(),
          ),
        );
      },
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;

  const _NavDestination({required this.label, required this.icon});
}