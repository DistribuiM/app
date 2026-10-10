# Contexto do projeto
App Flutter "DistribuiM" para uma empresa de venda de milho e derivados.
Backend: Firebase (Auth com Google Sign-In, Firestore).

# Fluxo de telas
Login (Google) -> Home com 2 abas: Clientes e Entregas.
- Clientes: lista -> detalhe do cliente; ação de adicionar cliente.
- Entregas: apenas lista (sem tela de detalhe); ação de adicionar entrega.
  Cada item mostra motorista, valor pago, forma de pagamento e cidade.

# Entidades de domínio
- Usuario (id, nome, email, cargo): cargo é o enum CargoUsuario
  { motorista, admin }. Hoje todo usuário é motorista; admin é um papel
  futuro. Vive em features/auth/domain. No Firestore: coleção
  'motoristas', com o e-mail como id do documento. O conteúdo das telas
  dependerá do cargo (motorista vs admin): telas leem o Usuario logado
  via SessionCubit, não via FirebaseAuth.
- Cliente.
- Entrega: referencia o motorista apenas por campos simples
  (motoristaId, motoristaNome); NÃO importa Usuario de auth.
- Pagamento não é feature nem entidade própria: valor pago e forma de
  pagamento são campos de Entrega.

# Arquitetura
Clean Architecture feature-first. Features: auth, home, clients,
deliveries. Cada feature em lib/features/<nome>/:
- domain/entities, domain/repositories (interfaces abstratas),
  domain/usecases (opcional). Dart puro: não importa Flutter nem Firebase.
- data/datasources (único lugar que fala com Firebase),
  data/models (só se a serialização for realmente diferente da entidade),
  data/repositories (implementa a interface do domain).
- presentation/cubit, presentation/pages, presentation/widgets.

Regras de dependência: presentation -> domain <- data. Uma feature pode
importar o domain de outra (entidades e interfaces de repository), nunca o
data. Telas só compõem ou navegam para telas de outra feature nos casos já
existentes (home monta as abas; client_details embute a seção de entregas;
client_list abre o DeliveryForm). A feature home não tem lógica própria:
apenas compõe as páginas de clients e deliveries nas abas.

Código compartilhado fica em lib/core: di/, error/, widgets/ (componentes
reutilizáveis), router/ (go_router). core/di e core/router são a raiz de
composição e podem importar de todas as features; core/widgets não deve
depender de features (exceção atual: CustomAppBar, dívida conhecida).

# Estado
flutter_bloc. Cubit por padrão; usar Bloc (eventos + estados) só em
fluxos com várias ações distintas. Estados com Equatable. A UI apenas
reage a estados; decisões ficam no Cubit/Bloc.

# Injeção de dependência
get_it com registro MANUAL em lib/core/di/injection_container.dart.
NÃO usar injectable nem build_runner. Ordem de registro:
instâncias externas (FirebaseAuth.instance, FirebaseFirestore.instance,
GoogleSignIn.instance) -> datasources -> repositories (registrados pela
interface) -> cubits (registerFactory, uma instância por tela).
setupDependencies() é chamado uma única vez, no main(), antes de runApp;
nunca em telas ou widgets. Exceção à regra de factory: SessionCubit é
singleton (vive o app inteiro) e é fornecido na raiz com
BlocProvider.value.

# Navegação
go_router, configurado em lib/core/router/app_router.dart. Use
context.push / context.pop; não use Navigator.push. O redirect entre
login e home depende do SessionCubit (estado de sessão com o Usuario e
seu cargo), nunca de FirebaseAuth direto na UI. As abas da Home
NÃO são rotas. Rotas de detalhe que recebem um objeto via extra devem
redirecionar para '/' quando o extra for nulo. Declare rotas estáticas
(ex: /clients/new) antes das com parâmetro (/clients/:id).
Não altere main.dart nem a navegação fora do que o prompt pedir.

# Regras de migração
- Preserve lógica de negócio, queries, nomes de campos do Firestore,
  mensagens de erro e aparência das telas. Migrar é reorganizar.
- Copie a lógica existente fielmente; não reescreva do zero nem
  "modernize" APIs. google_sign_in está na versão 7: use
  GoogleSignIn.instance (initialize/authenticate); o construtor
  GoogleSignIn() não existe mais.
- NUNCA crie uma classe com o mesmo nome de uma já existente. Se ela só
  muda de camada, mova o arquivo original em vez de criar uma cópia.
- Nenhum datasource pode delegar para um service/model antigo. Apague o
  arquivo antigo só depois de confirmar (busca no projeto) que nada o
  referencia.
- Mover/renomear arquivos sem mudar lógica é feito pelo desenvolvedor no
  editor; não faça isso. Atue quando houver decisão de como dividir ou
  traduzir lógica.
- Antes de corrigir um erro que toque vários arquivos, liste todos os
  arquivos afetados. Não corrija um erro por vez às cegas.
- Uma feature por vez. Ao final, rode flutter analyze e liste os erros
  restantes antes de corrigir.
- Nunca versione nem sugira commitar: firebase_options.dart,
  google-services.json, GoogleService-Info.plist, keystores, .env.

# Nomenclatura
Termos de domínio em português, como já existe (Usuario, Cliente,
Entrega); termos técnicos em inglês (Repository, DataSource, Cubit).
Arquivos: <feature>_repository.dart, <feature>_repository_impl.dart,
<feature>_remote_data_source.dart, <feature>_cubit.dart,
<feature>_state.dart.

# Estilo de resposta
Direto, sem explicações longas, a menos que eu peça.