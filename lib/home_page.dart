import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'resource_detail_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Lists to hold all resources and filtered resources
  List<Resource> resources = [];
  List<Resource> filteredResources = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 0;
  final int resourcesPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchTokenAndResources();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetches token and resources when the page is initialized
  Future<void> fetchTokenAndResources() async {
    try {
      final Dio dio = Dio();
      final responseToken = await dio.get('http://10.0.2.2:51526/api/token');
      if (responseToken.statusCode == 200) {
        final Map<String, dynamic> responseData = responseToken.data;
        final String token = responseData['token'];
        await fetchResources(token);
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
      throw Exception('Failed to load token: $e');
    }
  }

  // Fetches resources using the provided token
  Future<void> fetchResources(String token) async {
    try {
      final Dio dio = Dio();
      final response = await dio.get('http://10.0.2.2:51526/api/resources',
          options: Options(headers: {'X-Api-Token': token}));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data['data'];
        setState(() {
          resources = jsonData.map<Resource>((item) {
            final imageUrl = item['image'].replaceAll(
                'https://web-application.ddev.site:8443', 'http://10.0.2.2:51526');
            return Resource(
              name: item['name'],
              imageUrl: imageUrl,
              userName: item['user_name'],
              categoryName: item['category_name'],
              description: item['description'],
            );
          }).toList();
          filterResources();
        });
      } else {
        throw Exception('Failed to load resources');
      }
    } catch (e) {
      throw Exception('Failed to load resources: $e');
    }
  }

  // Filters resources based on current page
  void filterResources() {
    final int startIndex = currentPage * resourcesPerPage;
    final int endIndex = (currentPage + 1) * resourcesPerPage;
    setState(() {
      filteredResources = resources.sublist(startIndex,
          endIndex.clamp(0, resources.length));
    });
  }

  // Refreshes resources when triggered
  Future<void> refreshResources() async {
    try {
      final Dio dio = Dio();
      final responseToken = await dio.get('http://10.0.2.2:51526/api/token');
      if (responseToken.statusCode == 200) {
        final Map<String, dynamic> responseData = responseToken.data;
        final String token = responseData['token'];
        final response = await dio.get('http://10.0.2.2:51526/api/resources',
            options: Options(headers: {'X-Api-Token': token}));
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = response.data['data'];
          setState(() {
            resources = jsonData.map<Resource>((item) {
              final imageUrl = item['image'].replaceAll(
                  'https://web-application.ddev.site:8443', 'http://10.0.2.2:51526');
              return Resource(
                name: item['name'],
                imageUrl: imageUrl,
                userName: item['user_name'],
                categoryName: item['category_name'],
                description: item['description'],
              );
            }).toList();
            currentPage = 0;
            filterResources();
          });
        } else {
          throw Exception('Failed to load resources');
        }
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
      throw Exception('Failed to refresh resources: $e');
    }
  }

  // Goes to the next page of resources
  void nextPage() {
    if ((currentPage + 1) * resourcesPerPage < resources.length) {
      setState(() {
        currentPage++;
        filterResources();
      });
    }
  }

  // Goes to the previous page of resources
  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        filterResources();
      });
    }
  }

  // Filters resources based on search query
  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      final dummyListData = resources
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        filteredResources = dummyListData;
      });
    } else {
      setState(() {
        currentPage = 0;
        filterResources();
      });
    }
  }

  // Views detailed information about a resource
  void viewResourceDetail(Resource resource) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => ResourceDetailPage(resource: resource, title: resource.categoryName),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            refreshResources();
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.article, color: Colors.white),
          ),
        ],
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar to filter resources
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterSearchResults(value);
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Trouver une ressource',
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                disabledBorder: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            // Display filtered resources
            child: filteredResources.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 55, color: Color(0xFF003366)),
                  SizedBox(height: 10),
                  Text(
                    "Aucune ressource trouvée",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredResources.length,
              itemBuilder: (BuildContext context, int index) {
                // Display each resource item
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      viewResourceDetail(filteredResources[index]);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resource image and category
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Image.network(
                                    filteredResources[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10.0,
                              right: 30.0,
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      filteredResources[index].categoryName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.category, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Resource details
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredResources[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Publié par ${filteredResources[index].userName}",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                child: Divider(
                                  color: Colors.grey.shade400,
                                  thickness: 1.0,
                                  height: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Pagination buttons
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              border: Border(
                top: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: currentPage != 0,
                  child: ElevatedButton(
                    onPressed: previousPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: (currentPage + 1) * resourcesPerPage < resources.length,
                  child: ElevatedButton(
                    onPressed: nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Resource {
  final String name;
  final String imageUrl;
  final String userName;
  final String categoryName;
  final String description;

  Resource({
    required this.name,
    required this.imageUrl,
    required this.userName,
    required this.categoryName,
    required this.description,
  });
}
