import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/room_repository.dart';
import 'firebase_options.dart';
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/auth_cubit/auth_state.dart';
import 'logic/room_cubit/room_cubit.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => RoomRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(context.read<AuthRepository>())),
          BlocProvider(create: (context) => RoomCubit(context.read<RoomRepository>())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Home Automation',
          theme: ThemeData.dark(),
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                context.read<RoomCubit>().listenToRooms();
                return const DashboardScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}