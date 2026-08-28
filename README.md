Grão — Controle Financeiro para Estudantes

"Grão a grão se faz a fortuna."

👥 Integrantes do Grupo
Nome	RM	Papel
Ana Luiza Bertão	RM563171	UX/UI Design & Documentação
Sofia Franken	RM562767	Desenvolvimento Flutter & Arquitetura
📱 O que é o Grão?

O Grão é um aplicativo mobile de controle financeiro pensado especialmente para estudantes universitários. Ele permite registrar gastos, categorizar despesas, visualizar o histórico financeiro e entender para onde vai o dinheiro — de forma simples, visual e sem complicação.

❗ O Problema que Resolvemos

Estudantes universitários frequentemente enfrentam dificuldades financeiras não por falta de renda, mas por falta de controle e visibilidade sobre seus gastos. Aplicativos bancários existentes são complexos demais e não falam a língua do estudante. Planilhas são abandonadas em dias.

O resultado: fim de mês sem dinheiro, sem saber exatamente onde ele foi.

🎯 Público-Alvo
Estudantes universitários entre 18 e 25 anos
Pessoas que recebem mesada, bolsa ou salário de estágio
Iniciantes em educação financeira
Perfil: digital-native, prefere apps mobile a planilhas
✨ Funcionalidades do MVP
Funcionalidade	Descrição
📊 Dashboard de resumo	Visão geral do saldo, gastos e receitas do mês
➕ Registrar gasto/receita	Formulário rápido com valor, categoria e data
🏷️ Categorias	Alimentação, Transporte, Lazer, Estudos, Moradia, Outros
📋 Histórico	Lista de todas as transações com filtro por período
🎯 Meta de gastos	Definir limite mensal por categoria
📈 Gráfico de pizza	Visualização do gasto por categoria
🎨 Identidade Visual
Nome e Naming Rationale

Grão foi escolhido como nome por três razões:

Conceito: "Grão a grão se faz a fortuna" — a ideia de que pequenas economias fazem grande diferença
Memorabilidade: Curto, fácil de pronunciar, único no mercado de apps financeiros
Tom: Amigável, brasileiro, sem jargão financeiro intimidador
Tom de Voz

O Grão fala como um amigo que entende de finanças — direto, encorajador e sem julgamento. Não usamos termos técnicos. Usamos linguagem positiva: "Você economizou R$ 50 esse mês! "

Paleta de Cores
Token	Hex	Uso
primary	
#7C3AED	Cor principal, botões, destaques
primaryLight	
#A78BFA	Gradientes, elementos secundários
primaryDark	
#5B21B6	AppBar, elementos de peso
background	
#F5F3FF	Fundo das telas
surface	
#FFFFFF	Cards e superfícies
income	
#10B981	Entradas (verde)
expense	
#EF4444	Saídas (vermelho)
textDark	
#1E1B4B	Títulos e textos principais
textGray	
#6B7280	Textos secundários
Tipografia
Fonte principal: Poppins (Google Fonts)
Títulos: Poppins SemiBold (600), 24px
Subtítulos: Poppins Medium (500), 18px
Corpo: Poppins Regular (400), 14px
Labels: Poppins Regular (400), 12px
💡 Pitch — Por que o Grão existiria no mercado?
O Diferencial

Enquanto apps como Mobills e Organizze focam em adultos com renda consolidada, o Grão é construído pensando na realidade do estudante:

Onboarding em 30 segundos — sem cadastro de banco ou dados sensíveis
Interface gamificada — metas visuais e conquistas motivam o uso contínuo
Linguagem estudantil — categorias como "Rolê", "RU/Bandejão", "Material"
Zero fricção — registrar um gasto leva menos de 10 segundos
Modelo de Negócio
Freemium: versão gratuita com funcionalidades essenciais
Grão Premium (R$ 9,90/mês): histórico ilimitado, relatórios avançados, sync em nuvem
Parcerias: cupons e descontos de parceiros (restaurantes, livrarias, apps de streaming) dentro do app
Mercado

Existem aproximadamente 9,4 milhões de estudantes universitários no Brasil (INEP 2023). Mesmo com 0,1% de conversão para o plano premium, o potencial de receita anual ultrapassa R$ 11 milhões.

🏗️ Estrutura do Projeto
grao/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   └── history_screen.dart
│   ├── widgets/
│   │   ├── balance_card.dart
│   │   ├── transaction_tile.dart
│   │   └── category_chip.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── assets/
│   ├── images/
│   └── fonts/
├── pubspec.yaml
└── README.md
🚀 Como Rodar o Projeto
bash
# Clone o repositório
git clone https://github.com/seu-usuario/grao-app.git
cd grao-app

# Instale as dependências
flutter pub get

# Rode o app
flutter run

Requisitos: Flutter 3.x, Dart 3.x, Android Studio ou VS Code com extensão Flutter.

📅 Roadmap dos Checkpoints
Checkpoint	Foco	Status
CP4	Idealização, identidade visual, projeto inicial	✅ Em andamento
CP5	Telas completas, navegação, dados locais	🔜 Próximo
CP6	Produto final, APK, apresentação	🔜 Futuro

Projeto desenvolvido para a disciplina Cross-Platform Application Development — FIAP 2026 Professor: Hercules Ramos