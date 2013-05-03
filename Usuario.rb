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
    @data_cadastro = usuario['created_on'][0..3]
    @uf_residencia = usuario['custom_fields'][0]['value']
    @unidade_ensino = usuario['custom_fields'][7]['value']
    formatar_usuario
  end
  
  def ano_cadastro_valido?
    (@data_cadastro.eql?"2012")
  end
  
  def uf_residencia_valido?
    (@uf_residencia.nil? || @uf_residencia.empty?)
  end
  
  def mec?
    (@email.include?("@mec"))
  end
  
  def formatar_sobrenome
    
    if(@sobrenome.include? 'De')
      @sobrenome.gsub!( /D[De]/, "de" )
    elsif(@sobrenome.include? 'Da')
      @sobrenome.gsub!( /D[Da]/, "da" )
    elsif(@sobrenome.include? 'Do')
      @sobrenome.gsub!( /D[Do]/, "do" )
    elsif(@sobrenome.include? 'Dos')
      @sobrenome.gsub!( /D[Dos]/, "do")
    end
  end
  
  def formatar_usuario
    concatenacao =("#{@nome}" << " " << "#{@sobrenome}").removeaccents.gsub(/[^0-9A-Za-z]/, '')
    @usuario = (concatenacao.split.first << "." << concatenacao.split.last).downcase
    @usuario_ideal = @usuario
    @nome = concatenacao.split(/\.?\s+/, 2)[0].capitalize
    sobrenome_array = concatenacao.split(/\.?\s+/, 2)[1].split(' ')
    @sobrenome = sobrenome_array.uniq.map(&:capitalize).join(' ')
    formatar_sobrenome
  end
  
  def valido?
    (@usuario.eql?@usuario_ideal)? true : false 
  end
  
  def valido_antigo?
    (@usuario_antigo.eql?@usuario_ideal)? true : false 
  end
  
  def to_s
    puts "#{@usuario_antigo};#{@usuario};#{@nome};#{@sobrenome};#{@email}"
  end
  
  def to_s2
    "#{@nome}	#{@sobrenome}	#{@email}	#{@data_cadastro}	#{@uf_residencia}	#{@unidade_ensino}\n"
  end
  
  def to_s_simples
    puts "#{ (self.valido_antigo?)? '√' : 'x'} Login: #{@usuario_antigo} | Login Ideal: #{@usuario_ideal} | Nome: #{@nome} | Sobrenome: #{@sobrenome}"
  end
end