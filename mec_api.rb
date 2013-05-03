# encoding: UTF-8
require 'gmail'
require_relative 'Usuario'
require_relative 'RedmineAPI'
class Main
  @@usuarios_validos = []
  @@usuarios_invalidos = []
  @@count = {"ano"=>2594,"residencia"=>14,"duplicata"=>127,"mec"=>2}
  def self.algoritmo_alocacao
    saida = ""
    RedmineAPI.usuarios.each do |item|
      u = Usuario.new(item)
      saida << u.to_s2 if u.ano_cadastro_valido? && !u.uf_residencia_valido? && !saida.include?(u.to_s2) && !u.mec?
    end
    File.new("professores_2012.txt", "w").write(saida)
  end
    
  def self.verificar
    count = 0
    RedmineAPI.usuarios.each do |item|
      u = Usuario.new(item)
      if(u.id!=1) # retirando o admin dos usuarios_invalidos tive erro ao tentar alterar
        (u.valido_antigo?)? @@usuarios_validos << u : @@usuarios_invalidos << u
      end
    end
    
    @@usuarios_invalidos.each do |usuario| 
      puts usuario.to_s
    end
    
    puts "Usuários válidos: #{@@usuarios_validos.size}\nUsuários inválidos: #{@@usuarios_invalidos.size}"
  end
  
  def self.alterar_usuarios_invalidos
    verificar
    puts @@usuarios_invalidos.size
    @@usuarios_invalidos.each do |item|
      usuario = RedmineAPI.get_usuario_by_id(item.id)
      u = Usuario.new(usuario)
      usuario['login'] = u.usuario
      usuario = "{"'"user"'":#{usuario}}"
      if(RedmineAPI.alterar_usuario(usuario.gsub("=>",":")).response.code == "200")
        # conteudo = "<p>Seu usuario no projeto de Monitoramento e Avaliação de Programas SETEC/MEC mudou de <h4 style='display: inline'>#{u.usuario_antigo}</h4> para <h4 style='display: inline'>#{u.usuario}</h4></p> <p>Efetue o login no seguinte link (https://avaliacao.renapi.gov.br/login) para verificar a mudança e caso ocorra algum erro, favor enviar um email com o assunto 'Alteração de usuário incorreta' para avaliacoes.renapi@mec.gov.br</p> <p>Atenciosamente, </br> Equipe de desenvolvimento</p>"
#         begin
#           enviar_email(u.email, conteudo)
#         rescue Net::IMAP::NoResponseError
#           puts @@msg_erro_envio_email
#         else
          sucesso(u)
          #end
      else
        puts @@msg_erro_alteracao_usuario
      end
    end
  end
  
  def self.enviar_email(email, conteudo)
    Gmail.new("fladsonthiago@gmail.com", "opaco,725898") do |gmail|
      gmail.deliver do
        to email
        subject "Alteração de login no projeto de Monitoramento e Avaliação de Programas SETEC/MEC"
        html_part do
          content_type 'text/html; charset=UTF-8'
          body conteudo
        end
      end
    end
  end
  
  def self.sucesso(usuario)
    puts "\n=========================================================================\nSUCESSO: O usuario de Nome: #{usuario.nome} foi atualizado com sucesso e o email foi enviado para: #{usuario.email}\n========================================================================="
  end
  
  def self.test_mail
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH', 'fladsonthiago@gmail.com',
      :consumer_key => 'anonymous',
      :consumer_secret => 'anonymous',
      :token           => '1/8abtxmLUaTiF1omGYbckPfGzZp4oyGBXX8N-FM8hzfY',
      :secret          => '1pOtJAglTUK-5ZsR3i3hKeia'
    )
    messages_count = imap.status('INBOX', ['MESSAGES'])['MESSAGES']
    puts "Seeing #{messages_count} messages in INBOX"
  end
  @@msg_erro_envio_email = "\n=========================================================================\nERRO: Ocorreu algum erro no envio do email, favor checar log do servidor.\n========================================================================="
  @@msg_erro_alteracao_usuario = "\n===============================================================================\nERRO: Ocorreu algum erro na alteração do usuário, favor checar log do servidor.\n==============================================================================="
end