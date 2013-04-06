# encoding: UTF-8
require_relative 'lib/extend_string'
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
