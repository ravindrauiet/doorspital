import 'package:door/services/api_client.dart';
import 'package:door/services/profile_service.dart';
import 'package:door/services/service_request_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String kDefaultDoorstepSupportPhoneNumber = '+919837715111';
const String kDefaultDoorstepSupportWhatsAppNumber = '919837715111';

Future<void> showServiceRequestSheet({
  required BuildContext context,
  required String serviceType,
  required String serviceKey,
  required String serviceTitle,
  required String providerKind,
  required String providerId,
  required String providerName,
  required String providerPhone,
  String supportPhoneNumber = kDefaultDoorstepSupportPhoneNumber,
  String supportWhatsAppNumber = kDefaultDoorstepSupportWhatsAppNumber,
}) async {
  final serviceRequestService = ServiceRequestService();
  final profileService = ProfileService();
  final apiClient = ApiClient();
  final formKey = GlobalKey<FormState>();
  final selfNameController = TextEditingController();
  final selfMobileController = TextEditingController();
  final otherPatientNameController = TextEditingController();
  final otherPatientMobileController = TextEditingController();
  final otherRequesterNameController = TextEditingController();
  final otherRequesterMobileController = TextEditingController();
  final notesController = TextEditingController();
  bool isSubmitting = false;
  bool isLoadingProfile = true;
  bool isForSelf = true;
  bool shouldSavePhoneForFuture = false;

  final savedUser = await apiClient.getUserData();
  final savedName =
      savedUser?['userName']?.toString().trim() ??
      savedUser?['name']?.toString().trim() ??
      '';
  final savedPhone = savedUser?['phoneNumber']?.toString().trim() ?? '';
  var profileName = savedName;
  var profilePhone = savedPhone;
  selfNameController.text = savedName;
  selfMobileController.text = savedPhone;
  otherRequesterNameController.text = savedName;
  otherRequesterMobileController.text = savedPhone;

  final token = await apiClient.getToken();
  if (token != null && token.isNotEmpty) {
    final profileResponse = await profileService.getProfile();
    final profile = profileResponse.data ?? const {};
    profileName = profile['userName']?.toString().trim() ?? savedName;
    profilePhone = profile['phoneNumber']?.toString().trim() ?? savedPhone;
    selfNameController.text = profileName;
    selfMobileController.text = profilePhone;
    otherRequesterNameController.text = profileName;
    otherRequesterMobileController.text = profilePhone;
    final mergedUser = Map<String, dynamic>.from(savedUser ?? const {});
    if (profileName.isNotEmpty) {
      mergedUser['userName'] = profileName;
      mergedUser['name'] = profileName;
    }
    if (profilePhone.isNotEmpty) {
      mergedUser['phoneNumber'] = profilePhone;
    }
    if (mergedUser.isNotEmpty) {
      await apiClient.setUserData(mergedUser);
    }
  }
  isLoadingProfile = false;

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request ${serviceTitle.trim().isNotEmpty ? serviceTitle : serviceType}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      providerName.trim().isNotEmpty
                          ? 'Provider: $providerName'
                          : 'Submit your request and use the contact number to call directly.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setStateModal(() {
                                isForSelf = true;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isForSelf
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'For Myself',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isForSelf
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setStateModal(() {
                                isForSelf = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isForSelf
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'For Other',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: !isForSelf
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isLoadingProfile)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (isForSelf) ...[
                      TextFormField(
                        controller: selfNameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: selfMobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter your mobile number'
                            : null,
                      ),
                    ] else ...[
                      TextFormField(
                        controller: otherPatientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter patient name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: otherPatientMobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Patient Mobile Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter patient mobile number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: otherRequesterNameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: otherRequesterMobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Your Mobile Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Enter your mobile number'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: notesController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Explain your request (optional)',
                        hintText:
                            'Briefly describe what help you need, symptoms, timing, or special requirements.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setStateModal(() {
                                  isSubmitting = true;
                                });

                                final leadName = isForSelf
                                    ? selfNameController.text.trim()
                                    : otherPatientNameController.text.trim();
                                final leadMobile = isForSelf
                                    ? selfMobileController.text.trim()
                                    : otherPatientMobileController.text.trim();
                                final requesterName = isForSelf
                                    ? selfNameController.text.trim()
                                    : otherRequesterNameController.text.trim();
                                final requesterMobile = isForSelf
                                    ? selfMobileController.text.trim()
                                    : otherRequesterMobileController.text.trim();
                                final profileNameCandidate = requesterName;
                                final profilePhoneCandidate = requesterMobile;

                                if (token != null && token.isNotEmpty) {
                                  final profilePayload = <String, dynamic>{};
                                  if (profileNameCandidate.isNotEmpty &&
                                      profileNameCandidate != profileName) {
                                    profilePayload['userName'] =
                                        profileNameCandidate;
                                  }
                                  if (profilePhoneCandidate.isNotEmpty &&
                                      profilePhoneCandidate != profilePhone) {
                                    profilePayload['phoneNumber'] =
                                        profilePhoneCandidate;
                                  }

                                  if (profilePayload.isNotEmpty) {
                                    final profileUpdate = await profileService
                                        .updateProfile(profilePayload);
                                    if (profileUpdate.success &&
                                        profileUpdate.data != null) {
                                      profileName =
                                          profileUpdate.data!['userName']
                                              ?.toString()
                                              .trim() ??
                                          profileNameCandidate;
                                      profilePhone =
                                          profileUpdate.data!['phoneNumber']
                                              ?.toString()
                                              .trim() ??
                                          profilePhoneCandidate;
                                      final currentUser =
                                          await apiClient.getUserData() ?? {};
                                      if (profileName.isNotEmpty) {
                                        currentUser['userName'] = profileName;
                                        currentUser['name'] = profileName;
                                      }
                                      if (profilePhone.isNotEmpty) {
                                        currentUser['phoneNumber'] = profilePhone;
                                      }
                                      await apiClient.setUserData(currentUser);
                                      shouldSavePhoneForFuture = true;
                                    }
                                  }
                                }

                                final response =
                                    await serviceRequestService.submitRequest(
                                  ServiceRequestPayload(
                                    name: leadName,
                                    mobileNumber: leadMobile,
                                    requestFor: isForSelf ? 'self' : 'other',
                                    requesterName: requesterName,
                                    requesterMobileNumber: requesterMobile,
                                    serviceType: serviceType,
                                    serviceKey: serviceKey,
                                    serviceTitle: serviceTitle,
                                    providerKind: providerKind,
                                    providerId: providerId,
                                    providerName: providerName,
                                    providerPhone: providerPhone,
                                    notes: notesController.text.trim(),
                                  ),
                                );

                                setStateModal(() {
                                  isSubmitting = false;
                                });

                                if (!sheetContext.mounted) return;
                                if (response.success) {
                                  final currentUser =
                                      await apiClient.getUserData() ?? {};
                                  if (requesterName.isNotEmpty) {
                                    currentUser['userName'] = requesterName;
                                    currentUser['name'] = requesterName;
                                  }
                                  if (requesterMobile.isNotEmpty) {
                                    currentUser['phoneNumber'] = requesterMobile;
                                  }
                                  await apiClient.setUserData(currentUser);

                                  final requestOtp =
                                      response.data?['requestOtp']?.toString() ?? '';
                                  final whatsappMessage = [
                                    'New service request',
                                    'Service: $serviceTitle',
                                    'Request Type: ${isForSelf ? 'For Myself' : 'For Other'}',
                                    'Patient Name: $leadName',
                                    'Patient Mobile: $leadMobile',
                                    if (!isForSelf) 'Requester Name: $requesterName',
                                    if (!isForSelf) 'Requester Mobile: $requesterMobile',
                                    'Provider: ${providerName.trim().isNotEmpty ? providerName : 'Support'}',
                                    'OTP: $requestOtp',
                                    if (notesController.text.trim().isNotEmpty)
                                      'Request Details: ${notesController.text.trim()}',
                                  ].join('\n');
                                  Navigator.pop(sheetContext);
                                  await _showRequestSuccessDialog(
                                    context: context,
                                    requestOtp: requestOtp,
                                    phoneNumber: providerPhone,
                                    serviceTitle: serviceTitle,
                                    whatsappMessage: whatsappMessage,
                                    supportPhoneNumber: supportPhoneNumber,
                                    supportWhatsAppNumber: supportWhatsAppNumber,
                                    profileSaved: shouldSavePhoneForFuture,
                                  );
                                } else {
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response.message ??
                                            'Failed to submit request',
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Request',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _showRequestSuccessDialog({
  required BuildContext context,
  required String requestOtp,
  required String phoneNumber,
  required String serviceTitle,
  required String whatsappMessage,
  required String supportPhoneNumber,
  required String supportWhatsAppNumber,
  bool profileSaved = false,
}) async {
  if (!context.mounted) return;
  final callNumber = phoneNumber.trim().isNotEmpty
      ? phoneNumber.trim()
      : supportPhoneNumber;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Request Submitted for $serviceTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use this OTP for admin verification or follow-up.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD8E0FF)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Generated OTP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    requestOtp,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact Number: $callNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            if (profileSaved) ...[
              const SizedBox(height: 10),
              const Text(
                'Your contact details were saved for future requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _launchWhatsAppWithMessage(
                supportWhatsAppNumber,
                whatsappMessage,
              );
            },
            child: const Text('WhatsApp'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _launchCall(callNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now'),
          ),
        ],
      );
    },
  );
}

Future<void> _launchCall(String phoneNumber) async {
  final normalized = phoneNumber.trim();
  if (normalized.isEmpty) return;
  final uri = Uri.parse('tel:$normalized');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _launchWhatsAppWithMessage(
  String supportWhatsAppNumber,
  String message,
) async {
  final encoded = Uri.encodeComponent(message);
  final uri = Uri.parse('https://wa.me/$supportWhatsAppNumber?text=$encoded');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
