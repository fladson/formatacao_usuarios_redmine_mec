# encoding: UTF-8
require_relative 'mec_api'
require_relative 'RedmineAPI'
require_relative 'Usuario'

desc 'Verifica e imprime na tela a lista de usuários invalidos'
task :verificar_usuarios do
  Main.verificar
end

desc 'Atualiza o login do usuario para a formatacao correta e envia um email de notificacao'
task :atualizar_usuarios_invalidos do
  Main.alterar_usuarios_invalidos
end