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
            // add clinic profile details here
						const Text('...'),
            // log out button
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