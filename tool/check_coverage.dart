import 'dart:io';

const _minimumCoverage = 70.0;

void main(List<String> arguments) {
  final path = arguments.isEmpty ? 'coverage/lcov.info' : arguments.single;
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Arquivo de cobertura não encontrado: $path');
    exitCode = 2;
    return;
  }

  final groups = {'domínio': _Coverage(), 'ViewModels': _Coverage()};
  String? currentGroup;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final source = line.substring(3).replaceAll('\\', '/');
      currentGroup = switch (source) {
        final path
            when path.contains('lib/features/financial_account/domain/') =>
          'domínio',
        final path when path.contains('lib/') && path.endsWith('_cubit.dart') =>
          'ViewModels',
        _ => null,
      };
      continue;
    }
    if (line == 'end_of_record') {
      currentGroup = null;
      continue;
    }
    if (currentGroup != null && line.startsWith('DA:')) {
      final fields = line.substring(3).split(',');
      if (fields.length >= 2) {
        groups[currentGroup]!.add(int.parse(fields[1]));
      }
    }
  }

  var failed = false;
  for (final MapEntry(key: name, value: coverage) in groups.entries) {
    if (coverage.total == 0) {
      stderr.writeln('Nenhuma linha de $name foi encontrada em $path.');
      failed = true;
      continue;
    }
    stdout.writeln(
      '$name: ${coverage.percentage.toStringAsFixed(2)}% '
      '(${coverage.hit}/${coverage.total})',
    );
    if (coverage.percentage < _minimumCoverage) {
      stderr.writeln(
        '$name abaixo da cobertura mínima de '
        '${_minimumCoverage.toStringAsFixed(0)}%.',
      );
      failed = true;
    }
  }

  if (failed) exitCode = 1;
}

final class _Coverage {
  int hit = 0;
  int total = 0;

  void add(int executions) {
    total++;
    if (executions > 0) hit++;
  }

  double get percentage => total == 0 ? 0 : hit * 100 / total;
}
