# encoding: UTF-8
require 'httparty'
require 'gmail'
require_relative 'lib/extend_string'

class RedmineAPI
  URI_BASE = 'http://0.0.0.0:3000'
  KEY = '370fdba1acf1749334615b4529afd970a3f4de75' # Chave de acesso do usuario Administrador
  @@usuarios = []
  
  def self.get_usuarios
    url = "#{URI_BASE}/users.json?key=#{KEY}&limit=100"
    usuarios = HTTParty.get(url)
    usuarios['users'].each{|usuario| @@usuarios << usuario}
    @@usuarios
  end
  
  def self.get_usuario_by_id(id)
    url = "#{URI_BASE}/users/#{id}.json?key=#{KEY}"
    user = HTTParty.get(url)
    user['user']
  end
  
  def self.alterar_usuario(usuario)
    url = "#{URI_BASE}/users/#{JSON.parse(usuario)['user']['id']}?key=#{KEY}"
    HTTParty.put(url, json_config(usuario))
  end
  
  def self.json_config(usuario)
    {
        :body => usuario,
        :format => :json,
        :headers => {"Content-Type" => "application/json", "content-type" => "application/json", "Accept" => "application/json"}
    }
  end
  
  def self.usuarios
    get_usuarios
  end
end

class Usuario
  attr_accessor :id, :usuario, :nome, :sobrenome, :email, :usuario_ideal, :usuario_antigo
  def initialize(usuario)
    @id = usuario['id']
    @usuario = usuario['login']
    @usuario_antigo = @usuario
    @nome = usuario['firstname']
    @sobrenome = usuario['lastname']
    @email = usuario['mail']
    formatar_usuario
  end
  
  def formatar_usuario
    concatenacao =("#{@nome}" << " " << "#{@sobrenome}").removeaccents
    @usuario = (concatenacao.split.first << "." << concatenacao.split.last).downcase
    @usuario_ideal = @usuario
  end
  
  def valido?
    (@usuario.eql?@usuario_ideal)? true : false 
  end
  
  def valido_antigo?
    (@usuario_antigo.eql?@usuario_ideal)? true : false 
  end
  
  def to_s
    puts "Login antigo: #{@usuario_antigo}\nLogin atual: #{@usuario}\nNome: #{@nome}\nSobrenome: #{@sobrenome}\nLogin Ideal: #{@usuario_ideal}\nEmail: #{@email}\nValido: #{valido?}"
  end
  
  def to_s_simples
    puts "#{ (self.valido_antigo?)? '√' : 'x'} Login: #{@usuario_antigo} | Login Ideal: #{@usuario_ideal}"
  end
end

class Main
  @@msg_erro_envio_email = "\n=========================================================================\nERRO: Ocorreu algum erro no envio do email, favor checar log do servidor.\n========================================================================="
  @@msg_erro_alteracao_usuario = "\n===============================================================================\nERRO: Ocorreu algum erro na alteração do usuário, favor checar log do servidor.\n==============================================================================="
  @@usuarios_validos = []
  @@usuarios_invalidos = []
  
  def self.verificar
    count = 0
    RedmineAPI.usuarios.each do |item|
      u = Usuario.new(item)
      if(u.id!=1) # retirando o admin dos usuarios_invalidos tive erro ao tentar alterar
        (u.valido_antigo?)? @@usuarios_validos << u : @@usuarios_invalidos << u
      end
      puts u.to_s_simples
    end
    puts "Usuários válidos: #{@@usuarios_validos.size}\nUsuários inválidos: #{@@usuarios_invalidos.size}"
  end
  
  def self.alterar_usuarios_invalidos
    self.verificar
    @@usuarios_invalidos.each do |item|
      usuario = RedmineAPI.get_usuario_by_id(item.id)
      u = Usuario.new(usuario)
      usuario['login'] = u.usuario
      usuario = "{"'"user"'":#{usuario}}"
      if(RedmineAPI.alterar_usuario(usuario.gsub("=>",":")).response.code == "200")
        conteudo = "<p>Seu usuario no projeto de Monitoramento e Avaliação de Programas SETEC/MEC mudou de <h4 style='display: inline'>#{u.usuario_antigo}</h4> para <h4 style='display: inline'>#{u.usuario}</h4></p> <p>Efetue o login no seguinte link (https://avaliacao.renapi.gov.br/login) para verificar a mudança e caso ocorra algum erro, favor enviar um email com o assunto 'Alteração de usuário incorreta' para avaliacoes.renapi@mec.gov.br</p> <p>Atenciosamente, </br> Equipe de desenvolvimento</p>"
        begin
          enviar_email(u.email, conteudo)
        rescue Net::IMAP::NoResponseError
          puts @@msg_erro_envio_email
        else
          sucesso(u)
        end
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
end

#Main.verificar
Main.alterar_usuarios_invalidos