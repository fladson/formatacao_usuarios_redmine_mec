# encoding: UTF-8
require 'httparty'
class RedmineAPI
  URI_BASE = 'https://avaliacao.renapi.gov.br'
  KEY = '' # Chave de acesso do usuario Administrador
  @@usuarios = []
  @@grupos = ['202','284','51','201']
  def self.get_usuarios
    i = 0
    27.times do
      url = "#{URI_BASE}/users.json?key=#{KEY}&limit=100&page=#{i}"
      usuarios = HTTParty.get(url)
      usuarios['users'].each{|usuario| @@usuarios << usuario}
      i+=1
    end
    @@usuarios
  end
  
  def self.get_usuario_by_id(id)
    url = "#{URI_BASE}/users/#{id}.json?key=#{KEY}"
    user = HTTParty.get(url)
    user['user']
  end
  
  # def self.alterar_usuario(usuario)
#     url = "#{URI_BASE}/users/#{JSON.parse(usuario)['user']['id']}?key=#{KEY}"
#     HTTParty.put(url, json_config(usuario))
#   end
  
  def self.get_usuarios_from_group_by_id(group_id)
    ids = []
    users = []
    url = "#{URI_BASE}/groups/#{group_id}.json?key=#{KEY}&include=users"
    usuarios = HTTParty.get(url)
    usuarios['group']['users'].each{|usuario| ids << usuario['id']}
    ids.each{|id| @@usuarios << get_usuario_by_id(id)}
  end

  def self.json_config(usuario)
    {
        :body => usuario,
        :format => :json,
        :headers => {"Content-Type" => "application/json", "content-type" => "application/json", "Accept" => "application/json"}
    }
  end
  
  def self.usuarios
    @@grupos.each{|id| get_usuarios_from_group_by_id(id)}
    get_usuarios
  end
end