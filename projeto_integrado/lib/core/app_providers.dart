import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:projeto_integrado/core/favorites_provider.dart';
import 'package:projeto_integrado/core/history_provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/auth/viewmodel/login_viewmodel.dart';
import 'package:projeto_integrado/features/auth/viewmodel/signup_viewmodel.dart';
import 'package:projeto_integrado/features/chamados/viewmodel/chamados_viewmodel.dart';
import 'package:projeto_integrado/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:projeto_integrado/features/dashboard/viewmodel/alertas_viewmodel.dart';
import 'package:projeto_integrado/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:projeto_integrado/features/dashboard/viewmodel/feedbacks_viewmodel.dart';
import 'package:projeto_integrado/features/home/viewmodel/add_user_viewmodel.dart';
import 'package:projeto_integrado/features/home/viewmodel/production_efficiency_viewmodel.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import 'package:projeto_integrado/features/profile/viewmodel/meus_feedbacks_viewmodel.dart';
import 'package:projeto_integrado/features/profile/viewmodel/seu_nivel_viewmodel.dart';
import 'package:projeto_integrado/features/profile/viewmodel/historico_viewmodel.dart';
import 'package:projeto_integrado/features/profile/viewmodel/notificacoes_viewmodel.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LoginViewModel()),
    ChangeNotifierProvider(create: (_) => SignupViewModel()),
    ChangeNotifierProvider(create: (_) => DashboardViewModel()),
    ChangeNotifierProvider(create: (_) => FeedbacksViewModel()),
    ChangeNotifierProvider(create: (_) => AlertasViewModel()),
    ChangeNotifierProvider(create: (_) => ChamadosViewModel()),
    ChangeNotifierProvider(create: (_) => ChatViewModel()),
    ChangeNotifierProvider(create: (_) => CurrentUserViewModel()),
    ChangeNotifierProvider(create: (_) => SeuNivelViewModel()),
    ChangeNotifierProvider(create: (_) => MeusFeedbacksViewModel()),
    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ChangeNotifierProvider(create: (_) => HistoryProvider()),
    ChangeNotifierProvider(create: (_) => AddUserViewModel()),
    ChangeNotifierProvider(create: (_) => HistoricoViewModel()),
    ChangeNotifierProvider(create: (_) => NotificacoesViewModel()),
    ChangeNotifierProxyProvider<
      CurrentUserViewModel,
      ProductionEfficiencyViewModel
    >(
      create: (context) =>
          ProductionEfficiencyViewModel(context.read<CurrentUserViewModel>()),
      update: (context, currentUser, previous) {
        if (previous == null) {
          return ProductionEfficiencyViewModel(currentUser);
        }
        previous.updateCurrentUser(currentUser);
        return previous;
      },
    ),
  ];
}
