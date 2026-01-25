import 'package:flutter/material.dart';
import 'package:petcare_app/create_account/create_owner.dart';
import 'package:petcare_app/create_account/create_clinic.dart';

class SignupScreen extends StatelessWidget {
	const SignupScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFEFF7FF),
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Image.asset(
										'images/logo.png',
                    width: 80,
                    height: 80,
										fit: BoxFit.contain,
									),
								const SizedBox(height: 20),
								const Text(
									'Create Account',
									style: TextStyle(
										fontSize: 22,
										fontWeight: FontWeight.w700,
										color: Colors.black87,
									),
								),
								const SizedBox(height: 6),
								const Text(
									'Choose your account type',
									style: TextStyle(
										fontSize: 14,
										color: Colors.black54,
									),
								),
								const SizedBox(height: 24),
								_RoleCard(
									title: 'Pet Owner',
									subtitle: 'Manage your pets\' health',
									bulletPoints: const [
										'Add multiple pet profiles',
										'Track medical records',
										'Monitor activities',
										'Find vet clinics',
									],
									buttonLabel: 'Continue as Pet Owner',
									onPressed: () {
										Navigator.of(context).push(
											MaterialPageRoute(builder: (context) => const CreateOwnerScreen()),
										);
									},
								),
								const SizedBox(height: 18),
								_RoleCard(
									title: 'Vet Clinic',
									subtitle: 'Connect with pet owners',
									bulletPoints: const [
										'Create clinic profile',
										'Increase visibility',
										'View patient info',
										'Share services',
									],
									buttonLabel: 'Continue as Vet Clinic',
									onPressed: () {
										Navigator.of(context).push(
											MaterialPageRoute(builder: (context) => const CreateClinicScreen()),
										);
									},
								),
								const SizedBox(height: 20),
								RichText(
									text: TextSpan(
										text: 'Already have an account? ',
										style: const TextStyle(color: Colors.black87, fontSize: 14),
										children: [
											WidgetSpan(
												child: GestureDetector(
													onTap: () {
														Navigator.of(context).pushNamed('/login');
													},
													child: const Padding(
														padding: EdgeInsets.only(left: 4),
														child: Text(
															'Sign in',
															style: TextStyle(
																color: Colors.blue,
																fontWeight: FontWeight.w600,
															),
														),
													),
												),
											),
										],
									),
								),
							],
						),
					),
				),
			),
		);
	}
}

class _RoleCard extends StatelessWidget {
	const _RoleCard({
		required this.title,
		required this.subtitle,
		required this.bulletPoints,
		required this.buttonLabel,
		required this.onPressed,
	});

	final String title;
	final String subtitle;
	final List<String> bulletPoints;
	final String buttonLabel;
	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.grey.shade300),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.04),
						blurRadius: 12,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						Image.asset(
								title == 'Pet Owner' ? 'images/petowner.png' : 'images/vetclinic.png',
                width: 70,
							  height: 70,
								fit: BoxFit.contain,
							),
						const SizedBox(height: 14),
						Text(
							title,
							style: const TextStyle(
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Colors.black87,
							),
						),
						const SizedBox(height: 4),
						Text(
							subtitle,
							textAlign: TextAlign.center,
							style: const TextStyle(
								fontSize: 13,
								color: Colors.black54,
							),
						),
						const SizedBox(height: 16),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: bulletPoints
									.map(
										(text) => Padding(
											padding: const EdgeInsets.only(bottom: 8),
											child: Row(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Container(
														width: 6,
														height: 6,
														margin: const EdgeInsets.only(top: 6, right: 10),
														decoration: BoxDecoration(
															color: Colors.black87,
															borderRadius: BorderRadius.circular(3),
														),
													),
													Expanded(
														child: Text(
															text,
															style: const TextStyle(
																fontSize: 14,
																color: Colors.black87,
															),
														),
													),
												],
											),
										),
									)
									.toList(),
						),
						const SizedBox(height: 10),
						SizedBox(
							width: double.infinity,
							height: 44,
							child: ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.black,
									foregroundColor: Colors.white,
									elevation: 0,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
									textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
								),
								onPressed: onPressed,
								child: Text(buttonLabel),
							),
						),
					],
				),
			),
		);
	}
}
