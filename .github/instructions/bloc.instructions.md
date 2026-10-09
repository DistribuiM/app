---
applyTo: "lib/features/**/presentation/**"
---
- Um Cubit/Bloc por tela ou fluxo, dentro da própria feature; nunca
  compartilhado entre features.
- Estados como classes Equatable (ou sealed) com nomes explícitos
  (Initial, Loading, Loaded, Error); sem flags soltas como isLoading
  espalhadas pela UI.
- Widgets consomem estado com BlocBuilder/BlocConsumer/BlocListener;
  efeitos como SnackBar e navegação ficam no listener.
- Nenhuma chamada a Firebase ou a datasources na camada presentation:
  só o Cubit conversa com o repository (interface do domain).
- Cubits são obtidos via getIt e fornecidos com BlocProvider na página.
- Se usar Bloc, eventos nomeados no passado (ClientsFetched,
  DeliveryAdded).