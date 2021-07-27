import 'package:carousel_slider/carousel_slider.dart';
import 'package:carrot_clone/components/manner_temparature.dart';
import 'package:carrot_clone/repositories/contents_repository.dart';
import 'package:carrot_clone/repositories/firebase_repository.dart';
import 'package:carrot_clone/screens/update_screen.dart';
import 'package:carrot_clone/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DetailScreen extends StatefulWidget {
  final String docId;
  final String dong;
  final String cid;
  final String image;
  final String title;
  final String location;
  final String price;
  final String likes;

  const DetailScreen({
    Key? key,
    required this.cid,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.likes,
    required this.dong,
    required this.docId,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, String> data;
  late ContentsRepository _contentsRepository;
  late FirebaseRepository _firebaseRepository;
  late Size size;
  List<String> imgList = [];
  late int _currentIndex;
  double scrollPositionToAlpha = 0;
  ScrollController _appBarScrollController = ScrollController();
  late AnimationController _appBarAnimationController;
  late Animation _colorTween;
  late bool _isMyFavoriteContent;

  @override
  void initState() {
    data = {
      "cid": widget.cid,
      "image": widget.image,
      "title": widget.title,
      "location": widget.location,
      "price": widget.price,
      "likes": widget.likes
    };
    _isMyFavoriteContent = false;
    _appBarAnimationController = AnimationController(vsync: this);
    _colorTween = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_appBarAnimationController);
    _appBarScrollController.addListener(() {
      setState(() {
        if (_appBarScrollController.offset > 255)
          scrollPositionToAlpha = 255;
        else
          scrollPositionToAlpha = _appBarScrollController.offset;
        _appBarAnimationController.value = scrollPositionToAlpha / 255;
      });
    });
    _firebaseRepository = FirebaseRepository();
    _contentsRepository = ContentsRepository();
    _loadMyFavoriteContentState();
    super.initState();
  }

  _loadMyFavoriteContentState() async {
    bool checkIsMyFavorite =
        await _contentsRepository.isMyFavoriteContents("${data['cid']}");
    setState(() {
      _isMyFavoriteContent = checkIsMyFavorite;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    imgList = [
      "${data['image']}",
      "${data['image']}",
      "${data['image']}",
      "${data['image']}",
    ];
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }

  Widget _bottomNavigationBarWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      width: size.width,
      height: 55,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              _isMyFavoriteContent
                  ? await _contentsRepository
                      .deleteMyFavoriteContent("${data['cid']}")
                  : await _contentsRepository.addMyFavoriteContent(data);
              setState(() {
                _isMyFavoriteContent = !_isMyFavoriteContent;
              });

              print("관심상품이벤트발생");
            },
            child: SvgPicture.asset(
              _isMyFavoriteContent
                  ? "assets/svg/heart_on.svg"
                  : "assets/svg/heart_off.svg",
              width: 20,
              height: 20,
              color: Color(0xfff08f4f),
            ),
          ),
          SizedBox(width: 15),
          VerticalDivider(width: 1, thickness: 1.0),
          SizedBox(width: 15),
          Column(
            children: [
              Text(
                DataUtils.calcStringToWon("${data["price"]}"),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "가격제안불가",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 7.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    // BoxDecoration 사용시에는 color를 BoxDecoration 안에 설정해줘야 함.
                    color: Color(0xfff08f4f),
                  ),
                  child: Text(
                    "채팅으로 거래하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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

  Widget _makeAnimatedIcon(IconData iconData) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Icon(
        iconData,
        color: _colorTween.value,
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      backgroundColor: Colors.white.withAlpha(scrollPositionToAlpha.toInt()),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
          });
        },
        icon: _makeAnimatedIcon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: _makeAnimatedIcon(Icons.share_outlined),
        ),
        _makePopUpMenu(),
      ],
    );
  }

  Widget _makePopUpMenu() {
    return PopupMenuButton(
      icon: _makeAnimatedIcon(Icons.more_vert),
      onSelected: (int value) {
        if (value == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateScreen(
                docId: widget.docId.toString(),
                dong: widget.dong.toString(),
                cid: "${data['cid']}",
                image: "${data['image']}",
                title: "${data['title']}",
                location: "${data['location']}",
                price: "${data['price']}",
                likes: "${data['likes']}",
              ),
            ),
          );
        } else {
          _showDialog();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("수정"),
          value: 1,
        ),
        PopupMenuItem(
          child: Text("삭제"),
          value: 2,
        )
      ],
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("게시물 삭제"),
          content: Text("삭제하시겠습니까?"),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _firebaseRepository.deleteDoc(widget.dong, widget.docId);

                    var count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  },
                  child: new Text("삭제"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text("취소"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _bodyWidget() {
    return CustomScrollView(
      controller: _appBarScrollController,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _makeSliderImage(),
              _sellerSimpleInfo(),
              Divider(height: 1, thickness: 1),
              _contentDetail(),
              Divider(height: 1, thickness: 1),
              _otherSellContents(),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildListDelegate(
              List.generate(20, (index) {
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          color: Colors.grey,
                          height: 120,
                        ),
                      ),
                      Text("상품 제목", style: TextStyle(fontSize: 14.0)),
                      Text("금액",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _makeSliderImage() {
    return Container(
      child: Stack(
        children: [
          Hero(
            tag: "${data['cid']}",
            // Hero애니메이션 도중에 발생하는 오버플로우 때문에 애니매이션 동작 재정의
            flightShuttleBuilder: (
              BuildContext flightContext,
              Animation<double> animation,
              HeroFlightDirection flightDirection,
              BuildContext fromHeroContext,
              BuildContext toHeroContext,
            ) {
              return SingleChildScrollView(
                // fromHeroContext: 시작크기로 애니메이션 진행, toHeroContext: 끝크기로 애니메이션 진행
                child: toHeroContext.widget,
              );
            },
            child: Container(
              child: CarouselSlider(
                items: imgList.map((url) {
                  return Column(
                    children: [
                      Image.asset(
                        url,
                        width: size.width,
                        fit: BoxFit.fill,
                      ),
                    ],
                  );
                }).toList(),
                options: CarouselOptions(
                    height: size.width,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerSimpleInfo() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: Image.asset("assets/images/user.png").image,
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "개발하는곰",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text("포항시 양덕동"),
            ],
          ),
          Expanded(
            child: MannerTemperature(mannerTemperature: 37.5),
          ),
        ],
      ),
    );
  }

  Widget _contentDetail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.0),
          Text(
            "${data["title"]}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            "디지털/가전 ・ 22시간 전",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 15.0),
          Text(
            "선물 받은 새상품 입니다.\n상품 꺼내보기만 했습니다.\n거래는 직거래만 합니다.",
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15.0),
          Text(
            "채팅 3 ・ 관심 17 ・ 조회 235",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }

  Widget _otherSellContents() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "판매자의 다른 판매 상품",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "모두보기",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
