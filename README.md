Formatação de usuários projeto MEC
==================================

Script Ruby que formata o login de usuários do projeto de Monitoramento e Avaliação de Programas SETEC/MEC utilizando a API do Redmine.

Usuários com o login diferente do padrão "nome.sobrenome" serão alterados e notificados por email.

Configuração:

- Primeiro altere o atributo BASE_URI, que está no arquivo RedmineAPI.rb, para o endereço onde o Redmine está hospedado. No caso, será o endereço: https://avaliacao.renapi.gov.br/
- O segundo passo é preciso que o usuário Administrador do Redmine entre na página "Minha Conta" e gere uma chave para acesso da API e habilite as opções "Habilitar a api REST" e "Ativar suporte JSONP" na página de Configurações/Autenticação. 
- Insira a chave de acesso gerada no atributo "KEY" do arquivo RedmineAPI.rb
- Altere também o email e senha na linha '50' do arquivo mec_api.rb para que o email remetente desejado.
- É recomendado que o assunto e o conteúdo dos emails sejam verificados.

Execução:

- Para ver quais opções estão disponíveis execute o comando: rake -T
- Para verificar quais usuários estão com o login inválidos execute o comando: rake verificar_usuarios
- Para corrigir os logins inválidos e enviar o email de notificação execute o comando: rake atualizar_usuarios_invalidos

Observação: Pode ocorrer algum erro no parsing do JSON recebido, pois não testei com muitos usuários, ou seja, pode ser que devido ao alto número de usuários pode ser necessário uma alteração para que o código trate as páginas JSON que a API retorna, visto que o limite é de 100 objetos por página.
