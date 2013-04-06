# encoding: UTF-8
require 'httparty'
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