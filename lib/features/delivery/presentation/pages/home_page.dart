import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../app_state.dart';
import '../../../../dependency_container.dart';
import '../../../cash/presentation/pages/cash_order_by_shipper_page.dart';
import '../../../cash/presentation/pages/cash_order_by_warehouse_page.dart';
import '../../domain/repository/delivery_repository.dart';
import '../components/home_page_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.message ?? 'Có lỗi xảy ra! Vui lòng thử lại!')),
            );
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (!state.isDeliver) {
            return NoPermissionPage(
              message: 'Bạn không có quyền truy cập vào ứng dụng này!',
              onPressed: () => context.read<AuthCubit>().logout(state.auth!.refreshToken),
            );
          }
          // HomePage base on role
          return _HomePageWithBottomNavigation('Xin chào, ${state.auth!.userInfo.username!}');
        } else {
          return _noAuth(context);
        }
      },
    );
  }

  Widget _noAuth(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.of(context).pushNamed('/dev'), //NOTE: dev
      child: LoginPage(
        showTitle: false,
        formTitle: 'VTV Delivery',
        onLoginPressed: (username, password) async {
          context.read<AuthCubit>().loginWithUsernameAndPassword(username: username, password: password);
        },
      ),
    );
  }
}

class _HomePageWithBottomNavigation extends StatefulWidget {
  const _HomePageWithBottomNavigation(this.title);

  final String title;

  @override
  State<_HomePageWithBottomNavigation> createState() => _HomePageWithBottomNavigationState();
}

class _HomePageWithBottomNavigationState extends State<_HomePageWithBottomNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  bool get isAppBarVisible {
    return _selectedIndex == 0;
  }

  void fetchDeliveryInfo(BuildContext context, AppState? state) {
    final AppState appState;
    if (state == null) {
      appState = Provider.of<AppState>(context, listen: false);
    } else {
      appState = state;
    }
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated && appState.deliveryInfo == null) {
      appState.fetchDeliveryInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomePageContent(),
      Consumer<AppState>(
        builder: (context, state, _) {
          switch (state.typeWork) {
            case TypeWork.SHIPPER:
              return const CashOrderByShipperPage();
            case TypeWork.WAREHOUSE:
              return const CashOrderByWarehousePage();
            default:
              return const MessageScreen(message: 'TypeWork không hợp lệ!');
            // return Center(
            //   child: Text('deliveryInfo: ${Provider.of<AppState>(context, listen: false).deliveryInfo.toString()}'),
            // );
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.deliveryInfo == null) {
          fetchDeliveryInfo(context, state);
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return child!;
        }
      },
      child: Scaffold(
        appBar: isAppBarVisible
            ? AppBar(
                title: Text(widget.title),
                centerTitle: true,
                actions: _actions(context),
              )
            : null,
        bottomNavigationBar: _bottomNavigationBar(),
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      //# Profile
      IconButton(
        onPressed: () async {
          var deliver = await sl<DeliveryRepository>().getDeliverInfo();
          deliver.fold(
            (error) => null,
            (ok) => Navigator.of(context).pushNamed(
              '/profile',
              arguments: ok.data!,
            ),
          );
        },
        icon: const Icon(Icons.account_circle_outlined),
      ),
    ];
  }

  Widget? _bottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _onItemTapped,
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Đơn hàng'),
      ],
    );
  }
}
