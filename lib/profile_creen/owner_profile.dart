import 'package:flutter/material.dart';

class OwnerProfile extends StatelessWidget {
	const OwnerProfile({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Profile'),
				automaticallyImplyLeading: false,
			),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Center(child: Text('Owner Profile Screen')),
            // log out button
						const SizedBox(height: 16),
						const Spacer(), // makes the log out button stay at the bottom
						SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.redAccent,
									foregroundColor: Colors.white,
									elevation: 0,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
								),
								onPressed: () {
									Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
								},
								icon: const Icon(Icons.logout),
								label: const Text('Log out'),
							),
						),
					],
				),
			),
		);
	}
}
