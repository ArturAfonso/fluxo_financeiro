import 'package:fluxo_financeiro/core/errors/failure.dart';

String failureMessage(Failure failure) => switch (failure) {
  OfflineFailure() => 'Sem conexão. Confira a internet e tente novamente.',
  RateLimitFailure() =>
    'Muitas solicitações. Aguarde um pouco e tente novamente.',
  NotFoundFailure() => 'A transação não foi encontrada.',
  ParsingFailure() => 'Os dados recebidos não puderam ser processados.',
  _ => 'Não foi possível carregar os dados. Tente novamente.',
};
