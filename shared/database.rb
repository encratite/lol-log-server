require 'sequel'

def getDatabase(configuration)
  database =
    Sequel.connect(
                   adapter: configuration::Adapter,
                   host: configuration::ServerAddress,
                   user: configuration::User,
                   password: configuration::Password,
                   database: configuration::Database,
                   )

  #run an early test to see if the DBMS is accessible
  database['select 1 where true'].all
  return database
end
