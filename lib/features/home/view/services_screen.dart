import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/features/doorstep_service/services/doorstep_content_service.dart';
import 'package:door/features/home/components/doorstep_service_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final DoorstepContentService _contentService = DoorstepContentService();
  bool _isLoading = true;
  String? _error;
  DoorstepPageContent? _content;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final response = await _contentService.getDoorstepContent();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _content = response.data;
      } else {
        _error = response.message ?? 'Failed to load services';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _content?.servicesPageTitle ?? 'Doorstep Services';
    final pageSubtitle =
        _content?.servicesPageSubtitle ?? 'Book trusted medical services at your home';
    final services = _content?.servicesPageItems ?? const <DoorstepServiceContent>[];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouteConstants.homeScreen),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pageSubtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SearchField(onTap: () {}),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          services.isEmpty
                              ? const Center(child: Text('No services available'))
                              : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 1.0,
                                          ),
                                      itemCount: services.length,
                                      itemBuilder: (context, index) {
                                        final service = services[index];
                                        return GestureDetector(
                                          onTap: () {
                                            context.pushNamed(
                                              RouteConstants
                                                  .doorstepServiceDetailsScreen,
                                              extra: service.serviceKey,
                                            );
                                          },
                                          child: DoorstepServiceCard(
                                            name: service.title,
                                            imagePath: service.cardImage,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
