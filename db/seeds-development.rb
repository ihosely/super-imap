AdminUser.new(:email => "admin@example.com", :password => "password").save

plain_conn = ImapProvider::Plain.create(
  :code => 'PLAIN',
  :title          => "Fake IMAP",
  :host           => "localhost",
  :port           => 10143,
  :use_ssl        => false)

oauth1_conn = ImapProvider::Oauth1.create(
  :code            => 'OAUTH1',
  :title                     => "OAuth 1.0",
  :host                      => "localhost",
  :port                      => 10143,
  :use_ssl                   => false,
  :oauth1_access_token_path  => "oauth1_access_token_path",
  :oauth1_authorize_path     => "oauth1_authorize_path",
  :oauth1_request_token_path => "oauth1_request_token_path",
  :oauth1_scope              => "oauth1_scope",
  :oauth1_site               => "oauth1_site")

oauth2_conn = ImapProvider::Oauth2.create(
  :code      => 'OAUTH2',
  :title               => "OAuth 2.0",
  :host                => "localhost",
  :port                => 10143,
  :use_ssl             => false,
  :oauth2_grant_type   => "oauth2_grant_type",
  :oauth2_scope        => "oauth2_scope",
  :oauth2_site         => "oauth2_site",
  :oauth2_token_method => "oauth2_token_method",
  :oauth2_token_url    => "oauth2_token_url")

def create_transmit_log(mail_log, n)
  mail_log.transmit_logs.create(:response_code => 200, :response_body => "Response #{n}")
end

def create_mail_log(user, n)
  user.mail_logs.create(:message_id => "abc#{n}").tap do |mail_log|
    create_transmit_log(mail_log, 1)
    create_transmit_log(mail_log, 2)
    create_transmit_log(mail_log, 3)
  end
end

def create_user(connection, n)
  connection.users.create(
    :tag            => "User #{n}",
    :email          => "user#{n}@localhost",
    :login_username => "user#{n}@localhost",
    :login_password => "password").tap do |user|
    create_mail_log(user, 1)
    create_mail_log(user, 2)
    create_mail_log(user, 3)
  end
end

def create_partner_connection(partner, ct)
  partner.connections.create(:imap_provider_id => ct.id).tap do |connection|
    5.times.each do |n|
      create_user(connection, n)
    end
  end
end

Partner.create(:name => "Partner").tap do |partner|
  create_partner_connection(partner, plain_conn)
end
