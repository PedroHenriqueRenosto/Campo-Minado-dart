import 'dart:io';
import 'dart:math';

// Configurações do jogo
int linhas = 12;
int colunas = 12;
int totalBombas = 8;

// Tabuleiros
List<List<String>> tabuleiro = [];
List<List<String>> visivel = [];

bool jogoAcabou = false;
bool ganhou = false;
int bandeiras = 0;

// ─── Funções do tabuleiro ─────────────────────────────────────────────────────

void criarTabuleiro() {
  tabuleiro = [];
  visivel = [];

  for (int i = 0; i < linhas; i++) {
    List<String> linhaTab = [];
    List<String> linhaVis = [];

    for (int j = 0; j < colunas; j++) {
      linhaTab.add('0');
      linhaVis.add('#');
    }

    tabuleiro.add(linhaTab);
    visivel.add(linhaVis);
  }
}

void colocarBombas() {
  Random sorteio = Random();
  int bombasColocadas = 0;

  while (bombasColocadas < totalBombas) {
    int l = sorteio.nextInt(linhas);
    int c = sorteio.nextInt(colunas);

    if (tabuleiro[l][c] != 'B') {
      tabuleiro[l][c] = 'B';
      bombasColocadas++;
    }
  }
}

int contarBombasAoRedor(int l, int c) {
  int contador = 0;

  for (int dl = -1; dl <= 1; dl++) {
    for (int dc = -1; dc <= 1; dc++) {
      int nl = l + dl;
      int nc = c + dc;

      if (nl >= 0 && nl < linhas && nc >= 0 && nc < colunas) {
        if (tabuleiro[nl][nc] == 'B') {
          contador++;
        }
      }
    }
  }

  return contador;
}

void preencherNumeros() {
  for (int l = 0; l < linhas; l++) {
    for (int c = 0; c < colunas; c++) {
      if (tabuleiro[l][c] != 'B') {
        int qtd = contarBombasAoRedor(l, c);
        tabuleiro[l][c] = qtd.toString();
      }
    }
  }
}

void revelar(int l, int c) {
  if (l < 0 || l >= linhas || c < 0 || c >= colunas) return;
  if (visivel[l][c] != '#') return;

  visivel[l][c] = tabuleiro[l][c];

  if (tabuleiro[l][c] == '0') {
    for (int dl = -1; dl <= 1; dl++) {
      for (int dc = -1; dc <= 1; dc++) {
        revelar(l + dl, c + dc);
      }
    }
  }
}

bool verificarVitoria() {
  for (int l = 0; l < linhas; l++) {
    for (int c = 0; c < colunas; c++) {
      if (tabuleiro[l][c] != 'B' && visivel[l][c] == '#') {
        return false;
      }
    }
  }
  return true;
}

void mostrarTodasBombas() {
  for (int l = 0; l < linhas; l++) {
    for (int c = 0; c < colunas; c++) {
      if (tabuleiro[l][c] == 'B') {
        visivel[l][c] = 'B';
      }
    }
  }
}

// ─── Mostrar tabuleiro ────────────────────────────────────────────────────────

void mostrarTabuleiro() {
  print('');
  print('=== CAMPO MINADO ===');
  print('Tamanho: ${linhas}x${colunas}  |  Bombas: $totalBombas  |  Bandeiras: $bandeiras  |  Restam: ${totalBombas - bandeiras}');
  print('');

  // Números das colunas
  stdout.write('    ');
  for (int c = 0; c < colunas; c++) {
    if (c + 1 < 10) {
      stdout.write(' ${c + 1} ');
    } else {
      stdout.write('${c + 1} ');
    }
  }
  print('');

  stdout.write('    ');
  for (int c = 0; c < colunas; c++) {
    stdout.write('---');
  }
  print('');

  for (int l = 0; l < linhas; l++) {
    if (l + 1 < 10) {
      stdout.write(' ${l + 1} |');
    } else {
      stdout.write('${l + 1} |');
    }

    for (int c = 0; c < colunas; c++) {
      String celula = visivel[l][c];

      if (celula == '#') {
        stdout.write(' . ');
      } else if (celula == 'F') {
        stdout.write(' F ');
      } else if (celula == 'B') {
        stdout.write(' * ');
      } else if (celula == '0') {
        stdout.write('   ');
      } else {
        stdout.write(' $celula ');
      }
    }

    print('|');
  }

  stdout.write('    ');
  for (int c = 0; c < colunas; c++) {
    stdout.write('---');
  }
  print('');
}

// ─── Menu de configuração ─────────────────────────────────────────────────────

void mostrarMenuConfiguracao() {
  print('');
  print('=== CONFIGURAR JOGO ===');
  print('Configuracao atual: ${linhas}x${colunas}, $totalBombas bombas');
  print('');
  print('Opcoes rapidas:');
  print('  1 - Facil    (12x12,  8 bombas)');
  print('  2 - Medio    (12x12, 20 bombas)');
  print('  3 - Dificil  (12x12, 40 bombas)');
  print('  4 - Extremo  (12x12, 60 bombas)');
  print('  5 - Personalizado (voce escolhe o numero de bombas)');
  print('  6 - Voltar sem alterar');
  print('');
  stdout.write('Escolha: ');
}

// Pede ao jogador para configurar o jogo e reinicia
void configurarJogo() {
  mostrarMenuConfiguracao();

  String? entrada = stdin.readLineSync();

  if (entrada == null || entrada.trim().isEmpty) return;

  String opcao = entrada.trim();

  // Máximo de bombas permitido (deixa pelo menos 20 células livres)
  int maxBombas = (linhas * colunas) - 20;

  if (opcao == '1') {
    totalBombas = 8;
    print('Dificuldade: Facil. Bombas: $totalBombas');
  } else if (opcao == '2') {
    totalBombas = 20;
    print('Dificuldade: Medio. Bombas: $totalBombas');
  } else if (opcao == '3') {
    totalBombas = 40;
    print('Dificuldade: Dificil. Bombas: $totalBombas');
  } else if (opcao == '4') {
    totalBombas = 60;
    print('Dificuldade: Extremo. Bombas: $totalBombas');
  } else if (opcao == '5') {
    print('');
    print('O tabuleiro tem ${linhas * colunas} celulas.');
    print('Minimo: 1 bomba  |  Maximo: $maxBombas bombas');
    stdout.write('Quantas bombas voce quer? ');

    String? entradaBombas = stdin.readLineSync();
    int? novasBombas = int.tryParse(entradaBombas ?? '');

    if (novasBombas == null) {
      print('Numero invalido. Mantendo $totalBombas bombas.');
      return;
    }

    if (novasBombas < 1) {
      print('Minimo e 1 bomba. Usando 1 bomba.');
      totalBombas = 1;
    } else if (novasBombas > maxBombas) {
      print('Maximo e $maxBombas bombas. Usando $maxBombas bombas.');
      totalBombas = maxBombas;
    } else {
      totalBombas = novasBombas;
      print('Bombas definidas: $totalBombas');
    }
  } else if (opcao == '6') {
    print('Configuracao mantida.');
    return;
  } else {
    print('Opcao invalida. Configuracao mantida.');
    return;
  }

  // Reinicia o jogo com a nova configuração
  jogoAcabou = false;
  ganhou = false;
  bandeiras = 0;
  criarTabuleiro();
  colocarBombas();
  preencherNumeros();

  print('Novo jogo iniciado com $totalBombas bombas!');
}

// ─── Função principal ─────────────────────────────────────────────────────────

void main() {
  print('');
  print('Bem-vindo ao Campo Minado!');
  print('');
  print('Comandos:');
  print('  r <linha> <coluna>  ->  revelar celula      (ex: r 3 5)');
  print('  f <linha> <coluna>  ->  colocar bandeira    (ex: f 1 2)');
  print('  b                   ->  configurar bombas e dificuldade');
  print('  n                   ->  novo jogo');
  print('  s                   ->  sair');
  print('');
  print('Legenda:  . = escondido  |  F = bandeira  |  * = bomba');
  print('');

  criarTabuleiro();
  colocarBombas();
  preencherNumeros();

  while (true) {
    mostrarTabuleiro();

    // Mensagem de fim de jogo
    if (jogoAcabou) {
      if (ganhou) {
        print('PARABENS! Voce encontrou todas as celulas seguras!');
      } else {
        print('BOOM! Voce pisou em uma bomba! Fim de jogo.');
      }
      print('');
      print('O que deseja fazer?');
      print('  n - Novo jogo com as mesmas bombas');
      print('  b - Configurar bombas e comecar de novo');
      print('  s - Sair');
      stdout.write('Escolha: ');

      String? resposta = stdin.readLineSync();

      if (resposta == 'n') {
        jogoAcabou = false;
        ganhou = false;
        bandeiras = 0;
        criarTabuleiro();
        colocarBombas();
        preencherNumeros();
      } else if (resposta == 'b') {
        configurarJogo();
      } else if (resposta == 's') {
        print('Ate mais!');
        break;
      }

      continue;
    }

    // Lê o comando
    stdout.write('Comando: ');
    String? entrada = stdin.readLineSync();

    if (entrada == null || entrada.trim().isEmpty) {
      continue;
    }

    List<String> partes = entrada.trim().split(' ');
    String comando = partes[0];

    // Sair
    if (comando == 's') {
      print('Ate mais!');
      break;
    }

    // Novo jogo
    if (comando == 'n') {
      jogoAcabou = false;
      ganhou = false;
      bandeiras = 0;
      criarTabuleiro();
      colocarBombas();
      preencherNumeros();
      print('Novo jogo iniciado!');
      continue;
    }

    // Configurar bombas
    if (comando == 'b') {
      configurarJogo();
      continue;
    }

    // Revelar ou bandeira
    if (comando == 'r' || comando == 'f') {
      if (partes.length < 3) {
        print('Faltou linha e coluna. Exemplo: ${comando} 3 5');
        continue;
      }

      int? linha = int.tryParse(partes[1]);
      int? coluna = int.tryParse(partes[2]);

      if (linha == null || coluna == null) {
        print('Linha e coluna precisam ser numeros inteiros.');
        continue;
      }

      // Converte para índice (jogador usa 1, o código usa 0)
      linha = linha - 1;
      coluna = coluna - 1;

      if (linha < 0 || linha >= linhas || coluna < 0 || coluna >= colunas) {
        print('Posicao fora do tabuleiro. Linhas: 1 a $linhas, Colunas: 1 a $colunas');
        continue;
      }

      if (comando == 'r') {
        if (visivel[linha][coluna] == 'F') {
          print('Tem uma bandeira aqui! Use f para remover primeiro.');
          continue;
        }

        if (visivel[linha][coluna] != '#') {
          print('Essa celula ja foi revelada.');
          continue;
        }

        if (tabuleiro[linha][coluna] == 'B') {
          mostrarTodasBombas();
          jogoAcabou = true;
          ganhou = false;
        } else {
          revelar(linha, coluna);

          if (verificarVitoria()) {
            jogoAcabou = true;
            ganhou = true;
          }
        }
      }

      if (comando == 'f') {
        if (visivel[linha][coluna] != '#' && visivel[linha][coluna] != 'F') {
          print('Nao e possivel colocar bandeira em celula ja revelada.');
          continue;
        }

        if (visivel[linha][coluna] == 'F') {
          visivel[linha][coluna] = '#';
          bandeiras--;
          print('Bandeira removida.');
        } else {
          if (bandeiras >= totalBombas) {
            print('Voce ja usou todas as ${totalBombas} bandeiras!');
          } else {
            visivel[linha][coluna] = 'F';
            bandeiras++;
            print('Bandeira colocada!');
          }
        }
      }
    } else {
      print('Comando desconhecido. Use: r, f, b, n ou s');
    }
  }
}