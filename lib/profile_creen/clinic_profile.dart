import 'package:flutter/material.dart';

class ClinicProfile extends StatelessWidget {
	const ClinicProfile({super.key});

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
						const Text(
							'Vet Clinic Profile',
							style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
						),
						const SizedBox(height: 8),
						const Text('Clinic details will appear here (Firebase integration later).'),
						const SizedBox(height: 16),

						// Clinic data fields (placeholders until Firebase integration)
						Card(
							elevation: 0,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							child: Padding(
								padding: const EdgeInsets.all(12),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const Text('Clinic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
										const SizedBox(height: 8),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Clinic Name'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
										const Divider(),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Address'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
										const Divider(),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Phone'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
										const Divider(),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Email'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
										const Divider(),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Opening Hours'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
										const Divider(),
										ListTile(
											contentPadding: EdgeInsets.zero,
											title: const Text('Services'),
											subtitle: const Text('Not set', style: TextStyle(color: Colors.grey)),
										),
									],
								),
							),
						),

						const SizedBox(height: 16),
						const Spacer(),

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




/*
actions: [
					TextButton.icon(
						onPressed: () {
							Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
						},
						icon: const Icon(Icons.logout, color: Colors.redAccent),
						label: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
					),
				],
*/