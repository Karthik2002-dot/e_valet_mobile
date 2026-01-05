import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'operator_drawer_item.dart';

class OperatorDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const OperatorDrawer(
      {super.key, this.selectedIndex = 0, this.onItemSelected});

  // Menu item UI extracted to `OperatorDrawerItem` (operator_drawer_item.dart)

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/images/niloufer.logo.png',
                  width: 140,
                ),
              ),
              const SizedBox(height: 24),
              OperatorDrawerItem(
                asset: 'assets/images/dashboard.png',
                title: 'Dashboard',
                isSelected: selectedIndex == 0,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(0);
                },
              ),
              OperatorDrawerItem(
                asset: 'assets/images/slots.png',
                title: 'Slots',
                isSelected: selectedIndex == 1,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(1);
                },
              ),
              OperatorDrawerItem(
                asset: 'assets/images/drivers.png',
                title: 'Drivers',
                isSelected: selectedIndex == 2,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(2);
                },
              ),
              OperatorDrawerItem(
                asset: 'assets/images/cars.png',
                title: 'Car Logs',
                isSelected: selectedIndex == 3,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(3);
                },
              ),
              Spacer(),
              Divider(
                color: AppColors.black,
                thickness: 2,
                indent: 16,
                endIndent: 16,
              ),
              OperatorDrawerItem(
                asset: 'assets/images/profile.png',
                title: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(4);
                },
              ),
              OperatorDrawerItem(
                asset: 'assets/images/logout.png',
                title: 'Logout',
                isSelected: selectedIndex == 5,
                onTap: () {
                  Navigator.of(context).pop();
                  onItemSelected?.call(5);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
