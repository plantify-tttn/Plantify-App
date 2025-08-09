import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/pages/comment/comment_page.dart';
import 'package:plantify/pages/home/home_center.dart';
import 'package:plantify/pages/login/login_page.dart';
import 'package:plantify/pages/plants/plant_detail_page.dart';
import 'package:plantify/pages/posts/craeate_post_page.dart';
import 'package:plantify/pages/posts/craete_post.dart';
import 'package:plantify/pages/register/register_page.dart';
import 'package:plantify/pages/search/search_page.dart';
import 'package:plantify/pages/welcome/welcome_page.dart';
import 'package:plantify/viewmodel/login_vm.dart';
import 'package:plantify/viewmodel/register_vm.dart';
import 'package:plantify/viewmodel/search_vm.dart';
import 'package:provider/provider.dart';

class RouterCustom {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouterName.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return WelcomePage();
        },
      ),
      GoRoute(
        path: '/login',
        name: RouterName.login,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (_)=> LoginVm(),
            child: LoginPage(),
          );
        }
      ),
      GoRoute(
        path: '/register',
        name: RouterName.register,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider(
            create: (_)=> RegisterVm(),
            child: RegisterPage(),
          );
        },
      ),
      // GoRoute(
      //   path: '/forgot-password',
      //   name: RouterName.forgotPassword,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const ForgotPasswordPage();
      //   },
      // ),
      // GoRoute(
      //   path: '/verification',
      //   name: RouterName.verification,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const VerificationPage();
      //   },
      // ),
      GoRoute(
        path: '/home',
        name: RouterName.home,
        builder: (BuildContext context, GoRouterState state) {
          return HomeCenter();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/craetePost',
            name: RouterName.createPost,
            builder: (BuildContext context, GoRouterState state) {
              return CreatePostPage();
            },
          ),
          GoRoute(
            path: '/search',
            name: RouterName.search,
            builder: (BuildContext context, GoRouterState state) {
              return ChangeNotifierProvider(
                create: (_)=> SearchVm(),
                child: SearchPage(),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/detailPlat',
                name: RouterName.detailPlant,
                builder: (BuildContext context, GoRouterState state) {
                  final plant = state.extra as PlantModel;
                  return PlantDetailPage(plant: plant);
                },
              ),
            ]
          ),
          GoRoute(
            path: '/comment',
            name: RouterName.comment,
            builder: (BuildContext context, GoRouterState state) {
              final post = state.extra as PostModel;
              return CommentPage(post: post);
            },
          ),
        ]
      ),
      
      // GoRoute(
      //   path: '/my_ticket',
      //   name: RouterName.my_ticket,
      //   builder: (BuildContext context, GoRouterState state) {
      //     final tapIndex = int.tryParse(state.uri.queryParameters['tapIndex'] ?? '0');
      //     return MyTicketPage(tapIndex: tapIndex);
      //   },
      // ),
      // GoRoute(
      //   path: '/profile-information',
      //   name: RouterName.profileInformation,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const ProfileInformationPage();
      //   },
      // ),
      // GoRoute(
      //   path: '/profile',
      //   name: RouterName.profile,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const ProfilePage();
      //   },
      // ),
      // GoRoute(
      //   path: '/profile-ticket',
      //   name: RouterName.profileTicket,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const ProfileTicketPage();
      //   },
      // ),
      // GoRoute(
      //   path: '/profile-setting',
      //   name: RouterName.profileSetting,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const ProfileSettingPage();
      //   },
      // ),
      // GoRoute(
      //   path: '/instruction',
      //   name: RouterName.instruction,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const InstructionPage();
      //   },
      // ),
      // GoRoute(
      //   path: '/route-information',
      //   name: RouterName.routeInformation,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const RouteInformationPage();
      //   },
      // ),
  ]);
}
