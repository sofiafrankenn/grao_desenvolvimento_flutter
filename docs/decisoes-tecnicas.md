# Decisões técnicas — do CP4 ao CP5

Registro curto do que foi decidido e por quê.

## 1. Banco de dados: Supabase

O enunciado aceita Supabase ou Firebase. Ficamos com o Supabase porque as tabelas são SQL (`supabase/schema.sql`), dá para conferir os dados direto no painel e a explicação em aula fica mais simples.

Tabelas:

- `transactions` — id, título, valor, tipo (gasto/entrada), categoria, data e observação.
- `goals` — categoria (chave) e limite mensal.

As chaves entram por `--dart-define` (`lib/config/env.dart`) e nunca são commitadas.

## 2. Repositório com interface e mock

`GraoRepository` define o que o app precisa (listar, criar, editar, excluir, metas). Existem duas implementações:

- `SupabaseRepository`, quando há chaves;
- `MockRepository`, em memória, quando não há chaves, não há internet ou o Supabase falha.

Se o banco falhar no meio do uso, o `AppState` troca para o mock sem derrubar o app e a tela **Eu** mostra um aviso. Isso também garante que a apresentação em aula não dependa do Wi-Fi.

## 3. Estado do app

`AppState` (um `ChangeNotifier`) guarda transações, metas, mês selecionado e perfil. As telas o acessam por `AppScope` (um `InheritedNotifier`). Para este escopo, pacotes como Provider ou Riverpod seriam peso extra.

Detalhe: exclusão é otimista — o item some na hora e o banco confirma depois.

## 4. Dados de exemplo

`MockData` gera as datas a partir de hoje, para sempre haver movimento recente. Cobre mês positivo, mês com meta estourada, mês no vermelho, valores pequenos e grandes, e vários tipos de entrada.

## 5. Gráfico

O gráfico de pizza (em rosca) é desenhado com `CustomPainter` (`lib/widgets/donut_chart.dart`). Evita dependência e deixa o visual igual à paleta do CP4.

## 6. Tipografia

A Poppins foi empacotada em `assets/fonts` (Regular, Medium e Bold), então o app não precisa baixar a fonte. Os títulos usam Bold (700). O CP4 previa SemiBold (600); se quiserem ficar 100% fiéis, basta adicionar `Poppins-SemiBold.ttf` em `assets/fonts`, declarar no `pubspec.yaml` com `weight: 600` e trocar os títulos para `FontWeight.w600`.

## 7. Visual e tom de voz

- Ícones do Material no lugar de emojis nas categorias, para o visual ficar igual em todas as plataformas.
- Cabeçalhos em roxo sólido (sem degradê), mantendo a paleta do CP4.
- Saudação de acordo com o horário e com o nome que a pessoa escolhe no onboarding.
- Frases curtas e conversadas, centralizadas em `lib/utils/micro_copy.dart`.
- Exclusão com "Desfazer" em vez de caixa de confirmação.

## 8. Plataformas

- Android: permissão de internet adicionada ao manifesto principal (necessária para o Supabase em versão de release).
- macOS: permissão de cliente de rede nas entitlements.
- Ícone e nome do app atualizados em Android, iOS, web, macOS e Windows.

## 9. Pendências conhecidas (para o CP6)

- Login e políticas de segurança por usuário no Supabase.
- Persistência de metas e perfil por usuário.
- Geração do APK.
