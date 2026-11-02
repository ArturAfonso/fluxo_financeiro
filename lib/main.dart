import 'package:fluxo_financeiro/app/app.dart';
import 'package:fluxo_financeiro/app/di/injection.dart';
import 'package:fluxo_financeiro/app/router/app_router.dart';
import 'package:fluxo_financeiro/app/theme/theme_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await configureDependencies();
  runApp(
    FluxoFinanceiroApp(
      router: createAppRouter(),
      themeCubit: getIt<ThemeCubit>(),
    ),
  );
}
