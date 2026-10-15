# Contexto do projeto
App Flutter "DistribuiM" para uma empresa de venda de milho e derivados.
Backend: Firebase (Auth com Google Sign-In, Firestore).
Package Android: com.gip.app_distribuim.

# Fluxo de telas
Login (Google) -> Home com 2 abas: Clientes e Entregas.
- Clientes: lista -> detalhe do cliente; ação de adicionar cliente.
- Entregas: apenas lista (sem tela de detalhe); ação de adicionar entrega.
  Cada item mostra motorista, valor pago, forma de pagamento e cidade.

# Entidades de domínio
- Usuario (id, nome, email, cargo): cargo é o enum CargoUsuario
  { motorista, admin } e Usuario.isAdmin diz se é admin. Vive em
  features/auth/domain. No Firestore: coleção 'motoristas' (guarda
  motoristas e admins), com o e-mail como id do documento; campo cargo
  ausente vale motorista. O conteúdo das telas depende do cargo (ver
  Cargos): telas leem o Usuario logado via SessionCubit, não via
  FirebaseAuth.
- Cliente.
- Entrega: referencia o motorista apenas por campos simples
  (motoristaId, motoristaNome); NÃO importa Usuario de auth.
- Pagamento não é feature nem entidade própria: valor pago e forma de
  pagamento são campos de Entrega. A tela payment_form.dart está fora de
  escopo: não editar nem usar como referência.

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
client_list abre o DeliveryForm). Exceção: qualquer tela pode ler o
SessionCubit/SessionState (auth) para obter o usuário logado. A feature
home não tem lógica própria: apenas compõe as páginas de clients e
deliveries nas abas.

Código compartilhado fica em lib/core: di/, error/, widgets/ (componentes
reutilizáveis), router/ (go_router). core/di e core/router são a raiz de
composição e podem importar de todas as features; core/widgets não deve
depender de features (exceção atual: CustomAppBar, dívida conhecida).

# Estado
flutter_bloc. Cubit por padrão; usar Bloc (eventos + estados) só em
fluxos com várias ações distintas. Estados com Equatable. A UI apenas
reage a estados; decisões ficam no Cubit/Bloc.
Listas de clientes e entregas são streams do Firestore
(ClientListCubit.ouvirClientes(usuario), DeliveryListCubit.ouvirEntregas
(usuario)) e se atualizam sozinhas: NÃO recarregue a lista manualmente
após cadastrar ou editar. Erros do stream são convertidos para Failure no
repository, como nas leituras Future. buscarClientes (Future) continua
existindo para o DeliveryFormCubit.

# Cargos (admin e motorista)
- Admin nunca é responsável por cliente (motoristaResponsavel), mas pode
  registrar entregas para qualquer cliente. motoristaResponsavel.id e
  motorista.id guardam o e-mail do motorista, que é o id do documento em
  'motoristas'.
- Listas: o motorista vê só os clientes em que é
  motoristaResponsavel.id e só as entregas com motorista.id dele; o admin
  vê tudo. O filtro é feito na QUERY do Firestore (datasource, parâmetro
  opcional idMotorista), nunca filtrando na UI. Os repositories apenas
  repassam idMotorista e não conhecem Usuario nem cargo.
- A regra de cargo fica no Cubit: ele recebe o Usuario por parâmetro
  (carregarClientes(usuario), ouvirEntregas(usuario),
  carregarDados(usuario)) e calcula
  idMotorista = usuario.isAdmin ? null : usuario.id. Cubits NÃO leem
  SessionCubit nem FirebaseAuth. As telas obtêm o Usuario do SessionCubit
  (SessionAuthenticated; em qualquer outro estado devolvem
  const SizedBox.shrink()).
- UsuarioRepository.buscarMotoristas devolve só motoristas, filtrando em
  Dart. Não use where('cargo', ...) no Firestore para isso: excluiria os
  documentos sem o campo cargo.
- Detalhe do cliente: a tabela de entregas mostra todas as entregas do
  cliente, sem filtro por motorista (o saldo pendente soma todas).
- ClientForm: o motorista é o responsável automaticamente. O admin escolhe
  o responsável em um dropdown obrigatório, sem pré-seleção, só com
  motoristas (nunca admin). Se a lista não carregar, mostra o erro com
  "Tentar novamente" e o cadastro fica bloqueado (MotoristaListCubit).
- DeliveryForm: o motorista não vê o dropdown de motorista, é registrado
  automaticamente e só escolhe entre os clientes dele. O admin vê o
  dropdown com ele mesmo pré-selecionado mais os motoristas (não outros
  admins) e todos os clientes.
- Segurança: esconder dados na tela ou filtrar na query não é controle de
  acesso. A proteção real são as Firestore Security Rules (melhoria
  futura); não trate o filtro do app como proteção.
- Editar cliente: admin e motorista editam. O ClientForm é reaproveitado
  (parâmetro opcional `cliente`: sem ele é cadastro, com ele é edição) e a
  rota é /clients/:id/edit com o Cliente em extra. A atualização usa
  campos pontuados e só altera nome, telefone, endereço e, apenas quando o
  admin envia, motoristaResponsavel; NUNCA escreve financeiro,
  ultimasEntregas nem id. O motorista não vê o campo de responsável; o
  admin vê o dropdown pré-selecionado com o responsável atual, ou vazio e
  obrigatório se ele não estiver na lista de motoristas. O telefone
  continua único, ignorando o próprio cliente. Limitações conhecidas:
  entregas antigas mantêm nome e cidade antigos do cliente, e o checkbox
  de vendas a prazo não é salvo.

# Formulários e dropdowns
- O widget Dropdown (core/widgets) trabalha com List<String>. Nunca
  resolva a opção escolhida por um texto que possa se repetir (nada de
  indexWhere por nome): use rótulos únicos e um Map<String, T> de rótulo
  para objeto.
- Rótulos: motoristas = nome, e 'nome (email)' só nos nomes repetidos;
  clientes = 'nome - cidade', e 'nome - cidade (telefone)' só nos
  repetidos, com ' #id' ao final se ainda repetir.
- Para pré-selecionar uma opção use o parâmetro opcional
  initialSelection do Dropdown (o rótulo da opção).

# Erros
Datasources não engolem exceções: deixam propagar (nada de try/catch com
print que devolve vazio ou termina como se tivesse dado certo). O
repository (data) converte para Failure: ValidationFailure para regra de
negócio violada (mensagem pronta para o usuário) e ServerFailure para
falha técnica (mensagem genérica; o detalhe vai para debugPrint). O Cubit
emite o estado de erro com Failure.message (ou uma mensagem genérica se
não for Failure). A UI mostra a mensagem e só fecha a tela em caso de
sucesso. Leituras de lista (buscarClientes, buscarMotoristas) também
propagam erros, e as telas oferecem "Tentar novamente".
buscarMotoristaPorId devolve null só quando o usuário não existe; falhas
propagam. No login, o repository converte falhas do Google em AuthFailure
e falhas na verificação do cadastro em ServerFailure (com signOut
best-effort); a LoginPage mostra state.message. Se a sessão não puder ser
verificada ao abrir o app, o SessionCubit a trata como deslogada (emite
SessionUnauthenticated e faz signOut best-effort). Em métodos async, use
await explícito dentro do try, senão o catch não captura o erro. Métodos
sem uso (registrarMotorista, buscarClientePorId, buscarClientePorTelefone,
buscarEntregaPorId) foram mantidos de propósito para telas futuras e
ainda engolem erros: não apagar nem alterar sem pedido.

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