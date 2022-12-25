import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _apiKey = "PLACE_YOUR API_KEY_HERE";

  String? _searchGif;
  List gifs = [];
  final _debouncer = Debouncer(milliseconds: 300);

  bool isDesktopHeight(BuildContext context) =>
      MediaQuery.of(context).size.height >= 730;

  bool isMobileWidth(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  var isLoaded = false;
  bool isLoadingMore = false;
  int _page = 1;
  int _limit() => isDesktopHeight(context)
      ? 16
      : isDesktopHeight(context) && isMobileWidth(context)
          ? 18
          : 12;

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Giphy Search');

  final scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.addListener(() {
      _searchGif = _controller.text;
    });
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchGifs('trendingUrl');
  }

  Future<void> fetchGifs(selUrl) async {
    String url = '';

    if (selUrl == 'trendingUrl') {
      url =
          'https://api.giphy.com/v1/gifs/trending?api_key=$_apiKey&limit=$_limit&rating=g';
    } else {
      url =
          'https://api.giphy.com/v1/gifs/search?api_key=Xn60G09p07MSk3Kotq6u7kTYj4SN7S44&q=$_searchGif&limit=$_limit&offset=$_page&rating=g&lang=en';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        gifs = gifs + result['data'];
      });
      setState(() {
        isLoaded = true;
      });
    }
  }

// Flutter Pagination. Source: https://www.youtube.com/watch?v=Gsfjcpo6wcA
  Future<void> _scrollListener() async {
    if (isLoadingMore) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoadingMore = true;
      });
      _page += 1;
      setState(() {
        isLoadingMore = false;
      });
      await fetchGifs('searchUrl');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 48, 73, 1),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(247, 127, 0, 1),
          title: customSearchBar,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        controller: _controller,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            // fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onChanged: (value) {
                          _debouncer.run(() => {
                                setState(() {
                                  gifs = [];
                                  _page = 1;
                                }),
                                if (value == '')
                                  {fetchGifs('trendingUrl')}
                                else
                                  {fetchGifs('searchUrl')}
                              });
                        },
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Giphy Search');
                  }
                });
              },
              icon: customIcon,
            )
          ],
          centerTitle: true,
        ),
        body: isLoaded == true
            // ? Container(
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: currentWidth > 1200
                        ? const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20)
                        : currentWidth > 600
                            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 250,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20)
                            : const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2.5,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                    itemCount: gifs.length,
                    itemBuilder: (BuildContext ctx, index) {
                      final gif = gifs[index];
                      final gifUrl = gif['images']['480w_still']['url'];

                      return Image.network(
                        '${gifUrl}',
                        height: 400.0,
                        width: 400.0,
                        fit: BoxFit.cover,
                      );
                    }),
              )
            : _searchGif == ''
                ? Center(
                    child: Container(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(10.0),
                    child: GridView.builder(
                        controller: scrollController,
                        gridDelegate: currentWidth > 600
                            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20)
                            : const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: gifs.length,
                        itemBuilder: (BuildContext ctx, index) {
                          final gif = gifs[index];
                          final gifUrl = gif['images']['fixed_height']['url'];
                          return Image.network(
                            '${gifUrl}',
                            height: 200.0,
                            width: 200.0,
                            fit: BoxFit.cover,
                          );
                        }),
                  ));
  }
}

// Delay Search while typing. Source: https://medium.com/fabcoding/implementing-search-in-flutter-delay-search-while-typing-8508ea4004c6
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
